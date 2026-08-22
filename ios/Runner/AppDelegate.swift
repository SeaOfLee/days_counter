import Flutter
import UIKit
import UserNotifications
import WidgetKit

// Keep these in sync with the matching constants in DaysCounterWidget.swift —
// the two targets compile separately and can't share this definition.
private let widgetBridgeChannelName = "net.leerichardson.dayscounter/widget"
private let widgetAppGroupIdentifier = "group.net.leerichardson.dayscounter"
private let widgetEventsKey = "eventsPayload"
// Retired in Phase 21 when the widget moved from one featured event to
// per-instance configuration. Cleared on write so upgraded installs don't
// keep a dead single-event blob around. Safe to delete after a release.
private let retiredFeaturedEventKey = "featuredEventPayload"

// Local notifications only — scheduled on-device by UNUserNotificationCenter,
// with no server, no APNs and no push entitlement. Flutter decides what to
// schedule and how it reads; this side only hands the requests to iOS.
private let notificationChannelName = "net.leerichardson.dayscounter/notifications"

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: widgetBridgeChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "updateEvents":
        let defaults = UserDefaults(suiteName: widgetAppGroupIdentifier)
        if let payload = call.arguments as? String {
          defaults?.set(payload, forKey: widgetEventsKey)
          defaults?.removeObject(forKey: retiredFeaturedEventKey)
        }
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let notifications = FlutterMethodChannel(
      name: notificationChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    notifications.setMethodCallHandler { call, result in
      switch call.method {
      case "requestPermission":
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound]) { granted, _ in
            // Hop back to the main thread: the completion handler runs on an
            // arbitrary queue, and Flutter results must be sent from the
            // platform thread.
            DispatchQueue.main.async { result(granted) }
          }

      case "schedule":
        let center = UNUserNotificationCenter.current()
        // Flutter always sends the complete set, so replacing wholesale is
        // what keeps a deleted or renamed event from leaving an orphan.
        center.removeAllPendingNotificationRequests()
        var added = 0
        var firstError: String?
        let group = DispatchGroup()
        let lock = NSLock()
        // Cast the outer list and each element separately. Flutter's codec
        // delivers dictionaries whose keys are AnyHashable-wrapped, so the
        // tempting `as? [[String: Any]]` on the whole payload can fail as a
        // unit and leave nothing scheduled without raising anything.
        for raw in (call.arguments as? [Any]) ?? [] {
          guard
            let item = raw as? [AnyHashable: Any],
            let id = item["id"] as? String,
            let title = item["title"] as? String,
            let body = item["body"] as? String
          else { continue }

          let content = UNMutableNotificationContent()
          content.title = title
          content.body = body
          content.sound = .default

          // Calendar components, never a time interval: an interval trigger
          // adds fixed 24-hour blocks and drifts across a DST boundary, and
          // this one follows the user across time zones.
          var components = DateComponents()
          components.year = item["year"] as? Int
          components.month = item["month"] as? Int
          components.day = item["day"] as? Int
          components.hour = item["hour"] as? Int
          components.minute = item["minute"] as? Int

          // add() is asynchronous and reports failure only through its
          // completion handler. Counting loop iterations instead would count
          // attempts and call them successes — which is exactly the lie that
          // hid a scheduling failure once already.
          group.enter()
          center.add(
            UNNotificationRequest(
              identifier: id,
              content: content,
              trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )
          ) { error in
            lock.lock()
            if let error {
              if firstError == nil { firstError = error.localizedDescription }
            } else {
              added += 1
            }
            lock.unlock()
            group.leave()
          }
        }
        // Reports what iOS actually accepted, plus the first failure reason,
        // so a rejection surfaces instead of vanishing.
        group.notify(queue: .main) {
          result(["accepted": added, "error": firstError as Any])
        }

#if DEBUG
      // Debug-only helpers. Milestones are days away and fire at 9am, so
      // without these the delivery path can't be exercised without waiting
      // or moving the clock. Compiled out of release entirely.
      case "debugFireTestNotification":
        let args = call.arguments as? [AnyHashable: Any] ?? [:]
        let seconds = args["seconds"] as? Int ?? 10
        let content = UNMutableNotificationContent()
        // Flutter passes the real copy, so this previews exactly what a
        // user will see rather than placeholder text that proves only that
        // the plumbing works.
        content.title = args["title"] as? String ?? "Dayward"
        content.body = args["body"] as? String ?? "Today's the day."
        content.sound = .default
        // An interval trigger, which the real scheduling path deliberately
        // avoids: over ten seconds there is no DST or time-zone drift to
        // worry about, and "fire N seconds from now" is exactly what this
        // needs.
        UNUserNotificationCenter.current().add(
          UNNotificationRequest(
            identifier: "debug-test",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(
              timeInterval: TimeInterval(seconds), repeats: false
            )
          )
        )
        result(nil)

      case "debugAuthorizationStatus":
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          let status: String
          switch settings.authorizationStatus {
          case .notDetermined: status = "notDetermined — never asked"
          case .denied: status = "denied — nothing will schedule"
          case .authorized: status = "authorized"
          case .provisional: status = "provisional"
          case .ephemeral: status = "ephemeral"
          @unknown default: status = "unknown"
          }
          DispatchQueue.main.async { result(status) }
        }

      case "debugPendingNotifications":
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
          let described = requests.map { request -> String in
            let when = (request.trigger as? UNCalendarNotificationTrigger)?
              .nextTriggerDate()
              .map(ISO8601DateFormatter().string(from:)) ?? "n/a"
            return "\(request.identifier)  \(when)  \(request.content.body)"
          }
          DispatchQueue.main.async { result(described.sorted()) }
        }
#endif

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
