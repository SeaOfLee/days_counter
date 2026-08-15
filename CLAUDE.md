# CLAUDE.md

Guidance for agents working in this repository.

## What this is

An iOS-first Flutter app for tracking the number of days since or until
meaningful dates (e.g. "Last Drink — 1,139 days"). It is a **learning
project**, not a commercial product — the point is hands-on practice with
Flutter/Dart, Riverpod, local persistence, Xcode, Swift/SwiftUI, WidgetKit,
App Groups, and signing/provisioning. Optimize for understanding over
speed or polish.

The app's user-facing name is **Dayward** (`CFBundleDisplayName`, the
app bar title, the widget's `configurationDisplayName`) — this is
distinct from the underlying Flutter project/package name
(`days_counter`) and repo directory name, which stay as-is; don't
"fix" that mismatch, it's intentional.

The full phased build plan lives in @docs/PROJECT_PLAN.md.
**Read it before starting non-trivial work** — it defines the current
phase, the success criterion for that phase, and what's explicitly
deferred. Do not jump ahead to a later phase's work (e.g. don't add
Riverpod, persistence, or the WidgetKit extension) unless asked or unless
the plan's current phase calls for it.

A design/look-and-feel pass has since happened — see the note under
"Current state" below. Two reference images live in `docs/`:
[docs/dayward-widget-mockups.png](docs/dayward-widget-mockups.png) is
the one actually used (purpose-built for this app, uses real event
data, lavender/mascot palette).
[docs/design-reference-dashboard.png](docs/design-reference-dashboard.png)
is an earlier, generic finance-dashboard mockup that was superseded
once the widget-mockups image surfaced — kept for history, not a live
reference.

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
Group `group.net.leerichardson.dayscounter` (Phase 15) — Runner's and the
widget extension's entitlements
([ios/Runner/Runner.entitlements](ios/Runner/Runner.entitlements),
[ios/DaysCounterWidgetExtension.entitlements](ios/DaysCounterWidgetExtension.entitlements))
both declare it under the same development team, confirmed by
inspecting the signed binaries. The widget now renders real Flutter
data (Phase 16): [lib/services/widget_bridge.dart](lib/services/widget_bridge.dart) calls a
`MethodChannel` (`net.leerichardson.dayscounter/widget`) whose handler in
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
`pumpAndSettle()` times out. The AppDelegate's channel handler also now
calls `WidgetCenter.shared.reloadAllTimelines()` (guarded by
`if #available(iOS 14.0, *)`) after every write (Phase 17), so the
widget refreshes immediately after an edit instead of waiting on
WidgetKit's own reload schedule — confirmed on-device. Phase 18 is also
done: [lib/providers/featured_event_provider.dart](lib/providers/featured_event_provider.dart) persists a chosen
featured-event ID via new `EventRepository.get/setFeaturedEventId()`
methods (a small `featured_event_id.txt` file alongside `events.json`
in `LocalEventRepository`), and [lib/screens/featured_event_screen.dart](lib/screens/featured_event_screen.dart)
(reached via a new icon in `EventListScreen`'s app bar) lets the user
pick one. `selectFeaturedEvent()` in the provider file is the single
source of truth for "which event does the widget show" — it falls back
to the first event if nothing's chosen yet or the chosen one was
deleted — and both `EventsNotifier` and `FeaturedEventIdNotifier` call
it before syncing to `WidgetBridge`, awaited the same way as Phase 16/17.

**Flutter is on the `beta` channel, not `stable`**, and should stay
there until further notice. Stable 3.44.8's engine crashes
(`EXC_BAD_ACCESS` in `-[VSyncClient initWithTaskRunner:callback:]`,
called from `FlutterViewController createTouchRateCorrectionVSyncClientIfNeeded`)
on first launch on this iPhone 13 Pro running iOS 26.5.2 — confirmed
with a throwaway stock `flutter create` app crashing identically, so
it's an engine/iOS compatibility bug, not anything in this project.
Beta 3.47.0-0.3.pre's newer engine does not have this bug. If physical-device
testing breaks again with this exact crash signature, check whether
stable has since shipped a fix before assuming it's a regression here.
Switching channels bumped `IPHONEOS_DEPLOYMENT_TARGET` from 13.0 to 15.0
project-wide (an expected, harmless Flutter tooling migration).

Phase 19 is done too: `DaysCounterWidgetEntryView` now branches on
`@Environment(\.widgetFamily)`, with a `systemMedium` layout (title
left, count+"days" right via `HStack`/`Spacer`) alongside the original
`systemSmall` one, and `.supportedFamilies([.systemSmall, .systemMedium])`
makes that explicit — both confirmed rendering cleanly on-device.

**This completes every item in PROJECT_PLAN.md's "V1 Definition of
Done."** All required phases (0–19) are done. Everything past V1 is
optional and only pursued if explicitly requested, with one exception:
**Phase 20 — Prepare for App Store Submission is the active next
phase**, requested by the user right after V1 landed, to be worked on
before any subsequent design/look-and-feel pass (which the user plans
to handle themselves). Phases 21–22 (Configurable Widgets, Lock Screen
Widgets) and the remaining "Post-V1 Learning Ideas" list were still
fully optional at that point — see the newer note below, which
supersedes this: Phase 21 has since been requested, rewritten, and
joined by Phases 23–25.

Phase 20 is underway: the placeholder bundle identifier
(`com.example.daysCounter`) has been renamed throughout to
`net.leerichardson.dayscounter` — Runner, RunnerTests, and the widget
extension's `PRODUCT_BUNDLE_IDENTIFIER`s in
`ios/Runner.xcodeproj/project.pbxproj`, the App Group in both
`.entitlements` files (now `group.net.leerichardson.dayscounter`), and
the widget-bridge `MethodChannel` name in
[ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift),
[lib/services/widget_bridge.dart](lib/services/widget_bridge.dart), and
[test/fakes/widget_bridge_mock.dart](test/fakes/widget_bridge_mock.dart) (now
`net.leerichardson.dayscounter/widget`). The user's Apple Developer
Program (Individual) enrollment is confirmed and active, and a device
build/deploy under the new App ID and App Group succeeded, confirming
Apple's provisioning went through. The app icon
(`ios/Runner/Assets.xcassets/AppIcon.appiconset/`) is also done — all
15 declared sizes were generated via `sips` from a user-supplied
1024×1024 master image (no alpha channel, as the App Store marketing
icon requires), confirmed rendering on-device. The widget extension's
own icon asset catalog
(`ios/DaysCounterWidget/Assets.xcassets/AppIcon.appiconset/`, used for
its gallery listing) is intentionally left empty for now — WidgetKit
falls back to the app's icon, and it's not required for submission.
The app is now branded "Dayward" throughout (`CFBundleDisplayName` in
both Info.plists, `MaterialApp.title`, the widget's
`configurationDisplayName`, and the app bar title in
[lib/screens/event_list_screen.dart](lib/screens/event_list_screen.dart)) — see the note under "What this
is" above. `MaterialApp` also now sets `debugShowCheckedModeBanner:
false` explicitly in [lib/app.dart](lib/app.dart) — harmless in real release builds (where
it's already suppressed) but needed for clean App Store screenshots
captured in debug mode, since Flutter only supports debug mode on iOS
Simulator (release/profile require a physical device). The privacy
policy is live at https://leerichardson.net/dayward-privacy/ (source
saved to `~/Downloads/dayward-privacy-policy.md`) — the app has no
accounts, analytics, or networking code of its own, so "Data Not
Collected" is accurate for App Privacy questionnaire purposes. **One
caveat, now resolved**: the shipped 1.0.1 build fetched Quicksand over
HTTPS from `fonts.gstatic.com` on first launch via `google_fonts`,
since the font wasn't bundled — so "no networking anywhere" was not
literally true for that build. It didn't change the questionnaire
answers (see that file for the reasoning), and shipping 1.0.1 that way
was a deliberate call: the build was already uploaded, and the risk
didn't justify restarting review.

**Since then the font has been bundled** and the `google_fonts`
dependency removed entirely, so the claim is true again for anything
built after 1.0.1. `assets/fonts/` holds the four static Quicksand
weights the design uses (400/500/600/700) plus the OFL license the
font's terms require; `pubspec.yaml` declares them under family
`Quicksand`, and [lib/theme/app_theme.dart](lib/theme/app_theme.dart)
sets `ThemeData.fontFamily` instead of calling `GoogleFonts`. The four
explicitly-styled roles carry `fontFamily` themselves because
`appBarTheme.titleTextStyle` reuses `titleLarge` directly, before
`ThemeData` has applied the family to the text theme. The bundled TTFs
are the exact files `google_fonts` had been downloading (recovered
from a simulator's font cache), so this changed nothing visually — the
rendered event list is pixel-identical to the committed store
screenshot, verified with `magick compare` returning zero differing
pixels.

`app_store_assets/screenshots/` holds two, both captured via
`xcrun simctl io ... screenshot` with `xcrun simctl status_bar ...
override` for a clean 9:41/full-signal status bar:
`iphone-6.7-event-list.png` (1284×2778, iPhone 13 Pro Max simulator)
and `ipad-13-event-list.png` (2064×2752, iPad Pro 13-inch (M5)
simulator) — the app is Universal (`TARGETED_DEVICE_FAMILY = "1,2"`
for both targets, the unmodified Flutter default), so App Store
Connect required an iPad screenshot too. The list screen has never
been given iPad-specific layout treatment, but renders acceptably as
full-width cards with no overflow — good enough to ship as-is.
**Screenshot sizing gotcha**: don't assume the newest simulator
produces an Apple-accepted size — an initial 1320×2868 iPhone 17 Pro
Max screenshot was rejected; App Store Connect wants the older
6.5"/6.7" iPhone buckets (1242×2688 or 1284×2778) and the 13-inch iPad
bucket (2064×2752 or 2752×2064), not necessarily a new device's native
resolution. Check App Store Connect's stated requirements first and
pick a simulator whose *native* resolution matches exactly, rather
than resizing after the fact and distorting the aspect ratio.

Apple Developer Program enrollment cleared and App Store Connect
access is unblocked. The app record was created — the name "Dayward"
alone collided with an existing App Store listing (names must be
globally unique, unrelated to bundle ID or trademark), so the store
listing name is **"Dayward: Days Since & Until"** while
`CFBundleDisplayName`/in-app branding stay plain "Dayward"; the
subtitle and promotional text were adjusted to avoid redundancy with
the longer name. All of this is captured in
[app_store_assets/metadata.md](app_store_assets/metadata.md), which now also has Export Compliance
(No — the app implements no encryption; the `google_fonts` HTTPS fetch
noted above is covered by the standard TLS exemption), App Review
contact, and Copyright ("2026 Lee Richardson"). Both of the loose ends
that used to be flagged here are now closed: the Support URL
(`https://leerichardson.net/dayward-support/`, source drafted to
`~/Downloads/dayward-support.md`) is confirmed live, and the App Review
contact phone number was entered directly in App Store Connect (it is
deliberately not recorded in the repo).

