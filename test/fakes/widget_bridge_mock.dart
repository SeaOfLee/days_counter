import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _widgetBridgeChannel = MethodChannel('net.leerichardson.dayscounter/widget');

/// Registers a no-op handler for the widget bridge channel so tests don't
/// hang waiting on a platform response that will never arrive.
void mockWidgetBridgeChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_widgetBridgeChannel, (call) async => null);
}

/// Same handler, but keeps every call so a test can assert on what actually
/// reached the widget. Use this when the payload itself is the thing under
/// test; [mockWidgetBridgeChannel] is enough everywhere else.
class RecordingWidgetBridge {
  final List<MethodCall> calls = [];

  MethodCall get lastCall => calls.last;

  /// The most recent payload, decoded back into the list of event maps.
  List<Map<String, dynamic>> get lastEvents {
    final payload = lastCall.arguments as String;
    return (jsonDecode(payload) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  List<String> get lastEventIds =>
      lastEvents.map((event) => event['id'] as String).toList();

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_widgetBridgeChannel, (call) async {
          calls.add(call);
          return null;
        });
  }
}
