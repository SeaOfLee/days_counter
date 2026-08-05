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

Allow multiple widget instances, each configured for a different event.

Use modern WidgetKit configuration through App Intents.

Conceptually:

```swift
struct SelectEventIntent:
    WidgetConfigurationIntent {

    @Parameter(title: "Event")
    var event: EventEntity?
}
```

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

Success criterion:

Multiple widgets can display different events.

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

---

# Post-V1 Learning Ideas

Possible future exercises:

- iCloud / CloudKit sync
- iPad support
- Android version
- Android Home Screen widget
- Import/export JSON
- Event ordering
- Search
- Custom colors/icons
- Relative years/months/days display
- Accessibility improvements
- Localization

Do these only after V1 works.

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
