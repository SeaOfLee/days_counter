import Flutter
import UIKit
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
  }
}
