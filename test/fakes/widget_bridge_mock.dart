import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _widgetBridgeChannel = MethodChannel('com.example.daysCounter/widget');

/// Registers a no-op handler for the widget bridge channel so tests don't
/// hang waiting on a platform response that will never arrive.
void mockWidgetBridgeChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_widgetBridgeChannel, (call) async => null);
}