A release build was successfully archived and exported
(`xcodebuild archive` / `-exportArchive` with automatic signing,
method `app-store-connect`) — confirmed signed with an *Apple
Distribution* certificate (not the Development one used for device
testing), and uploaded to App Store Connect via Xcode Organizer.
Command-line archives don't appear in Organizer automatically since
they're built to a custom path outside Xcode's default
`~/Library/Developer/Xcode/Archives/` location; copy the `.xcarchive`
there (matching Xcode's `<scheme> <m-d-yy, h.mm a>.xcarchive` naming)
if this needs doing again. Note the archive/build is labeled "Runner"
in Organizer, not "Dayward" — that's the Xcode scheme name, unrelated
to the app's display name, and fine to leave as-is.

**Phase 20 is done — the app was submitted for App Store review**,
satisfying its success criterion. Apple's review turnaround is
typically 1–2 days but varies; approval/rejection is out of this
project's hands.

**Version 1.0.1 (build 3) was submitted on 2026-08-13**, superseding
the first submission. It carries the no-seed-data change, the new
launch screen, the de-personalized widget gallery placeholder, and
freshly captured screenshots. Both of Phase 20's old loose ends are
closed: the support page is live and the App Review phone number was
entered in App Store Connect. Verified before submitting: a clean
release build of that exact source renders correctly on the physical
iPhone (iOS 26.6), and the exported IPA is signed *Apple
Distribution* with app and widget extension both at `1.0.1 (3)`.

With V1 (Phases 0–19) and Phase 20 both done, a design/look-and-feel
pass (optional, post-V1) has also happened — see below. Expect to be
asked to work through the phases in @docs/PROJECT_PLAN.md roughly in
order.

**Five feature requests have since been folded into the plan** (planned
2026-08-15, none implemented yet):

- **Phase 21 (Configurable Widgets) was rewritten** to absorb two of
  them: "widget can swipe through multiple events" and "multiple
  featured events". WidgetKit has no swipe or pan gesture API at all —
  the swipe people picture is the OS-level widget *stack*, so all this
  app must supply is per-instance configuration via App Intents, which
  is what Phase 21 already was. The same work **deletes the
  featured-event concept from Phase 18** (provider, screen, repository
  methods, `featured_event_id.txt`, and the app bar action) rather than
  extending it to a list, since per-instance config makes a single
  globally featured event redundant. Phase 18 is marked superseded in
  place. Note this phase reopens the `ENABLE_APP_INTENTS_METADATA_EXTRACTION`
  build-cycle landmine documented above — the phase opens with a spike
  to find out, and a flag flip *without* a real intent in the target is
  a false negative.
- **Phase 23** — dark-mode readability on the event editor. Every cause
  is in [lib/theme/app_theme.dart](lib/theme/app_theme.dart), not the
  screen: `ColorScheme.copyWith` overrides colors without their paired
  `on*` roles, there's no `DatePickerThemeData`, `bodyLarge` (the actual
  `TextField` input style) is never defined, and unselected
  `SegmentedButton` segments are muted-on-card against a nearly
  identical scaffold.
