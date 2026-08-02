import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/date_event.dart';

/// Bridges the featured widget event to the native iOS side, which stores it
/// in the shared App Group container for the WidgetKit extension to read.
class WidgetBridge {
  static const _channel = MethodChannel('net.leerichardson.dayscounter/widget');

  static Future<void> updateFeaturedEvent(DateEvent? event) async {
    final payload = event == null ? null : jsonEncode(event.toJson());
    try {
      await _channel.invokeMethod('updateFeaturedEvent', payload);
    } on MissingPluginException {
      // No native handler on this platform (web, macOS, tests) — the
      // widget is iOS-only, so there's nothing to sync to.
    }
  }
}
