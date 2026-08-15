import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/date_event.dart';

/// Bridges the event list to the native iOS side, which stores it in the
/// shared App Group container for the WidgetKit extension to read. Each
/// placed widget picks one of these events for itself, so the widget needs
/// the whole list rather than a single chosen event.
class WidgetBridge {
  static const _channel = MethodChannel('net.leerichardson.dayscounter/widget');

  /// Always sends a string, never null — an empty list becomes `"[]"`. The
  /// widget relies on that: it distinguishes "the user has no events" from
  /// "nothing has ever been synced" by whether the key exists at all.
  static Future<void> updateEvents(List<DateEvent> events) async {
    final payload = jsonEncode(events.map((event) => event.toJson()).toList());
    try {
      await _channel.invokeMethod('updateEvents', payload);
    } on MissingPluginException {
      // No native handler on this platform (web, macOS, tests) — the
      // widget is iOS-only, so there's nothing to sync to.
    }
  }
}