- **Phase 24** — drag/drop reordering. Needs **no** `sortOrder` field:
  order is already just array position in `events.json`. It does need a
  bulk-order method on `EventRepository`, since `getEvents()` returns an
  unmodifiable list and `saveEvent` only appends or replaces in place.
- **Phase 25** — relative day entry ("100 days from today" as an
  alternative to the date picker). Input convenience only; no model,
  serialization, or Swift change.

Phase 22 (Lock Screen Widgets) and the "Post-V1 Learning Ideas" list
remain optional and unrequested — 22's number puts it before 23–25 but
its priority does not.

**Design/look-and-feel pass (optional, post-V1) is done**, targeting
[docs/dayward-widget-mockups.png](docs/dayward-widget-mockups.png) — a
lavender palette with a cartoon calendar-page mascot. Only the single
"finger up" mascot pose is used (per explicit user direction — the
mockup's per-event custom poses, e.g. sunglasses for Vacation, flowers
for Anniversary, were explicitly not wanted); source at
`~/Downloads/dayward_character.png`, which turned out to already have
a genuine alpha-transparent background (confirmed via ImageMagick
pixel inspection — the olive vignette visible in casual previews was a
rendering artifact, not real pixel data), so no vectorization or
background removal was needed. **The mascot appears only on the iOS
widget, not anywhere in the Flutter app** — another explicit user
call, made after an initial pass had briefly included it on in-app
event cards too.

