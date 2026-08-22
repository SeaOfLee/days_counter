# Days Since — Project Plan

## Goal

Build a small iOS-first application for tracking the number of days since or until meaningful dates.

This is primarily a learning project, not a commercial product.

The project should provide practical exposure to:

- Flutter and Dart
- Modern Flutter state management
- Local persistence
- iOS development fundamentals
- Xcode
- Swift and SwiftUI
- WidgetKit
- App Groups
- Apple signing and provisioning
- App Store / TestFlight publishing later, if desired

The application should remain intentionally small and avoid unnecessary backend or product complexity.

---

## Product Scope

### MVP Features

- Create a date event
- Give the event a title
- Select a date
- Choose whether the event counts:
  - Since a date
  - Until a date
- Display the number of calendar days
- Edit an event
- Delete an event
- Persist events locally
- Choose one event to display in an iOS Home Screen widget
- Home Screen widget updates automatically as days pass

### Example Events

- Last Drink — 1,139 days
- Started New Job — 247 days
- Vacation — 18 days
- Anniversary — 42 days

### Explicitly Out of Scope for V1

- Backend services
- Authentication
- User accounts
- Firebase
- Analytics
- Push notifications (remote/APNs — *local* notifications are a
  different mechanism and are in scope as of Phase 26)
- Cloud sync
- Subscriptions
- In-app purchases
- Social features
- Calendar integration
- Android support
- CI/CD
- Complex theming
- Advanced architecture for hypothetical future requirements

---

# Technology Choices

## Main Application

Use:

- Flutter
- Dart
- Material 3
- VS Code

Flutter owns:

- Main application UI
- Navigation
- Form handling
- Domain model
- Date calculations
- Local persistence
- State management

## Native iOS Components

Use:

- Xcode
- Swift
- SwiftUI
- WidgetKit

Native iOS code owns:

- Home Screen widget
- Widget timeline updates
- Shared App Group access
- Widget configuration later

## Architecture Overview

```text
┌──────────────────────────────────────┐
│                iPhone                │
│                                      │
│   ┌──────────────────────────────┐   │
│   │ Flutter Application          │   │
│   │                              │   │
│   │ Event List                   │   │
│   │ Event Editor                 │   │
│   │ State Management             │   │
│   │ Local Repository             │   │
│   └──────────────┬───────────────┘   │
│                  │                   │
│            Shared App Group          │
│                  │                   │
│   ┌──────────────▼───────────────┐   │
│   │ WidgetKit Extension          │   │
│   │                              │   │
│   │ Swift                        │   │
│   │ SwiftUI                      │   │
│   │ TimelineProvider             │   │
│   └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

---

# How to Use This Plan

This file is the single source of truth for scope and phase sequencing.
[CLAUDE.md](CLAUDE.md) tracks which phase is currently in progress — check
there first before starting work.

- Work phases in order. Each phase has a **Success criterion**, and some
  have an explicit **Verify** command — don't move to the next phase until
  both are satisfied.
- Phases 0–19 are required for V1. Anything under a "Post-V1" heading
  (including the three post-V1 phases near the end) is optional and out of
  scope unless explicitly requested — don't treat their numbers as "do
  this next."
- Commit at the end of each phase with a message describing what was
  added (the phase title is usually a good commit message as-is).
- Don't restate this sequence elsewhere (e.g. a separate session log or
  milestone list) — a second copy of the task list will drift from this
  one. Update phases in place instead.

---

# Phase 0 — Development Environment

## Current Environment

Expected toolchain:

- Apple Silicon MacBook Air
- macOS
- Flutter stable
- Dart
- Xcode
- CocoaPods
- VS Code
- Flutter VS Code extension
- Dart VS Code extension

## Verify Environment

Run:

```bash
flutter doctor -v
```

Required for this project:

```text
[✓] Flutter
[✓] Xcode
[✓] CocoaPods
```

Android warnings can be ignored.

Launch an iOS simulator:

```bash
open -a Simulator
```

Check available Flutter targets:

```bash
flutter devices
```

Expected result should include an iPhone simulator.

---

# Phase 1 — Scaffold the Flutter Project

If the repository directory already exists, run from the repository root:

```bash
flutter create --project-name days_since .
```

Open the project:

```bash
code .
```

Run the generated Flutter app before making changes.

Either:

```bash
flutter run
```

or use VS Code:

```text
Run → Start Debugging
```

Success criterion:

The stock Flutter counter app runs in an iPhone simulator.

Commit this baseline.

Example:

```bash
git add .
git commit -m "Initialize Flutter application"
```

---

# Phase 2 — Build the Domain Model

Create the central application model.

Suggested model:

```dart
class DateEvent {
  final String id;
  final String title;
  final DateTime date;
  final CountDirection direction;
  final String? emoji;

  DateEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.direction,
    this.emoji,
  });
}

enum CountDirection {
  since,
  until,
}
```

Possible future fields:

```text
color
notes
createdAt
updatedAt
sortOrder
```

Do not add them until needed.

---

# Phase 3 — Implement Calendar-Day Calculations

Treat this as a calendar-date problem rather than an elapsed-duration problem.

Avoid using this directly as the canonical calculation:

```dart
target.difference(DateTime.now()).inDays
```

Normalize both dates first.

Example:

```dart
DateTime dateOnly(DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day,
  );
}
```

Then:

```dart
int differenceInCalendarDays(
  DateTime first,
  DateTime second,
) {
  return dateOnly(second)
      .difference(dateOnly(first))
      .inDays;
}
```

Create domain helpers for:

```text
days since
days until
display text
```

Example output:

```text
0 days
1 day
247 days
```

## Unit Tests

Test at minimum:

```text
same date → 0
yesterday → 1
tomorrow → 1
Dec 31 → Jan 1
leap year behavior
DST transition
dates in different months
dates in different years
```

Keep all date logic independent from UI code.

Success criterion:

Date calculations have unit tests and do not depend on Flutter widgets.

Verify:

```bash
flutter test
```

All date-calculation tests pass.

---

# Phase 4 — Build the First Flutter Screen

Replace the generated counter app with one hard-coded event.

Initial target:

```text
Days

Last Drink

1,139
days
```

Use this phase to learn core Flutter concepts:

- MaterialApp
- Scaffold
- StatelessWidget
- StatefulWidget
- BuildContext
- Row
- Column
- Padding
- Text
- Card
- ListView
- ThemeData

Do not add persistence yet.

## Suggested Initial Structure

```text
lib/
├── main.dart
├── app.dart
├── models/
│   └── date_event.dart
├── screens/
│   └── event_list_screen.dart
├── widgets/
│   └── event_card.dart
└── utils/
    └── date_calculations.dart
```

Keep architecture lightweight.

Avoid premature structures such as:

```text
domain/
application/
presentation/
infrastructure/
ports/
adapters/
usecases/
facades/
```

Success criterion:

A hard-coded event displays the correct number of days.

---

# Phase 5 — Display Multiple Events

Replace the single hard-coded event with a list.

Example:

```dart
final events = [
  DateEvent(...),
  DateEvent(...),
  DateEvent(...),
];
```

Render using:

```dart
ListView.builder(...)
```

Each event card should display:

```text
Title
Large number
days
since/until date
```

Possible layout:

```text
┌──────────────────────────────┐
│ Last Drink             1,139 │
│                         days │
└──────────────────────────────┘

┌──────────────────────────────┐
│ Japan Trip                43 │
│                    days ago │
└──────────────────────────────┘

┌──────────────────────────────┐
│ Vacation                  18 │
│                     days to │
└──────────────────────────────┘
```

Success criterion:

Multiple events render correctly from in-memory data.

---

# Phase 6 — Add Event Creation

Create a second screen for adding events.

Suggested form:

```text
Event Name
[ Last Drink                 ]

