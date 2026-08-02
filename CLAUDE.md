# CLAUDE.md

Guidance for agents working in this repository.

## What this is

An iOS-first Flutter app for tracking the number of days since or until
meaningful dates (e.g. "Last Drink — 1,139 days"). It is a **learning
project**, not a commercial product — the point is hands-on practice with
Flutter/Dart, Riverpod, local persistence, Xcode, Swift/SwiftUI, WidgetKit,
App Groups, and signing/provisioning. Optimize for understanding over
speed or polish.

The full phased build plan lives in [PROJECT_PLAN.md](PROJECT_PLAN.md).
**Read it before starting non-trivial work** — it defines the current
phase, the success criterion for that phase, and what's explicitly
deferred. Do not jump ahead to a later phase's work (e.g. don't add
Riverpod, persistence, or the WidgetKit extension) unless asked or unless
the plan's current phase calls for it.

## Current state

Phases 0–11 are done: environment verified, project scaffolded, the
`DateEvent` domain model exists ([lib/models/date_event.dart](lib/models/date_event.dart)) with JSON
serialization, calendar-day math lives in [lib/utils/date_calculations.dart](lib/utils/date_calculations.dart) with
unit tests covering same-day/yesterday/tomorrow, leap years, year-end
rollover, and DST transitions, and [lib/screens/event_list_screen.dart](lib/screens/event_list_screen.dart) renders
events via [lib/widgets/event_card.dart](lib/widgets/event_card.dart) with full CRUD: tapping + opens
[lib/screens/event_edit_screen.dart](lib/screens/event_edit_screen.dart) to create an event, tapping a card opens the
same editor prepopulated to edit or delete it. Storage sits behind
[lib/repositories/event_repository.dart](lib/repositories/event_repository.dart), implemented by
[lib/repositories/local_event_repository.dart](lib/repositories/local_event_repository.dart), which persists events as a JSON
file (via `path_provider`) so they survive an app restart — verified both
by widget/unit tests and manually on the iOS simulator. State management
is Riverpod ([lib/providers/events_provider.dart](lib/providers/events_provider.dart)): `EventListScreen` is a
`ConsumerWidget` watching an `AsyncNotifierProvider` instead of holding
its own state. The UI has had a light polish pass: event cards show the
optional emoji next to the title, an empty state appears when there are
no events, and the app supports light/dark mode via `ThemeMode.system`.
The app has been signed and run successfully on a physical iPhone
(Phase 12), with `DEVELOPMENT_TEAM` configured in
`ios/Runner.xcodeproj/project.pbxproj` via Xcode's automatic signing. A
WidgetKit extension target, `DaysCounterWidget`
([ios/DaysCounterWidget/DaysCounterWidget.swift](ios/DaysCounterWidget/DaysCounterWidget.swift)),
now exists and renders a static hard-coded entry ("Last Drink" / "1,139"
/ "days") addable to the Home Screen (Phase 13). The template-generated
Control Widget and Live Activity files were removed as out of scope.
Adding the extension exposed an Xcode 26 build-system bug where
`ExtractAppIntentsMetadata` cycles with Flutter's "Thin Binary" script
phase once an extension is embedded; the fix — needed again if the
widget target is ever recreated — was disabling
`ENABLE_APP_INTENTS_METADATA_EXTRACTION` on both the Runner and widget
targets *and* reordering Runner's build phases so "Embed Foundation
Extensions" runs before "Thin Binary". Do not remove Flutter's
`Info.plist` input path from the Thin Binary phase to work around this —
`flutter_tools` (`xcode_thin_binary_build_phase_input_paths_migration.dart`)
re-adds it on every build to guard against a separate Bonjour/mDNS bug.
The widget's `Provider.getTimeline` (Phase 14) now generates a real
7-day run of `TimelineEntry` values from a hard-coded anchor date
(June 19, 2023), normalized to start-of-day and using `.atEnd` as the
reload policy, so the displayed day count advances automatically at
midnight instead of staying frozen. Both targets now share the App
Group `group.com.example.daysCounter` (Phase 15) — Runner's and the
widget extension's entitlements
([ios/Runner/Runner.entitlements](ios/Runner/Runner.entitlements),
[ios/DaysCounterWidgetExtension.entitlements](ios/DaysCounterWidgetExtension.entitlements))
both declare it under the same development team, confirmed by
inspecting the signed binaries. The widget now renders real Flutter
data (Phase 16): [lib/services/widget_bridge.dart](lib/services/widget_bridge.dart) calls a
`MethodChannel` (`com.example.daysCounter/widget`) whose handler in
[ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift) writes the JSON payload into the App
Group's `UserDefaults`; `EventsNotifier` (`build`/`saveEvent`/`deleteEvent`
in [lib/providers/events_provider.dart](lib/providers/events_provider.dart)) awaits this sync on every
change rather than firing it and forgetting it — the app can be
backgrounded moments after an edit, and an un-awaited platform-channel
call can be cut off mid-write. Since there's no featured-event setting
yet (that's Phase 18), the *first* event in the list stands in as a
temporary placeholder for "the event shown in the widget." The widget's
Swift code mirrors [lib/utils/date_calculations.dart](lib/utils/date_calculations.dart)'s UTC-normalized
day-diffing (not local-midnight) so counts stay correct across DST. Dart
tests that exercise `EventsNotifier` must register a mock handler for
that channel (see [test/fakes/widget_bridge_mock.dart](test/fakes/widget_bridge_mock.dart) and each test
file's `setUp`) — without it, `flutter_test`'s binary messenger hangs
forever on the unmocked channel rather than throwing quickly, so
`pumpAndSettle()` times out. Next up is Phase 17, adding a native bridge
call so the widget refreshes immediately after an edit instead of
waiting for WidgetKit's own reload schedule. Expect to be asked to work
through the phases in
[PROJECT_PLAN.md](PROJECT_PLAN.md) roughly in order.

## Guiding principles (from PROJECT_PLAN.md)

1. Build vertically — one working slice at a time — rather than designing
   the whole architecture upfront.
2. Keep the domain model small; don't add fields (color, notes, sortOrder,
   etc.) until a phase actually needs them.
3. Treat dates as **calendar dates, not durations**. Never use
   `target.difference(DateTime.now()).inDays` directly — normalize both
   dates to midnight first (see Phase 3 in the plan) so DST and
   time-of-day don't skew day counts.
4. Flutter owns the main app (UI, navigation, forms, domain model, date
   math, persistence, state). Native Swift/SwiftUI/WidgetKit owns only the
   Home Screen widget, its timeline, and shared App Group access — don't
   duplicate domain logic in Swift.
5. No backend, auth, accounts, analytics, push notifications, cloud sync,
   subscriptions, IAP, social features, calendar integration, or CI/CD in
   V1. No Android support is required.
6. Avoid premature architecture — no `domain/`, `application/`,
   `presentation/`, `infrastructure/`, `ports/`, `adapters/`, `usecases/`
   layers. Keep the flat structure below.
7. Don't add a routing package, state management (Riverpod), or a
   persistence layer until the plan's corresponding phase says to.
8. Commit at each meaningful learning milestone with small, descriptive
   commits (see "Suggested Git Milestones" in the plan).

## Target structure

```text
lib/
├── main.dart
├── app.dart
├── models/
│   └── date_event.dart
├── repositories/
│   └── event_repository.dart       # introduced Phase 8+
├── providers/
│   └── events_provider.dart        # introduced Phase 10+
├── screens/
│   └── event_list_screen.dart
├── widgets/
│   └── event_card.dart
└── utils/
    └── date_calculations.dart

ios/
├── Runner/
└── DaysSinceWidget/                # introduced Phase 13+
```

Keep date-calculation logic in `utils/` independent of any Flutter widget
so it's unit-testable in isolation.

## Commands

```bash
flutter doctor -v        # verify toolchain (Flutter, Xcode, CocoaPods)
flutter devices          # confirm an iOS simulator target is available
open -a Simulator         # launch the iOS simulator
flutter run               # run the app
flutter test               # run Dart/widget unit tests
flutter analyze           # static analysis (flutter_lints via analysis_options.yaml)
```

This project's `pubspec.yaml` targets Dart SDK `^3.12.2`. There is no
Android CI/build expectation — Android warnings from `flutter doctor` can
be ignored.

## Testing expectations

- Date-calculation logic (`utils/date_calculations.dart`) needs real unit
  test coverage: same date, yesterday/tomorrow, year-end rollover, leap
  years, DST transitions, cross-month/cross-year spans.
- Widget tests should stay targeted: empty list, event card rendering,
  add/edit flows, form validation — not exhaustive UI coverage.
- Native Swift tests (once the widget extension exists) should stay
  minimal — the widget only reads shared state, computes a display value,
  and renders SwiftUI/generates a timeline; don't rebuild the domain layer
  in Swift.

## Working with the plan

When picking up a task, identify which phase in [PROJECT_PLAN.md](PROJECT_PLAN.md) it
corresponds to, check that phase's success criterion, and stop there
rather than continuing into the next phase's scope. If a request
conflicts with the plan's explicit "out of scope for V1" list, flag it
rather than silently implementing it.
