import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _notificationChannel =
    MethodChannel('net.leerichardson.dayscounter/notifications');

/// Registers a no-op handler for the notification channel.
///
/// Required in every test that builds the app, for the same reason as
/// [mockWidgetBridgeChannel]: `flutter_test`'s binary messenger *hangs*
/// on an unmocked channel rather than throwing, so `pumpAndSettle()` times
/// out with no useful error.
void mockNotificationChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_notificationChannel, (call) async {
    return call.method == 'requestPermission' ? true : null;
  });
}

/// Keeps every call so a test can assert on what was scheduled.
class RecordingNotificationBridge {
  final List<MethodCall> calls = [];

  List<Map<String, dynamic>> get lastScheduled {
    final scheduled = calls.lastWhere((c) => c.method == 'schedule');
    return (scheduled.arguments as List<dynamic>)
        .cast<Map<Object?, Object?>>()
        .map((m) => m.cast<String, dynamic>())
        .toList();
  }

  List<String> get lastIds =>
      lastScheduled.map((n) => n['id'] as String).toList();

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_notificationChannel, (call) async {
      calls.add(call);
      return call.method == 'requestPermission' ? true : null;
    });
  }
}
