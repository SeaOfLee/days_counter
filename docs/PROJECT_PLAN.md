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
- Push notifications
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
have since been **explicitly requested** and are real upcoming work
rather than hypothetical exercises; work them in order unless told
otherwise. Phase 22 (Lock Screen Widgets) remains genuinely optional and
unrequested — its number places it before 23–25 but its priority does
not.

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

More is simulator-verifiable than expected — the runtime matches the
widget's deployment target, so the build cycle itself, the Edit Widget
picker and its ordering, placing two widgets configured to two events,
and delete/rename propagation can all be checked without a device.

Genuinely device-only: **upgrade-in-place from the shipped 1.0.1**, which
cannot be installed on a simulator, and the stack behavior itself — stack
creation by dragging one widget onto another, the swipe feel, and Smart
Rotate. Widget placement needs interactive long-press UI that previous
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
