import 'package:flutter/services.dart';

import 'notification_schedule.dart';

/// Hands the scheduled milestone notifications to iOS.
///
/// Local notifications only: `UNUserNotificationCenter` schedules these
/// on-device with no server, no APNs, and no push entitlement, so nothing
/// about the app's privacy answers changes. See CLAUDE.md.
///
/// Its own channel rather than a method on the widget bridge — that one is
/// named `/widget`, and hanging notification scheduling off it would make
/// the name a lie.
class NotificationBridge {
  static const _channel =
      MethodChannel('net.leerichardson.dayscounter/notifications');

  /// Asks for permission, returning whether it was granted.
  ///
  /// Called when a user first switches notifications on for an event, never
  /// at launch: a permission prompt before the user has asked for anything
  /// is the fastest route to a permanent denial.
  static Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on MissingPluginException {
      // No native handler on this platform (web, macOS, tests).
      return false;
    }
  }

  /// Replaces every pending request this app has scheduled.
  ///
  /// Replace rather than merge: the native side cancels the app's existing
  /// requests before adding these, so the caller never has to work out what
  /// changed, and a deleted or edited event can't leave an orphan behind.
  static Future<void> schedule(List<PendingNotification> notifications) async {
    try {
      await _channel.invokeMethod(
        'schedule',
        notifications.map((n) => n.toJson()).toList(),
      );
    } on MissingPluginException {
      // As above — notifications are iOS-only, so there's nothing to do.
    }
  }
}