Date
[ June 19, 2023              ]

Count
[ Since ] [ Until ]

Icon
[ ☕ ]

[ Save ]
```

Use:

- TextEditingController
- Form
- TextFormField
- Date picker
- SegmentedButton or equivalent
- Navigator.push
- Navigator.pop

Validate:

- title is not blank
- date exists
- direction exists

Initial workflow:

```text
Tap +
↓
Open Event Editor
↓
Enter values
↓
Save
↓
Return DateEvent
↓
Add to in-memory list
```

Do not add a routing package yet.

Success criterion:

A new event can be added while the app is running.

---

# Phase 7 — Add Editing and Deletion

Editing:

```text
Tap event
↓
Open same Event Editor
↓
Prepopulate fields
↓
Save changes
```

Deletion options:

- Context menu
- Swipe action
- Delete button on edit screen

Keep one editor screen for both create and edit.

Success criterion:

Full in-memory CRUD works.

---

# Phase 8 — Introduce a Repository Boundary

Define persistence behind an interface.

Example:

```dart
abstract class EventRepository {
  Future<List<DateEvent>> getEvents();

  Future<void> saveEvent(DateEvent event);

  Future<void> deleteEvent(String id);
}
```

The UI should not know how events are stored.

Example implementation:

```dart
class LocalEventRepository
    implements EventRepository {
  // implementation
}
```

This gives a clean future seam for:

```text
local JSON
SQLite
CloudKit
Firebase
REST API
```

without building any of those now.

---

# Phase 9 — Add Local Persistence

For V1, use the simplest storage mechanism that remains understandable.

Possible choices:

1. JSON stored locally
2. SharedPreferences for small/simple data
3. Lightweight embedded database
4. SQLite later as a learning exercise

A simple JSON representation is sufficient:

```json
[
  {
    "id": "44d...",
    "title": "Last Drink",
    "date": "2023-06-19",
    "direction": "since",
    "emoji": "🍺"
  }
]
```

Add serialization methods to the model.

Example:

```dart
Map<String, dynamic> toJson()
```

and:

```dart
DateEvent.fromJson(...)
```

Success criterion:

Events survive a complete app restart.

---

# Phase 10 — Add State Management

Do not add state management until CRUD and persistence are working.

Start with:

```dart
setState(...)
```

Then refactor to Riverpod.

Target architecture:

```text
UI
 ↓
Riverpod Provider / Notifier
 ↓
EventRepository
 ↓
Local Persistence
```

Possible provider:

```dart
final eventRepositoryProvider =
    Provider<EventRepository>((ref) {
  return LocalEventRepository();
});
```

Possible state:

```dart
final eventsProvider =
    AsyncNotifierProvider<
      EventsNotifier,
      List<DateEvent>
    >(
      EventsNotifier.new,
    );
```

Use Riverpod for:

- loading events
- adding events
- updating events
- deleting events
- notifying screens of changes

Success criterion:

UI no longer manually coordinates repository state.

Verify:

```bash
flutter test
flutter analyze
```

Existing tests still pass and no new lint/analysis errors are introduced by the provider refactor.

---

# Phase 11 — Basic UI Polish

Keep this intentionally restrained.

Add:

- App title
- Empty state
- Floating Add button
- Consistent spacing
- Large day count typography
- Secondary date label
- Optional emoji/icon
- Light and dark mode compatibility

Potential card design:

```text
┌────────────────────────────────┐
│ 🍺 Last Drink                  │
│                                │
│ 1,139                          │
│ days                           │
│ Since June 19, 2023            │
└────────────────────────────────┘
```

Do not spend substantial time on branding.

---

# Phase 12 — Run on a Physical iPhone

Connect the iPhone to the Mac.

Open:

```text
ios/Runner.xcworkspace
```

in Xcode.

Configure:

```text
Runner
→ Signing & Capabilities
→ Team
→ Apple ID development team
```

Run the Flutter app on the physical iPhone.

Learn the following concepts during this phase:

- Bundle Identifier
- Development Team
- Signing Certificate
- Provisioning Profile
- Device registration
- Entitlements

Success criterion:

The Flutter app launches on a real iPhone.

---

# Phase 13 — Add the WidgetKit Extension

Only start this after the main Flutter application works.

Open the iOS project in Xcode.

Add:

```text
File
→ New
→ Target
→ Widget Extension
```

Name:

```text
DaysSinceWidget
```

The widget will use:

- Swift
- SwiftUI
- WidgetKit

Initial widget should be static.

Example:

```swift
struct DaysSinceWidgetEntryView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last Drink")

            Text("1,139")
                .font(.largeTitle)

            Text("days")
        }
    }
}
```

Success criterion:

A hard-coded widget can be added to the iPhone Home Screen.

---

# Phase 14 — Learn WidgetKit Timeline Behavior

Widgets are not continuously running miniature apps.

WidgetKit requests timeline entries.

Relevant concepts:

- TimelineEntry
- TimelineProvider
- StaticConfiguration
- Widget
- WidgetFamily

For this application, values only change once per calendar day.

Conceptual timeline:

```text
Aug 1 00:00 → 1,139
Aug 2 00:00 → 1,140
Aug 3 00:00 → 1,141
Aug 4 00:00 → 1,142
```

Generate future timeline entries and allow WidgetKit to refresh appropriately.

Success criterion:

Hard-coded widget value updates automatically on successive days.

---

# Phase 15 — Configure an App Group

The Flutter host application and widget extension live in separate sandboxes.

Create a shared App Group.

Example:

```text
group.com.example.dayssince
```

Enable it for:

```text
Runner
DaysSinceWidget
```

Learn:

- Capabilities
- Entitlements
- App Groups
- Shared UserDefaults

Success criterion:

Both app targets can read/write the same App Group data.

---

# Phase 16 — Share Widget Data from Flutter

Do not have WidgetKit attempt to directly use the Flutter persistence mechanism.

Instead, treat shared widget data as a small projection/cache.

Architecture:

```text
Flutter database
      ↓
selected widget event
      ↓
serialize widget payload
      ↓
App Group storage
      ↓
WidgetKit
```

Shared payload example:

```json
{
  "id": "44d...",
  "title": "Last Drink",
  "date": "2023-06-19",
  "direction": "since"
}
```

The Flutter app writes the payload whenever:

- selected widget event changes
- event title changes
- event date changes
- event direction changes
- selected event is deleted

Success criterion:

The widget renders an event created inside Flutter.

---

# Phase 17 — Request Widget Refreshes

After the Flutter app writes new shared data:

```text
Edit event
↓
Persist event
↓
Update App Group data
↓
Request WidgetKit timeline reload
↓
Widget refreshes
```

Implement the minimum native bridge required to call WidgetKit refresh APIs.

Keep this bridge deliberately tiny.

Success criterion:

Editing an event in Flutter causes the Home Screen widget to refresh.

---

# Phase 18 — Add a Featured Widget Event Setting

> **Superseded by Phase 21.** This phase shipped in V1 and is kept as
> history. Phase 21 replaces it with per-instance widget configuration
> through App Intents, which makes a single globally featured event
> redundant — the setting, its storage, and its screen are deleted there.
> Don't build on this phase's featured-event API.

Before building native widget configuration, support one globally selected widget event inside the Flutter app.

Example setting:

```text
Featured Widget Event

