// Writes a fixed set of demo events straight into a booted iOS simulator's
// app container, for capturing App Store screenshots.
//
// This is a development tool. It is not part of the app — the app itself
// ships with no seed data and starts on the empty state.
//
//   dart run tool/seed_demo_events.dart
//   dart run tool/seed_demo_events.dart --container <path/to/Documents>
//
// Terminate-and-relaunch is required: LocalEventRepository caches events in
// memory, so a running app would overwrite whatever this writes. Relaunching
// also makes EventsNotifier.build() push the featured event through the
// widget bridge, so the Home Screen widget picks up the demo data too.

import 'dart:convert';
import 'dart:io';

import 'package:days_counter/models/date_event.dart';
import 'package:days_counter/utils/date_calculations.dart';

const bundleId = 'net.leerichardson.dayscounter';

/// AppColors.cardTints.length. Duplicated rather than imported: app_colors.dart
/// pulls in package:flutter, which a plain `dart run` script can't load.
const cardTintCount = 4;

/// The demo events, in display order. Dates are absolute rather than
/// relative to today so the "Since June 14, 2015" lines read like real
/// events; the day counts drift by however long it's been since this list
/// was last revised, which doesn't matter for a screenshot.
final demoEvents = <_Demo>[
  _Demo('Anniversary', DateTime(2015, 6, 14), CountDirection.since, '💍'),
  _Demo('Started Running', DateTime(2026, 1, 1), CountDirection.since, '🏃'),
  _Demo('New Apartment', DateTime(2026, 3, 20), CountDirection.since, '🌱'),
  _Demo('Japan Trip', DateTime(2026, 9, 1), CountDirection.until, '✈️'),
  _Demo('Birthday', DateTime(2026, 10, 4), CountDirection.until, '🎂'),
  _Demo('Adopted Milo', DateTime(2024, 8, 2), CountDirection.since, '🐶'),
  _Demo('Quit Coffee', DateTime(2026, 7, 30), CountDirection.since, '☕'),
];

/// Which event the widget shows (index into [demoEvents]).
const featuredIndex = 0;

class _Demo {
  _Demo(this.title, this.date, this.direction, this.emoji);

  final String title;
  final DateTime date;
  final CountDirection direction;
  final String emoji;
}

/// EventCard tints its background with `event.id.hashCode % cardTints.length`,
/// so the id is the only lever over card color. Rather than accept whatever
/// colors fall out, search for an id that lands on the wanted tint — that way
/// the screenshot shows every tint, in order, instead of a random run with
/// two identical cards side by side.
String _idForTint(int wantedTint, int seed) {
  for (var attempt = 0; attempt < 100000; attempt++) {
    final candidate = '${seed + attempt}';
    if (candidate.hashCode.abs() % cardTintCount ==
        wantedTint % cardTintCount) {
      return candidate;
    }
  }
  throw StateError('No id found for tint $wantedTint');
}

Future<String> _bootedContainerDocuments() async {
  final result = await Process.run('xcrun', [
    'simctl',
    'get_app_container',
    'booted',
    bundleId,
    'data',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'Could not find $bundleId on the booted simulator. Boot a simulator '
      'and run the app there once, or pass --container explicitly.\n'
      '${result.stderr}',
    );
    exit(1);
  }
  return '${(result.stdout as String).trim()}/Documents';
}

Future<void> main(List<String> args) async {
  final containerFlag = args.indexOf('--container');
  final documentsPath = containerFlag == -1
      ? await _bootedContainerDocuments()
      : args[containerFlag + 1];

  final events = <DateEvent>[];
  // Distinct id "namespaces" per event so the tint search doesn't return the
  // same id twice.
  var seed = 1000000;
  for (var i = 0; i < demoEvents.length; i++) {
    final demo = demoEvents[i];
    final id = _idForTint(i, seed);
    seed += 100000;
    events.add(
      DateEvent(
        id: id,
        title: demo.title,
        date: demo.date,
        direction: demo.direction,
        emoji: demo.emoji,
      ),
    );
  }

  // Stop the app first — it holds events in memory and would clobber this.
  await Process.run('xcrun', ['simctl', 'terminate', 'booted', bundleId]);

  final documents = Directory(documentsPath);
  await documents.create(recursive: true);
  await File('${documents.path}/events.json').writeAsString(
    jsonEncode(events.map((e) => e.toJson()).toList()),
  );
  await File(
    '${documents.path}/featured_event_id.txt',
  ).writeAsString(events[featuredIndex].id);

  stdout.writeln('Wrote ${events.length} demo events to ${documents.path}');
  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    final days = event.direction == CountDirection.since
        ? daysSince(event.date)
        : daysUntil(event.date);
    final featured = i == featuredIndex ? '  (featured)' : '';
    stdout.writeln(
      '  ${event.emoji} ${event.title}: ${dayCountLabel(days)}, '
      '${event.direction == CountDirection.since ? 'since' : 'until'} '
      '${formatDate(event.date)}$featured',
    );
  }
  stdout.writeln('\nRelaunch the app to pick these up:');
  stdout.writeln('  xcrun simctl launch booted $bundleId');
}