Design tokens live in [lib/theme/app_colors.dart](lib/theme/app_colors.dart) (palette constants,
light + dark) and [lib/theme/app_theme.dart](lib/theme/app_theme.dart) (`ThemeData` built from
them, including `CardTheme`/`AppBarTheme`/`FloatingActionButtonThemeData`/
`InputDecorationTheme`/`SegmentedButtonThemeData`/`ListTileThemeData`
overrides), wired into `MaterialApp.theme`/`darkTheme` in [lib/app.dart](lib/app.dart) —
replacing the old `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
placeholder. Typography uses the new `google_fonts` dependency
(Quicksand) via `TextTheme` role reuse (`displayMedium` for the
headline day-count number, `titleLarge`/`titleMedium`/`bodyMedium` for
title/unit-label/date-line) rather than a bespoke theme-extension
class. [lib/widgets/event_card.dart](lib/widgets/event_card.dart) was restructured from a centered
column into a row (emoji badge circle, title + inline day-count), with
its background color cycled deterministically across four pastel tints
keyed by `event.id.hashCode` (not a stored field — `DateEvent` still
has no `color` field, per the guiding principle of keeping the domain
model small) in light mode, collapsing to one uniform dark surface
color in dark mode (matching the mockup, which only shows one dark
card style, not per-event dark tints). This card restructure changed
`EventCard`'s title from an emoji-concatenated string to a bare
`Text(event.title)`, which required scoping a `test/event_edit_screen_test.dart`
finder to the `TextFormField` specifically (`find.descendant(...)`) —
flagged here since it's the one place this pass touched test
assertion logic rather than just rendering.

On the widget side, [ios/DaysCounterWidget/DaysCounterWidget.swift](ios/DaysCounterWidget/DaysCounterWidget.swift) got
inline Swift color constants mirroring the Dart hex values 1:1 (no
shared code between the two targets — by design, Flutter owns the
app, Swift owns only the widget), a `divider` rule + "Since/Until
<date>" line that the widget previously didn't render at all, a
`.system(design: .rounded, weight: .heavy)` font as the closest
system-font approximation to Quicksand without bundling a custom font
into the widget extension target, and a `@Environment(\.colorScheme)`-
driven background swap (`.containerBackground` now uses the app's
palette instead of the generic `.fill.tertiary` system material). The
mascot lives in `ios/DaysCounterWidget/Assets.xcassets/Mascot.imageset/`
(raster 1x/2x/3x PNGs generated via ImageMagick from the source
character art, referenced as `Image("Mascot")`). None of the widget's
`Provider`/`getTimeline`/`dayCount(for:on:)` date-math or App Group
bridging changed — this pass was view-layer only. The full build
(Runner + widget extension) compiles cleanly and all 35 Flutter tests
pass; the widget's on-screen rendering itself (actually placing it on
a Home Screen) needs a manual on-device/simulator check, since adding
a widget requires interactive long-press-and-add UI that couldn't be
automated in this session (no accessibility/UI-automation access).

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

When picking up a task, identify which phase in @docs/PROJECT_PLAN.md it
corresponds to, check that phase's success criterion, and stop there
rather than continuing into the next phase's scope. If a request
conflicts with the plan's explicit "out of scope for V1" list, flag it
rather than silently implementing it.