[ Last Drink              > ]
```

Store the selected event ID.

Only that event is projected into the App Group.

This keeps V1 widget behavior simple.

Success criterion:

User can select which event appears in the widget from inside the Flutter app.

---

# Phase 19 — Add Widget Sizes

Start with:

```text
systemSmall
```

Example:

```text
┌─────────────────────┐
│ Last Drink          │
│                     │
│ 1,139               │
│ days                │
└─────────────────────┘
```

Then add:

```text
systemMedium
```

Example:

```text
┌──────────────────────────────────┐
│ Last Drink                 1,139 │
│                              days│
└──────────────────────────────────┘
```

Do not support every possible widget family initially.

Success criterion:

Small and medium widgets display cleanly.

---

# Testing Guidelines (cross-cutting)

This is not a phase to do at the end — it applies throughout Phases 0–19.
Several phases already call out their own tests (e.g. Phase 3); this
section is the standing coverage bar for the whole V1 build, and a good
thing to re-check whenever a phase's Verify step doesn't already cover it.

## Dart Unit Tests

Domain logic should have strong coverage.

Test:

- date normalization
- days since
- days until
- leap years
- year boundaries
- DST boundaries
- serialization
- repository behavior

## Flutter Widget Tests

Test critical UI behavior:

- empty event list
- event card rendering
- adding an event
- editing an event
- form validation

Keep these targeted.

## Swift Tests

Keep native tests limited.

Native code should mainly:

```text
read shared state
calculate display value
render SwiftUI
generate timeline
```

Do not duplicate a large domain layer in Swift.

---

# Suggested Repository Structure

Eventually:

```text
days-since/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── models/
│   │   └── date_event.dart
│   │
│   ├── repositories/
│   │   ├── event_repository.dart
│   │   └── local_event_repository.dart
│   │
│   ├── providers/
│   │   └── events_provider.dart
│   │
│   ├── screens/
│   │   ├── event_list_screen.dart
│   │   └── event_edit_screen.dart
│   │
│   ├── widgets/
│   │   └── event_card.dart
│   │
│   └── utils/
│       └── date_calculations.dart
│
├── ios/
│   ├── Runner/
│   └── DaysSinceWidget/
│
├── test/
│   ├── date_calculations_test.dart
│   └── ...
│
├── pubspec.yaml
├── README.md
└── PROJECT_PLAN.md
```

Allow the exact layout to evolve naturally.

---

# Suggested Session Pacing

A rough guide to grouping phases into sittings. Not a hard boundary —
stop earlier if a phase needs more iteration, or combine phases if time
allows. This table is pacing guidance only; the phases above remain the
one authoritative task list.

| Session | Phases | Focus |
|---|---|---|
| 1 | 0–4 | Environment, scaffold, domain model, date math, first screen |
| 2 | 5–7 | Multiple events, create/edit/delete |
| 3 | 8–9 | Repository boundary, local persistence |
| 4 | 10 | Riverpod state management |
| 5 | 11–13 | UI polish, physical device, WidgetKit extension |
| 6 | 14–17 | Timeline behavior, App Group, shared data, refresh |
| 7 | 18–19 | Featured event setting, widget sizes |

---

# V1 Definition of Done

The project reaches V1 when:

- App runs on a physical iPhone
- User can create events
- User can edit events
- User can delete events
- User can count since a date
- User can count until a date
- Events survive application restart
- User can choose a featured event
- Home Screen widget displays that event
- Widget updates as calendar days change
- Editing the event refreshes the widget
- No backend is required

---

# Post-V1 Phases (optional)

Not required for V1. Numbered for reference back to earlier drafts of
this plan, not as a continuation of the Phase 0–19 sequence — don't start
these until the V1 Definition of Done above is met, and only if desired.
Phase 20 is the exception: pursue it once explicitly requested, ahead
of Phases 21–22, since it's about shipping what already exists rather
than an optional additional learning exercise.

Phase 20 is now done (the app shipped at 1.0.1). Phases 21 and 23–25
were explicitly requested and are all done. **Phase 26 (Milestone
Moments) is the active next phase** — also explicitly requested, and real
upcoming work rather than a hypothetical exercise. Phase 22 (Lock Screen
Widgets) remains genuinely optional and unrequested — its number places
it before 23–26 but its priority does not.

## Phase 20 — Prepare for App Store Submission

The app itself needs no new functionality for this phase — App Store
submission is almost entirely account, asset, and metadata work, not
code. This project has an easier path than most: no backend, no
accounts, and no data collection to disclose.

### Apple Developer Program

Enroll in the paid Apple Developer Program ($99/year) at
developer.apple.com, if not already enrolled. The free personal team
used for device testing so far can only run builds on your own
registered devices — App Store distribution requires a paid
membership. Enrollment can take a day or so to process.

### Bundle Identifier

Replace the placeholder bundle identifier (`com.example.daysCounter`)
with one you actually own, e.g. `com.<yourname>.dayscounter`. Register
it as a new App ID in the Apple Developer portal, or let Xcode's
automatic signing create it once the bundle ID is changed in
Signing & Capabilities.

### App Icon

Replace the default Flutter template icon
(`ios/Runner/Assets.xcassets/AppIcon.appiconset`) with a real design.
Xcode's single-size App Icon asset (1024×1024) generates the rest.

### App Store Connect

Create the app record at appstoreconnect.apple.com:

```text
App name
Category
Age rating questionnaire
Privacy policy URL (required even though this app collects nothing)
App Privacy "nutrition label" (straightforward here — no networking,
  accounts, or analytics to disclose)
