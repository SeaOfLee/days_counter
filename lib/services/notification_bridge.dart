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

  /// Fires a throwaway notification a few seconds from now, carrying the
  /// same copy a real reminder would.
  ///
  /// Debug builds only — the native handler is inside `#if DEBUG` and does
  /// not exist in release. Real reminders are days away and fire at 9am, so
  /// this is the only way to exercise delivery without waiting or moving the
  /// clock. It sends the production title and body deliberately: a test that
  /// shows placeholder text proves the plumbing works but says nothing about
  /// how the thing actually reads on a lock screen.
  static Future<void> debugFireTestNotification({int seconds = 10}) async {
    try {
      await _channel.invokeMethod('debugFireTestNotification', {
        'seconds': seconds,
        'title': notificationTitle,
        'body': notificationBody,
      });
    } on MissingPluginException {
      // Not iOS, or a release build.
    }
  }

  /// Everything iOS currently holds for this app, one line each.
  ///
  /// Debug builds only. This is what makes scheduling verifiable without
  /// waiting for a fire date to arrive.
  static Future<List<String>> debugPendingNotifications() async {
    try {
      final pending =
          await _channel.invokeMethod<List<Object?>>('debugPendingNotifications');
      return pending?.cast<String>() ?? const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Replaces every pending request this app has scheduled.
  ///
  /// Replace rather than merge: the native side cancels the app's existing
  /// requests before adding these, so the caller never has to work out what
  /// changed, and a deleted or edited event can't leave an orphan behind.
  /// Returns how many iOS actually accepted, which will not match the
  /// number passed in if the payload fails to decode natively.
  static Future<int> schedule(List<PendingNotification> notifications) async {
    try {
      return await _channel.invokeMethod<int>(
            'schedule',
            notifications.map((n) => n.toJson()).toList(),
          ) ??
          0;
    } on MissingPluginException {
      // As above — notifications are iOS-only, so there's nothing to do.
      return 0;
    }
  }
}
