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

          center.add(
            UNNotificationRequest(
              identifier: id,
              content: content,
              trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )
          )
          added += 1
        }
        // Returns what was actually accepted rather than nothing, so a
        // payload that fails to decode shows up as a number that disagrees
        // with what Flutter planned instead of failing silently.
        result(added)

#if DEBUG
      // Debug-only helpers. Milestones are days away and fire at 9am, so
      // without these the delivery path can't be exercised without waiting
      // or moving the clock. Compiled out of release entirely.
      case "debugFireTestNotification":
        let seconds = call.arguments as? Int ?? 10
        let content = UNMutableNotificationContent()
        content.title = "Dayward test"
        content.body = "Notifications are working."
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
