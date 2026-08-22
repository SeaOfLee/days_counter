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
  /// Returns how many iOS actually accepted and, if any were rejected, the
  /// first reason why.
  ///
  /// `UNUserNotificationCenter.add` is asynchronous and reports failure only
  /// through a completion handler, so the count comes from those handlers
  /// rather than from the number of requests sent — the difference is what
  /// tells a silent rejection from a success.
  static Future<({int accepted, String? error})> schedule(
    List<PendingNotification> notifications,
  ) async {
    try {
      final outcome = await _channel.invokeMapMethod<String, Object?>(
        'schedule',
        notifications.map((n) => n.toJson()).toList(),
      );
      return (
        accepted: outcome?['accepted'] as int? ?? 0,
        error: outcome?['error'] as String?,
      );
    } on MissingPluginException {
      // As above — notifications are iOS-only, so there's nothing to do.
      return (accepted: 0, error: null);
    }
  }

  /// Whether iOS will accept notifications from this app at all.
  ///
  /// Debug builds only. A denied or never-asked status is the first thing
  /// to rule out when nothing schedules, and it is otherwise invisible.
  static Future<String> debugAuthorizationStatus() async {
    try {
      return await _channel.invokeMethod<String>('debugAuthorizationStatus') ??
          'unknown';
    } on MissingPluginException {
      return 'unavailable';
    }
  }
}
