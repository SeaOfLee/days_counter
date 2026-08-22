import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/events_provider.dart';
import '../services/notification_bridge.dart';
import '../services/notification_schedule.dart';

/// Developer tools, reachable only from a debug build.
///
/// Milestone notifications are days away and fire at 9am, so without a way
/// to look at what iOS is actually holding — and to provoke a delivery on
/// demand — the whole path is unverifiable short of moving the device clock.
/// The native handlers behind these live inside `#if DEBUG` and are not
/// compiled into release at all.
class DebugMenuScreen extends ConsumerStatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  ConsumerState<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends ConsumerState<DebugMenuScreen> {
  List<String>? _pending;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshPending();
  }

  Future<void> _refreshPending() async {
    setState(() => _loading = true);
    final pending = await NotificationBridge.debugPendingNotifications();
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _loading = false;
    });
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _fireTest() async {
    await NotificationBridge.debugFireTestNotification(seconds: 10);
    if (!mounted) return;
    // iOS suppresses banners while the app is foregrounded, so without this
    // the tester sees nothing and concludes the feature is broken.
    _say('Firing in 10s — background the app to see it.');
  }

  Future<void> _reschedule() async {
    final events = ref.read(eventsProvider).valueOrNull ?? const [];
    final planned = plannedNotifications(events);
    final accepted = await NotificationBridge.schedule(planned);
    if (!mounted) return;
    // Showing both numbers is the point: a mismatch means the payload
    // didn't survive the platform channel.
    _say('Planned ${planned.length}, iOS accepted $accepted.');
    await _refreshPending();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pending = _pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refreshPending,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Fire a test notification'),
            subtitle: const Text('Arrives in 10 seconds'),
            onTap: _fireTest,
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat_outlined),
            title: const Text('Reschedule from current events'),
            subtitle: const Text('Same call the app makes after an edit'),
            onTap: _reschedule,
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              pending == null
                  ? 'Pending with iOS'
                  : 'Pending with iOS (${pending.length})',
              style: textTheme.titleMedium,
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (pending == null || pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Nothing scheduled. Turn on "Remind me" for an event whose '
                'next milestone is still ahead of it.',
              ),
            )
          else
            for (final line in pending)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(line, style: textTheme.bodySmall),
              ),
        ],
      ),
    );
  }
}
