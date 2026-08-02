import Flutter
import UIKit
import WidgetKit

// Keep these in sync with the matching constants in DaysCounterWidget.swift —
// the two targets compile separately and can't share this definition.
private let widgetBridgeChannelName = "net.leerichardson.dayscounter/widget"
private let widgetAppGroupIdentifier = "group.net.leerichardson.dayscounter"
private let widgetFeaturedEventKey = "featuredEventPayload"

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
      case "updateFeaturedEvent":
        let defaults = UserDefaults(suiteName: widgetAppGroupIdentifier)
        if let payload = call.arguments as? String {
          defaults?.set(payload, forKey: widgetFeaturedEventKey)
        } else {
          defaults?.removeObject(forKey: widgetFeaturedEventKey)
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