Screenshots (at least one device size)
```

### Signing for Release

Switch from the Development signing certificate/provisioning profile
used for device testing to a Distribution certificate and App Store
provisioning profile. Xcode's automatic signing handles most of this
once the paid membership is active.

### Archive and Submit

```text
Xcode
→ Product
→ Archive
→ Validate App
→ Distribute App
→ App Store Connect
```

Fill in release notes in App Store Connect, then submit for review.
Typical review turnaround is 1–2 days, though this varies.

The same uploaded build can also be distributed via TestFlight to
testers before (or instead of) a public App Store release, if desired.

Success criterion:

The app is submitted for App Store review. (Approval or rejection is
Apple's call, not something to engineer around here.)

## Phase 21 — Configurable Widgets

Allow multiple widget instances, each configured for a different event,
using modern WidgetKit configuration through App Intents.

**This phase is also the "swipe through multiple events" feature.**
WidgetKit has no swipe or pan gesture API — widgets are archived SwiftUI
views rendered out of process, and only tap targets (`Link`, and on
iOS 17+ `Button`/`Toggle` bound to an App Intent) reach the widget at
all. The swiping people picture is the OS-level **widget stack**: drag
one widget onto another and iOS provides the gesture, exactly as it does
between Photos and Calendar in a stock stack. All this app has to supply
is per-instance configuration so that two stacked Dayward widgets show
two different events instead of the same one. That is this phase.

It also **retires the featured-event concept from Phase 18**. Once each
widget instance chooses its own event, a single globally featured event
is redundant, so the setting and its storage are deleted rather than
kept as a fallback.

Desired UX:

```text
Long press widget
↓
Edit Widget
↓
Select Event
↓
Last Drink
Vacation
Anniversary
...
```

**Phase 21 is done.** Verified on a physical iPhone: two widgets configured
to different events, stacked, swiping between them shows each event's own
count. The notes below are kept as the record of how it was approached and
what the traps were.

### 21a — Build-system spike (do this first)

**Outcome: the cycle is gone.** Enabling extraction on the widget
extension's three configs only — step 1 of the ladder below — built clean,
so Runner's three flags and the build phase order were never touched. Four
builds confirmed it: `xcodebuild` Debug for simulator, `xcodebuild` Release
for device, `flutter build ios --simulator --debug`, and
`flutter build ios --release --no-codesign`. The emitted
`Metadata.appintents/extract.actionsdata` really did contain
`SelectEventIntent` and `EventEntity`, ruling out a green build from
extraction silently no-op'ing.

**Correction to the build loop below:** Release *cannot* be checked against
a simulator at all, regardless of App Intents — Flutter fails it with
"release/profile builds are only supported for physical devices". Use
`-destination 'generic/platform=iOS'` with `CODE_SIGNING_ALLOWED=NO`;
cycle detection happens at build-planning time, so signing is irrelevant.

`ENABLE_APP_INTENTS_METADATA_EXTRACTION = NO` is currently set on every
build configuration of both Runner and DaysCounterWidgetExtension. That
was the workaround for the Xcode 26 build cycle between
`ExtractAppIntentsMetadata` and Flutter's "Thin Binary" script phase (see
CLAUDE.md). App Intents needs that extraction turned back on, so this
phase reopens a bug that was previously worked around. The other half of
the original fix is still in place — Runner's "Embed Foundation
Extensions" phase runs before "Thin Binary" — so it may now build
cleanly.

**Flipping the flag alone is a false negative.** With extraction enabled
but no App Intents symbols in the target, `ExtractAppIntentsMetadata` has
nothing to do and may never create the task edges that cycle. The spike
must include a real intent — roughly thirty lines: an `AppEntity` with a
hardcoded `suggestedEntities()`, a `WidgetConfigurationIntent`, and
`Provider`/`StaticConfiguration` switched to their App Intent
equivalents. Do it on a throwaway branch.

The cycle error is emitted by the build planner *before* compilation, so
it fails in seconds:

```bash
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' build
```

Then confirm with a real `flutter build ios --simulator --debug`, which
also drives Flutter's script phases. **Test Debug and Release both** —
this cycle has been configuration-sensitive, and Release is what ships.

Try, cheapest first:

1. Extraction `YES` on **the widget extension's three configs only**,
   Runner's three left at `NO`. The intent types are referenced only by
   the extension, and "Thin Binary" is a Runner phase, so this is the
   variant least likely to reintroduce the cycle.
2. Move "Embed Foundation Extensions" back *after* "Thin Binary" — the
   Phase 13 reorder may be the cause now that extraction is on, so the
   old fix is worth explicitly un-applying as an experiment.
3. Extraction `YES` on both targets.

Do **not** remove Flutter's `Info.plist` input path from the Thin Binary
phase to work around this. `flutter_tools`'
`xcode_thin_binary_build_phase_input_paths_migration.dart` re-adds it on
every build, guarding a separate Bonjour/mDNS bug.

If none of those work, the options get materially worse and are a
decision to make with the user rather than silently:

- A legacy `IntentConfiguration` with a SiriKit `.intentdefinition`
  avoids App Intents metadata entirely, but dynamic options for a widget
  config INIntent need a **separate Intents extension target** — a third
  target, entitlement, and bundle id. For a learning project that may be
  worse than not doing it.
- Re-scope to a single widget that auto-rotates through events on its
  timeline. That delivers "multiple events on the Home Screen" without
  App Intents, but it does **not** satisfy this phase's success
  criterion, and it gives up the swipe-a-stack interaction entirely. A
  deliberate scope cut, not a fix.

Evaluate the spike before writing any real intent code.

### 21b — Publish all events to the App Group

The widget currently receives exactly one event: `WidgetBridge` sends a
single `jsonEncode(event.toJson())` string and `AppDelegate` stores it
under `featuredEventPayload`. An `EntityQuery` needs the whole list.

- `lib/services/widget_bridge.dart`: replace
  `updateFeaturedEvent(DateEvent?)` with `updateEvents(List<DateEvent>)`,
  encoding the full array. Keep the `MissingPluginException` catch — it
  is what lets the non-iOS test run.
  **Always send a string, never `null`** — an empty list becomes `"[]"`.
  This is load-bearing: it lets the widget distinguish "the user has zero
  events" from "never synced", and it removes the `removeObject` branch
  from the native handler. Send a bare JSON array, the same shape
  `events.json` already holds; a version envelope buys nothing until
  there's a second consumer.
- `ios/Runner/AppDelegate.swift`: rename the method case to
  `updateEvents`, write under a new `eventsPayload` key, and clear the
  stale `featuredEventPayload` key so upgraded installs don't leave a
  dead single-event blob behind. Keep the
  `WidgetCenter.shared.reloadAllTimelines()` call.
- `lib/providers/events_provider.dart`: `_syncFeaturedEventToWidget`
  becomes `_syncEventsToWidget(events)`, forwarding the list. It must
  stay **awaited**, for the reason already documented there: the app can
  be backgrounded moments after an edit, and an un-awaited
  platform-channel call can be cut off mid-write.

This also removes the two-way provider dependency where `EventsNotifier`
read `featuredEventIdProvider` while `FeaturedEventIdNotifier` read
`eventsProvider`.

Array order is the contract — `events.json` is persisted in list order,
so the payload order is the user's order, and Phase 24's drag reorder
will flow into the widget's event picker without extra work.

### 21c — Entity, query, intent, provider

`ios/DaysCounterWidget/` is a file-system-synchronized group in the Xcode
project, with `Info.plist` as its only membership exception. New `.swift`
files placed in that directory join the widget extension target
automatically — no Xcode GUI work and no `project.pbxproj` editing.
Prefer new files over growing the existing one:

- `WidgetEventStore.swift` — rename `FeaturedEvent` to `WidgetEvent`,
  replace `loadFeaturedEvent()` with `loadEvents() -> [WidgetEvent]`
  decoding an array from `eventsPayload` and returning `[]` on any
  failure. The UTC-normalized `dayCount(for:on:)` and `dateLine(for:)`
  helpers move here unchanged — they mirror
  `lib/utils/date_calculations.dart` and must keep doing so. Also factor
  the emoji-plus-title join (currently inline in `currentEntry`) into a
  `displayTitle` property, since the picker needs it too.
  **Gotcha:** these helpers are currently `private` at file scope, which
  in Swift means file-private. Moving them to a new file requires
  dropping the `private` keyword — both files are in the same module, so
  the default `internal` is what's wanted.
- `SelectEventIntent.swift` — entity, query, and intent together; they
  total about forty lines and splitting them three ways would be
  over-decomposition. The `AppEntity`'s `id` matches `DateEvent.id`, with
  a `displayRepresentation` built from `displayTitle` and a
  `static var defaultQuery`. Use a plain `EntityQuery` implementing
  `entities(for:)` and `suggestedEntities()` — the picker list is
  populated by `suggestedEntities()`, so it has to return a non-empty
  result. Not `EntityStringQuery`, which exists for Siri free-text
  matching this doesn't need, and not `DynamicOptionsProvider`, which is
  for plain-typed `@Parameter` option lists rather than entity pickers.

  Two details that matter: the `@Parameter` must be **optional**
  (`var event: EventEntity?`) — a non-optional parameter changes how iOS
  treats already-placed widgets, and optionality is what produces the
  "needs configuration" state for free. And both query methods must read
  `loadEvents()` fresh on every call rather than caching, so a renamed
  event shows its new title and a deleted event resolves to nothing.
- `DaysCounterWidget.swift` — `Provider` moves from `TimelineProvider` to
  `AppIntentTimelineProvider`. Note the shape change, which is easy to
  get wrong: `getSnapshot`/`getTimeline` become `snapshot(for:in:)` /
  `timeline(for:in:)`, they take the configuration, and they are `async`
  functions **returning** values rather than calling a completion
  handler. The 7-day entry generation and `.atEnd` reload policy carry
  over unchanged; only the event lookup changes, from "the one featured
  event" to "the id carried on the configuration intent".

  Watch `snapshot(for:in:)`: when the user browses the widget gallery
  the configuration is empty, so a naive implementation previews the
  "choose an event" prompt — a poor first impression. Branch on
  `context.isPreview` and show real data if any exists.
- `StaticConfiguration` becomes
  `AppIntentConfiguration(kind:intent:provider:)`. **Keep `kind` as
  `"DaysCounterWidget"`** so already-placed widgets survive the change.
  `configurationDisplayName`, `description`, and `supportedFamilies` stay
  as they are.

`AppIntentTimelineProvider` requires iOS 17+; the widget extension's
deployment target is well above that, so the new code needs no
availability guards.

### 21d — Three entry states

There are three states to render:

| State | When | Renders |
|---|---|---|
| Configured | the intent carries an event id that resolves | today's layout |
| Needs configuration | the intent's event is nil (a widget placed before this update), or its id no longer resolves because the event was deleted | a prompt to choose an event |
| No events | the shared list is empty | "Add an event" (today's copy) |

Prompting is a deliberate choice over silently falling back to the first
event — a widget confidently showing the wrong event is worse than one
that says what to do.

**Keep `SimpleEntry` as it is** (`date`, `title`, `dayCount`,
`dateLine`). The existing views already render "title only, no count"
when `dayCount == nil`, which is exactly what both empty states need, so
an explicit state enum would add a type for zero behavior change —
against guiding principle 6. Order the checks so the empty list wins:
test `events.isEmpty` first, then the configuration lookup.

Two view changes are genuinely required:

- Both layouts set `.lineLimit(1)` on the title at `.subheadline` size,
  so "Long press to choose an event" would render as `Long press to c…`
  in `systemSmall`. Shorten the copy — "Choose an event" matches "Add an
  event" in register and length — **and** relax the limit when there's no
  count (`entry.dayCount == nil ? 3 : 1`), since the title is then the
  only content on the tile.
- Give the no-count title the primary text color rather than the muted
  one. Muted is meant for a label sitting above a big number; as the sole
  content it reads like a rendering bug. This applies to today's "Add an
  event" state too, so it's an inherited polish fix.

Add `#Preview`s for all three states at both families — Xcode Previews
render without booting a simulator and are the fastest way to check the
truncation fix.

