# Dayward (days_counter)

An iOS-first Flutter app for tracking the number of days since or until
meaningful dates. See [CLAUDE.md](CLAUDE.md) and
[docs/PROJECT_PLAN.md](docs/PROJECT_PLAN.md) for the full project context
and build plan.

## Running locally

This project targets iOS only (no Android build is expected). Flutter is
pinned to the **beta channel** — stable's engine currently crashes on
first launch on iOS 26 (see CLAUDE.md for details) — so make sure you're
on beta before running any of this:

```bash
flutter channel beta
flutter upgrade
```

### One-time setup

```bash
flutter doctor -v        # verify Flutter, Xcode, and CocoaPods are all set up
flutter pub get          # install Dart/Flutter dependencies
```

### Everyday commands

```bash
flutter devices          # list available simulators and connected devices
open -a Simulator         # launch the iOS Simulator app

flutter run               # run on the first available/connected device
flutter run -d <device-id> # run on a specific simulator or physical device
                           # (device id comes from `flutter devices`)

flutter test               # run the Dart/widget unit test suite
flutter analyze           # static analysis (flutter_lints)
```

### Running on a physical iPhone

Plug the phone in (or have it on the same network for wireless
debugging), confirm it shows up in `flutter devices`, then:

```bash
flutter run -d <device-id> --debug
```

The first run may prompt you to trust the developer certificate on the
phone (Settings → General → VPN & Device Management).

### iOS widget extension

The `DaysCounterWidget` target builds automatically as part of `flutter
run`/`flutter build ios` (it's embedded in the Runner app). To iterate on
its SwiftUI code directly with live previews, open `ios/Runner.xcworkspace`
in Xcode and select the `DaysCounterWidgetExtension` scheme.

## Releasing to the App Store

### 1. Bump the version

The app's version comes from `pubspec.yaml`'s `version:` field (format
`<marketing-version>+<build-number>`, e.g. `1.0.1+2`), not from Xcode's
General tab — `Info.plist` reads `$(FLUTTER_BUILD_NAME)`/
`$(FLUTTER_BUILD_NUMBER)`, which are populated into
`ios/Flutter/Generated.xcconfig` from `pubspec.yaml`. Editing the version
in Xcode's General tab sets `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION`
instead, which `Info.plist` doesn't reference here, so it has no effect.
App Store Connect also rejects re-uploading a build with a build number
it's already seen, so this has to go up every release.

After changing `pubspec.yaml`'s `version:`, `Generated.xcconfig` is **not**
regenerated automatically by Xcode's Archive build (nor by `flutter pub
get`) — run this first, or the archive will still contain the old version:

```bash
flutter build ios --config-only   # refreshes Generated.xcconfig from pubspec.yaml, no compiling
```

### 2. Archive in Xcode

Open `ios/Runner.xcworkspace` (not the `.xcodeproj`) in Xcode. Set the run
destination to **Any iOS Device (arm64)** — archiving is disabled while a
simulator is selected. Then:

```text
Product → Archive
```

This builds with the Release configuration and, once it succeeds, opens
the **Organizer** window automatically (`Window → Organizer` if it
doesn't). Building the same archive from the command line instead
(`xcodebuild archive`) works too, but the result won't appear in
Organizer automatically since it's written to a custom output path —
copy the `.xcarchive` into
`~/Library/Developer/Xcode/Archives/<yyyy-mm-dd>/`, matching Xcode's own
`<scheme> <m-d-yy, h.mm a>.xcarchive` naming, if you need it to show up
there.

### 3. Validate and upload

From Organizer, with the new archive selected:

```text
Validate App → (fix anything it flags) → Distribute App → App Store Connect → Upload
```

This signs with an **Apple Distribution** certificate (not the
Development one used for device testing) via automatic signing, and
uploads the build to App Store Connect. It typically takes 10-30 minutes
to finish processing on Apple's end before it's selectable in the next
step.

### 4. Submit for review in App Store Connect

In the browser at [appstoreconnect.apple.com](https://appstoreconnect.apple.com):

1. Open the app record, and create a new version if one doesn't already
   exist for this release (e.g. `1.0.1`).
2. Under Build, select the build you just uploaded.
3. Fill in "What's New in This Version" release notes.
4. Submit for review.

Note: App Store Connect won't let you submit a new version for review
while a previous one is still "Waiting for Review" or "In Review" — you
can still do steps 1-3 to have it staged and ready, but the Submit step
is blocked until the in-flight review resolves (approved or rejected).
Typical review turnaround is 1-2 days, though this varies and is out of
this project's hands.