Optional, and the best UX-per-line in this phase: `AppIntentConfiguration`
supports `recommendations()`, returning one `AppIntentRecommendation` per
event so the widget gallery offers a preconfigured tile per event and the
user picks the right one at add time instead of adding then configuring.
About eight lines over `loadEvents()`.

### 21e — Delete the featured-event concept

Do this only after 21b–21d work, so there is never a window with no way
to choose an event.

Delete outright: `lib/providers/featured_event_provider.dart` (including
`selectFeaturedEvent()`) and `lib/screens/featured_event_screen.dart`.

Edit: `event_repository.dart` and `local_event_repository.dart` (drop
`get`/`setFeaturedEventId` and the `featured_event_id.txt` handling),
`events_provider.dart`, `widget_bridge.dart`,
`event_list_screen.dart` (remove the `Icons.widgets_outlined` app bar
action — this frees the app bar's only slot, which Phase 24 can reuse),
and `test/fakes/in_memory_event_repository.dart`.

`featured_event_id.txt` is left orphaned on existing installs. That's
acceptable; don't write migration code for a file nothing reads any more.

`test/fakes/widget_bridge_mock.dart` keeps the same channel name and must
still be registered in every widget test's `setUp` — without it
`pumpAndSettle()` hangs forever on the unmocked channel instead of
throwing. It currently discards `call.arguments`; extend it to capture
them so a test can assert the full event array reaches the bridge.

### 21f — Migration notes

Widgets placed by 1.0.1 users carry no intent configuration. With `kind`
unchanged they should survive the update and land in the "needs
configuration" state until long-pressed. That is intended behavior, not a
bug. It is also the single biggest assumption in this phase that no build
can check — verify it by installing the shipped 1.0.1 build on a device,
placing a widget, then installing the new build over it. If iOS drops
them anyway there is no code fix, only a release note.

**The stale-payload window.** After updating, `eventsPayload` does not
exist until the user launches the app once, because that is when
`EventsNotifier.build()` runs the sync. If WidgetKit refreshes before
that first launch, a user with four events briefly sees "Add an event" —
alarming and wrong. Accepting this is reasonable: the window closes
permanently on any app launch, and the user has to open the app or
long-press the widget to configure it regardless. The alternative is to
have `loadEvents()` fall back to decoding the old `featuredEventPayload`
as a single-element list, which costs a handful of lines of legacy code
in the file this phase is trying to clean up, and conflicts with clearing
that key. Prefer accepting the window; record the choice.

The app is already on the App Store, so this removes a working V1 feature
from users' hands — worth a release note.

### 21g — What can be verified where

`flutter analyze` catches the whole deletion sweep — dangling imports,
the test fake no longer satisfying `EventRepository`, any surviving
reference to the featured API. Run it the moment the deletions land.

`flutter test` covers the payload. Extend `widget_bridge_mock.dart` with
a recording variant that captures the method and arguments (keep the
existing no-op for tests that don't care) and assert: `build()` sends
`updateEvents` with ids in list order — nothing in the suite guards that
invariant today; a save appends; a delete removes; and an empty
repository yields `'[]'` rather than `null`, pinning the decision the
Swift empty-state logic depends on.

**Correction (2026-08-22): widget configuration does not work on the
simulator.** This section originally claimed the Edit Widget picker,
placing two configured widgets, and delete/rename propagation were all
simulator-checkable. They are not, at least on the iOS 26.5 runtime. A
widget added there lands in "Choose an event" and *stays* there after an
event is picked: the picker populates, the selection is accepted, and the
intent never attaches — chronod logs the widget descriptor with a null
intent reference and never attempts to resolve `SelectEventIntent`.

It is an environment fault, not a code one. `Metadata.appintents/
extract.actionsdata` in the built extension is complete and correct, and
Apple's own bundled sample widgets fail identically on the same runtime
(`LNMetadataProviderErrorDomain Code=9000 "aggregateMetadataIsEmpty"` for
`com.apple.AdaptiveMusicApp`). The same build configures correctly on a
physical iPhone. Do not spend time debugging app code when this appears —
go straight to a device.

The build cycle itself is still simulator-checkable, as is anything that
doesn't depend on the intent resolving: the app's own UI, the App Group
payload, and the widget's empty states.

Genuinely device-only, then: **anything involving widget configuration**,
**upgrade-in-place from the shipped 1.0.1**, which cannot be installed on
a simulator, and the stack behavior itself — stack creation by dragging
one widget onto another, the swipe feel, and Smart Rotate. Widget placement needs interactive long-press UI that previous
sessions could not automate, so budget for a hands-on pass.

Do the work in an order that fails fast: spike, then the Swift skeleton
against an empty payload, then the Flutter bridge (first end-to-end
moment), then the deletion sweep, then tests. Deleting last means a
broken build is unambiguously the deletion's fault rather than the
feature's.

Success criterion:

Two Dayward widgets are placed, configured to different events via Edit
Widget, and stacked — swiping the stack moves between them, each showing
its own correct day count. **Met.**

### 21h — Stacking, for the record

Stacking is pure OS behavior, but two details are easy to trip on and
neither is discoverable: **both widgets must be the same family** (small
onto small, medium onto medium) or iOS silently refuses the drop, and
**Edit Widget on a stack edits whichever widget is currently visible**, not
the stack. Long-press the stack → Edit Stack also exposes Smart Rotate and
Widget Suggestions, both on by default; for day counters they add noise and
are worth turning off. A stack holds up to 10 widgets, so one stack can
carry a whole set of events.

## Phase 22 — Lock Screen Widgets

Explore:

- accessoryCircular
- accessoryRectangular
- accessoryInline

Example:

```text
1,139 days
Last Drink
```

A useful additional WidgetKit learning exercise but not required.

## Phase 23 — Dark-Mode Readability on the Event Editor

**Done.** All fixes landed in `lib/theme/app_theme.dart` and
`lib/theme/app_colors.dart`; the editor itself was not touched, which was
the point.

Two findings worth keeping. First, the root cause was broader than "some
colors are dim": `ColorScheme.copyWith` was overriding `primary` and
`surface` without their `on*` counterparts, so those foregrounds stayed at
whatever `fromSeed` derived for *its* palette. Every overridden role is now
paired. Second, the accent turned out to be the real offender — white text
on `#B49CE8` measures about **2.4:1**, so the selected segment label and the
FAB's "+" both failed badly. A new `onAccent` ink (~7:1) replaces white on
every accent surface. That last change is visible outside the editor, on the
FAB.

Measured pairs that were failing, now fixed: form labels on the input fill
were ~4.1:1 dark and ~3.1:1 light (new `textLabel`/`textLabelDark` tokens
bring both above 4.5:1); `bodyLarge` — what `TextField` input text actually
resolves to — was never defined at all and fell back to a Material default.

The original problem statement follows.

The New/Edit Event screen is hard to read in dark mode. Nothing in
`lib/screens/event_edit_screen.dart` sets colors or text styles of its
own, so every cause lives in `lib/theme/app_theme.dart`:

- `ColorScheme.copyWith` overrides colors without their paired `on*`
  roles. Both themes override `primary`, `secondary`, `surface`,
  `onSurface`, and `onSurfaceVariant`, but leave `onPrimary`,
  `onSecondary`, the container roles, and the error roles at values
  `ColorScheme.fromSeed` derived for its own generated palette rather
  than the lavender one. Anything Material draws from those pairs is
  unaudited.
- There is no `DatePickerThemeData` at all, so the stock `showDatePicker`
  dialog renders entirely from those seed-derived roles.
- `bodyLarge` is never defined. The theme sets only `displayMedium`,
  `titleLarge`, `titleMedium`, and `bodyMedium`, but `TextField` input
  text and the `InputDecorator`'s child `Text` both resolve to
  `bodyLarge` — i.e. a Material default, not the app's palette.
- Input labels use the muted color on the dark input fill, a low-contrast
  pairing.
- Unselected segmented-button segments use the muted foreground on the
  card color, and the control sits directly on the scaffold background
  with no border — so the unselected half reads as empty space rather
  than a button.
- Error states are unthemed: no `errorBorder`, `focusedErrorBorder`, or
  `errorStyle`, so validation messages fall back to default error colors
  against the app's fill.
- Also absent: `textSelectionTheme` (cursor and selection handles),
  `iconTheme`, `dividerTheme`.

The work is confined to `app_theme.dart`. Its `_themeFrom` helper already
takes `foreground`, `muted`, `inputFill`, and `cardColor` parameters, so
fixes stay parameterized across light and dark rather than being branched
per theme. Complete the `ColorScheme` overrides, add
`DatePickerThemeData`, define `bodyLarge`, raise label contrast, theme
the error states, give `SegmentedButton` a visible boundary, and add
`textSelectionTheme`.

Resist adding per-screen color overrides in the editor — keeping the fix
in the theme means the list and any future screens inherit it too.

Success criterion:

Every control on the New/Edit Event screen — labels, input text, both
segmented-button halves, the date picker dialog, and validation errors —
is legible in dark mode, with text meeting 4.5:1 contrast.

Verify:

```bash
flutter test
flutter analyze
```

Plus a manual dark-mode pass through create → validate empty → pick date
→ save.

## Phase 24 — Drag and Drop Reordering

**Done.** Long press a card to pick it up and drag; tap still opens the
editor, so no explicit reorder mode or app bar toggle was needed — the
freed app bar slot from Phase 21 stayed free.

Two details worth knowing. `ReorderableListView`'s `onReorder` is
**deprecated** in favour of `onReorderItem`, which adjusts `newIndex` for
the removed item itself — using it means no off-by-one fixup when dragging
downwards, which is the classic bug here. And the default `proxyDecorator`
wraps the dragged item in an elevated `Material`, painting a rectangle
behind the card's rounded corners; a transparent decorator keeps the card
looking like a card while dragged.

`reorderEvents` takes ids rather than the reordered list, and any id the
caller doesn't name keeps its relative position at the end — a stale id
list can reorder but never silently drop events.

Let the user drag event cards into whatever order they want.

Ordering is already nothing more than array position in `events.json` —
the repository rewrites the whole array on every change and nothing
anywhere sorts. **So this needs no `sortOrder` field**, and guiding
principle 2 (keep the domain model small) holds.

What it does need:

- A bulk-order method on `EventRepository`, e.g.
  `reorderEvents(List<String> orderedIds)`. This is unavoidable:
  `getEvents()` returns an unmodifiable list and `saveEvent` only appends
  or replaces in place, so there is currently no way to express a new
  order at all.
- The same method on `LocalEventRepository` (reorder the cached list,
  then persist) and on the in-memory test fake. Note the fake holds its
  seed list directly, so a test passing a `const` seed would yield an
  immutable list — have it copy into a growable one.
- A `reorderEvents` method on `EventsNotifier`, following the pattern the
  other mutations already use: write to the repository, re-read events,
  replace state.
- `ListView.builder` becomes `ReorderableListView.builder` in
  `event_list_screen.dart`. Items carry no keys today; `EventCard`
  already accepts `super.key`, so callers pass `ValueKey(event.id)`. The
  per-item bottom padding has to move inside the keyed child.
- A decision on the drag affordance: long-press (the mobile default)
  versus an explicit reorder mode toggled from the app bar. Phase 21
  frees the app bar's only action slot by removing the featured-event
  button, so a toggle has somewhere to live.

Card tints are safe — `EventCard` keys its background color off
`event.id.hashCode`, not the list index, so reordering won't shuffle
colors.

One ordering caveat: `selectFeaturedEvent()` currently falls back to the
first event, which means reordering would silently change what the widget
displays for anyone who never picked a featured event. Phase 21 deletes
that fallback and removes the hazard. If this phase is done *before*
Phase 21, reordering must also trigger the widget sync.

Success criterion:

Events can be dragged into a new order, and that order survives an app
restart.

Verify:

```bash
flutter test
```

With a new repository test asserting order persists across a fresh
repository instance over the same directory — the existing suite has no
ordering test — plus a widget test driving a drag.

## Phase 25 — Relative Day Entry

**Done**, and it grew one unplanned change: **the Since/Until toggle was
removed.** Direction is now inferred on save — a future date counts down,
anything else counts up — because once the date is chosen, asking which way
to count is redundant.

`CountDirection` and `DateEvent.direction` **stay**, computed rather than
asked for. That keeps the model, JSON, App Group payload, and the Swift
widget's `dayCount(for:on:)` untouched, and leaves a seam if an explicit
override is ever wanted. Dropping the field outright would have been a
cross-target change for no user-visible gain.

Two consequences worth knowing:

- An `until` event whose date has already passed used to keep rendering a
  negative count (`formatDayCount` preserves the minus sign deliberately).
  It now becomes a `since` event the next time it is saved.
- Today is ambiguous — 0 days either way — and falls to `since`.

Inference removed the toggle that "in days" mode needed for its own
direction, so that mode has an **Ago / From now** control instead. The
offset is never stored: it resolves to a date immediately, so nothing
downstream knows it was used.

Let the user enter a date as "N days from today" instead of picking one
off a calendar, e.g. counting down to a 100-day mark.

This is an **input convenience only**. The app computes the resulting
date and stores it exactly as it stores any other date. `DateEvent` gains
no field, serialization is unchanged, the App Group payload is unchanged,
and no Swift code is touched — guiding principle 2 again.

Work:

- Add a helper to `lib/utils/date_calculations.dart` for "the date N days
  from a reference date", with an injectable `now` matching the existing
  `daysSince`/`daysUntil` signatures. Build it as
  `DateTime(now.year, now.month, now.day + n)` rather than adding a
  `Duration` — Dart normalizes the overflowing day field correctly,
  whereas `Duration(days: n)` reintroduces exactly the DST skew this file
  exists to avoid.
- In `event_edit_screen.dart`, add a mode switch above the date field. In
  offset mode, show a numeric field and a live preview of the computed
  date using the existing `formatDate`. `_save` already just reads
  `_date`, so it needs no restructuring — offset mode simply sets it.
- Make the interaction with direction explicit in the UI: with `until`
  the offset means N days ahead, with `since` it means N days back.

Success criterion:

Entering "100 days" with direction Until creates an event dated 100 days
from today, whose card immediately reads 100 days.

Verify:

```bash
flutter test
```

Unit tests for the new helper covering a DST boundary and month/year
rollover, matching the existing style in
`test/date_calculations_test.dart`, plus a widget test creating an event
through offset mode.

---

## Phase 26 — Milestone Moments

Acknowledge the days that matter: the day a countdown finally arrives, and
the round-number milestones a count-up passes on its way (100 days, 365
days, 1,000 days). The widget and the in-app card change their appearance
on those days, and an optional local notification announces them.

**Why these are one phase, not two.** "Today is the day" and "today is a
milestone" are the same predicate over the same number. The widget renders
it, the notification announces it, and the card mirrors it. Split across
two phases, the rule for what counts as a milestone gets written twice and
the two copies drift.

The notification half is also what makes the widget half worth building.
Nobody watches a widget waiting for midnight — a local notification is the
only way this app can reach the user without them going looking.

### The plan's "no push notifications" line

The Explicitly Out of Scope for V1 list rules out push notifications, and
that still holds: no APNs, no device tokens, no server, no push
entitlement. **Local notifications are a different mechanism** —
`UNUserNotificationCenter` schedules them on-device, and nothing leaves
the phone. That list has been amended to say so rather than leaving the
two to blur together.

Nothing about this phase changes the App Privacy questionnaire answers
("Data Not Collected" stays accurate), the Export Compliance answer, or
the privacy policy beyond one clarifying sentence.

### 26a — The milestone predicate

Canonical definition goes in `lib/utils/date_calculations.dart`, next to
the rest of the day math, as a pure function over the already-computed day
count — not over dates. Something like `milestoneFor(int days)` returning
a small enum or `null`.

The rules:

- **Day zero is its own case.** `days == 0` means today is the day.
- **Round numbers for count-ups**: a short ordered constant list (7, 30,
  100, 365, 500, 1,000) plus a rule for beyond it (every 1,000, or every
  500 — pick one and write it down). Keep the list a constant, not
  scattered literals.
- **Negative counts never match.** `formatDayCount` deliberately preserves
  the minus sign for an `until` event whose date has passed and hasn't been
  re-saved since (see Phase 25), so `days` can be negative. Guard for it —
  `-100` is not a milestone.

The Swift side gets a mirror of this in `WidgetEventStore.swift`, kept in
sync by hand and commented as such, exactly like `dayCount(for:on:)`
already mirrors `daysSince`/`daysUntil`. Guiding principle 4 says don't
duplicate domain logic in Swift; a six-line integer predicate is the
smallest possible exception and is cheaper than inventing a way to ship
the answer across the App Group. Note the alternative that was considered
and rejected: precomputing a milestone flag in Flutter and putting it in
the payload doesn't work, because the widget renders seven days ahead and
the flag would be stale for six of them.

### 26b — Widget rendering

**No `SimpleEntry` change is needed, and that's the point.** The existing
entry already carries `dayCount: Int?`, and:

- `nil` is already the empty-state sentinel ("Add an event" / "Choose an
  event"), so `0` is unambiguous.
- Both directions converge on the day itself: an `until` event computes
  `today → eventDate` = 0, and Phase 25's inference saves a today-dated
  event as `since`, which computes `eventDate → today` = 0. **The trigger
  is just `entry.dayCount == 0`** — no direction check, no new field.

Adding a state enum to `SimpleEntry` would be a type for zero behavior
change, the same call Phase 21d made about the three empty states.

**The timeline needs no work either.** `timeline(for:in:)` already emits
seven daily entries with `.atEnd`, so the day-zero entry is generated in
advance and expires itself at the next midnight. Any milestone inside the
seven-day window is likewise already scheduled.

What to render, in value-per-line order:

1. **Replace the number with "Today".** The strongest signal and the least
   layout risk — a word at `displayMedium` weight reads as an event, not as
   a rendering bug the way a bare `0` does. For a milestone, keep the
   number and change the treatment around it.
2. **Flip the background to the accent** (`#B49CE8` with `onAccent` ink).
   Both tokens exist and their contrast was already measured in Phase 23,
   so this needs no new color work.
3. **Static sparkle or confetti marks**, if wanted — a `Canvas` or a few
   positioned shapes.

**Don't attempt animation.** Widgets are archived SwiftUI views rendered
out of process; there are no animation loops. iOS 17+ does transition
between timeline entries automatically, so the flip in at midnight
animates for free, but that's the whole budget.

**The celebration mascot pose is settled and the asset already exists.**
The standing direction had been one pose only, and specifically not the
per-event poses in `docs/dayward-widget-mockups.png`; a state-driven
celebration pose was agreed as a separate rule and supplied on
2026-08-22. Source vector is
[docs/dayward_celebration_flat.svg](dayward_celebration_flat.svg) —
jumping, raised fists, sparse confetti — and it is already rasterized
into `ios/DaysCounterWidget/Assets.xcassets/MascotCelebration.imageset/`
at the same 150/300/450px greyscale-plus-alpha sizes and framing as
`Mascot.imageset`. Nothing in Swift references it yet; wiring it to the
`dayCount == 0` branch is this phase's work.

**Fixed and confirmed on device (2026-08-22): the celebration mascot used to
render too small.** The confetti
spreads well outside the character, so at the walking pose's 72pt frame the
celebration's calendar body came out visibly smaller and the character read
as shrunken. The milestone branch now draws at 96pt. That number came from
compositing both assets at 72/88/96/104 and comparing the calendar bodies:
88 matches the walking pose's presence, and the extra few points are
deliberate weight for the occasion. Anything beyond about 104 starts
clipping confetti at the frame edge.

Add `#Preview`s for day zero and a milestone at both families. Previews
render without booting a simulator and are the fastest check on the
`.lineLimit(1)` truncation risk that bit Phase 21d.

### 26c — In-app card parity

`lib/widgets/event_card.dart` must get the same treatment or the widget
and the list disagree on the same day, which reads as a bug.

The card already computes `days` itself, so it calls the same predicate.
Its background is currently `_cardColor(context)` — the deterministic tint
cycle keyed off `event.id.hashCode` in light mode, `surfaceDark` in dark.
A milestone overrides that for the day. Keep the override inside
`_cardColor` rather than branching in `build`, so there stays exactly one
place that decides a card's color.

### 26d — Local notifications — **done, narrowed**

Shipped, but deliberately smaller than this section originally specified.
The rule is one thing: **an event counting down to a future date announces
itself at 9am on the day it arrives.** Milestone-based notifications — "100
days today", a day-before heads-up — were cut as more machinery than the
feature needed to start with. The visual milestone treatment on the widget
and the card is unaffected and stays.

`upcomingMilestoneCounts` and `dateOfMilestone`, written for the larger
rule, were deleted rather than left unused. They are a `git show` away if
that rule comes back.

Extensibility lives in the shape rather than in retained code:
`plannedNotifications` walks the event list and delegates to a per-event
generator that yields zero or more notifications, so a second rule is an
addition inside that generator and nothing above it changes. Identifiers
are `<eventId>-<dayCount>` for the same reason — `-0` today leaves room for
`-100` later without collision.

What was built, and the constraints that shaped it:

- A hand-rolled `MethodChannel` on
  `net.leerichardson.dayscounter/notifications`, not
  `flutter_local_notifications`. Its own channel rather than a method on the
  widget bridge, which is named `/widget`.
- **`UNCalendarNotificationTrigger` from `DateComponents`, never
  `UNTimeIntervalNotificationTrigger`** — an interval adds fixed 24-hour
  blocks and drifts across a DST boundary. The debug menu's test
  notification is the one deliberate exception, commented as such.
- **The 64-pending cap is iOS-wide per app** and iOS silently drops the
  excess, so the budget is enforced in Dart.
- **No background execution**: scheduling happens on the same awaited beat
  as the widget sync, on load and after every mutation.
- Stable ids plus `removeAllPendingNotificationRequests` before re-adding,
  so rescheduling replaces rather than stacks.
- Permission is requested when a user first switches an event on, never at
  launch. A refusal leaves the switch off.
- The editor only offers the toggle when the date is still ahead, and
  `_save` clears the flag if the date has moved into the past.
  `canNotifyFor` is shared between editor and scheduler so the control and
  the rule can't disagree.

**A platform-channel trap worth not rediscovering.** The native handler
originally cast the whole payload with `as? [[String: Any]]`. That cast can
fail *as a unit* — Flutter's standard codec delivers dictionaries whose keys
are `AnyHashable`-wrapped — leaving nothing scheduled and raising nothing at
all. The symptom was maddening: `notify: true` saved correctly, permission
granted, and zero pending requests. Cast each element separately, and have
the handler return a count of what it accepted so a decode failure shows up
as a number disagreeing with what Flutter planned rather than as silence.

**A debug menu exists** for exactly this reason — the notifications are days
away and fire at 9am, so the path is otherwise unverifiable without moving
the clock. Behind a bug icon shown only when `kDebugMode` is true, with the
native handlers inside `#if DEBUG`: fire a test notification ten seconds
out, re-run the scheduling call, and list what iOS is actually holding.
Confirmed end to end on the simulator: permission granted, requests
accepted by iOS, banner delivered carrying the production copy.

Two false trails cost real time here and are worth not repeating. The first
count of "accepted" was incremented per loop iteration rather than from
`add`'s completion handler, so it reported attempts as successes. The second
was worse: `#if DEBUG` is false in Runner's Swift unless the target is given
`SWIFT_ACTIVE_COMPILATION_CONDITIONS`, which Flutter's generated project
never does — so every debug handler compiled away, and "pending shows 0"
looked like a scheduling failure when it was a broken instrument.

### 26e — Lock screen content — **done, no setting**

Notification text renders on the lock screen, in front of whoever else is
in the room. This app's headline example is "Last Drink", and its likely
users include people counting sobriety days. "Last Drink — 1,000 days" on
a lock screen is a genuine leak, not a hypothetical one.

**Resolved without a setting: the notification is always generic.** Title
"Dayward", body "Today's the day.", with the event's name and emoji left
out entirely. A toggle was considered and dropped — it would have needed
somewhere for an app-wide setting to live, and the parallel-file pattern
that would have implied was deliberately deleted in Phase 21.

The trade is real and taken on purpose: naming the event would be more
useful, and someone tracking several dates can't tell from the banner which
one arrived. Opening the app answers that. Being useful on the lock screen
and being safe on the lock screen are in direct conflict here, and safe
wins for this app's subject matter.

If a setting is ever wanted, `notificationTitle` and `notificationBody` in
`lib/services/notification_schedule.dart` are the two constants to make
conditional.

### 26f — Where the opt-in lives

Notifications should be **per event, opt-in**. Most events don't warrant
one.

That means a per-event flag, which is the first real pressure on guiding
principle 2 (keep the domain model small) since the model was written. The
principle says don't add fields *until a phase needs one* — this phase
does, so the field is in bounds. Two options:

1. **A `notify` bool on `DateEvent`** (recommended). `fromJson` defaults it
   to `false` when the key is absent, so existing `events.json` files load
   unchanged. The App Group payload gains a key the widget ignores —
   Swift's `Decodable` skips unrecognized keys by default, so
   `WidgetEvent` needs no change at all.
2. A parallel file keyed by event id, like the retired
   `featured_event_id.txt`. Avoids touching the model, but means two files
   that can disagree about which events exist, and a deleted event leaves
   an orphan. Phase 21 just finished cleaning up exactly that shape.

Take option 1. Whether the event notifies is part of what the event is to
the user, not a separate setting about it.

The lock-screen-privacy toggle from 26e is genuinely app-wide, so that one
does belong in its own small settings store.

### 26g — What can be verified where

- `flutter test` covers the predicate directly: day zero, each threshold,
  the values either side of a threshold, and negatives not matching. Add
  card tests for milestone and non-milestone rendering, and a bridge test
  asserting what gets scheduled — including that the pending count stays
  under the cap with a deliberately large event list.
- Xcode Previews cover the widget's day-zero and milestone layouts without
  booting anything.
- **The iOS Simulator does deliver local notifications**, so the schedule →
  fire path, the permission prompt, and the lock-screen text can all be
  checked there.
- Device-only: how the whole thing actually feels, and confirming a
  notification arrives on a day the app was never opened.

Order the work to fail fast: predicate and its tests, then the widget
render (the first visible payoff and the cheapest), then card parity, then
notifications last, since they have the most moving parts and the longest
feedback loop.

Success criterion: **met.**

An event dated today shows a distinct "today" treatment on both the Home
Screen widget and its in-app card, reverting on its own the next day; an
event crossing a milestone shows the milestone treatment; and an event
with notifications enabled delivers a local notification on that day with
no network request made by the app.

All of it is confirmed: the widget's milestone rendering and the resized
celebration mascot on a physical iPhone, the card treatment and the whole
notification path — permission, scheduling, delivery — on the simulator.
The one deliberate narrowing is that notifications cover a countdown's
arrival day only, not every milestone; see 26d.

Verify:

```bash
flutter test
flutter analyze
```

Plus a simulator pass: set an event to today, confirm both surfaces change
and a notification fires; advance the simulator's date by a day and
confirm both revert.

---

# Post-V1 Learning Ideas

Possible future exercises:

- iCloud / CloudKit sync
- iPad support
- Android version
- Android Home Screen widget
- Import/export JSON
- Search
- Custom colors/icons
- Relative years/months/days display
- Accessibility improvements
- Localization

Do these only after V1 works.

---

# Feature Ideas

Possible future product features (distinct from the learning exercises
above — these would need their own design/phase treatment before
becoming plan work).

Both entries that used to sit here have been promoted into Phase 21.
"Swipable widgets" turned out not to need in-widget gestures at all —
WidgetKit has none — because iOS widget stacks already provide the swipe
once each widget instance can be configured separately. "Multiple
featured dates" is superseded by the same work: per-instance
configuration makes a curated featured list unnecessary, so the featured
concept is removed rather than expanded.

Nothing is currently listed here.

---

# Guiding Principles

1. Build vertically rather than designing the entire architecture first.
2. Keep the domain model small.
3. Treat dates as calendar dates, not durations.
4. Keep Flutter responsible for the main application.
5. Keep the native iOS widget implementation small.
6. Avoid a backend until a real requirement exists.
7. Introduce libraries only when their value is obvious.
8. Learn the platform boundary rather than trying to hide it.
9. Commit at each meaningful learning milestone.
10. Finish the simple application before expanding its scope.
11. Keep this plan as the single source of truth for phase sequencing —
    don't maintain a second list (session logs, milestone lists) that
    restates the same tasks and can drift out of sync.
