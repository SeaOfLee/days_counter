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

The **widget extension is the exception to all of the above**. It uses
`GENERATE_INFOPLIST_FILE = YES`, so its version really does come from
`MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` in
`ios/Runner.xcodeproj/project.pbxproj` — nothing about it reads
`pubspec.yaml`. If those drift from the app's version, the upload trips
`ITMS-90473` ("CFBundleVersion Mismatch"), because Apple requires an
extension to carry the same version as its containing app. After bumping
`pubspec.yaml`, set the extension to match, in Xcode:

```text
Runner project → TARGETS → DaysCounterWidgetExtension → General → Identity
  Version = <marketing-version>   (e.g. 1.0.1)
  Build   = <build-number>        (e.g. 3)
```

Set it on the target, not the project (blue icon) — the project level
cascades to Runner too. Check all three configurations (Debug/Release/
Profile) agree. Verify before archiving:

```bash
grep -n "MARKETING_VERSION\|CURRENT_PROJECT_VERSION" ios/Runner.xcodeproj/project.pbxproj
```

Runner's own `MARKETING_VERSION` in that file is stale and inert; ignore
it. To confirm what actually ships, check the built bundles rather than
the project file:

```bash
flutter build ios --simulator --debug
plutil -extract CFBundleVersion raw build/ios/iphonesimulator/Runner.app/Info.plist
plutil -extract CFBundleVersion raw build/ios/iphonesimulator/Runner.app/PlugIns/*.appex/Info.plist
```

### 2. Refresh the screenshots

Only needed when the UI has visibly changed. App Store Connect requires
one 6.7" iPhone and one 13" iPad screenshot, since the app is Universal
(`TARGETED_DEVICE_FAMILY = "1,2"`). The current pair lives in
`app_store_assets/screenshots/`.

Populate demo events with the development-only seeding script rather than
typing them in by hand — the app itself ships with no seed data and opens
on the empty state:

```bash
xcrun simctl boot "iPhone 13 Pro Max"     # 1284x2778, a size App Store Connect accepts
open -a Simulator
flutter build ios --simulator --debug
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted net.leerichardson.dayscounter   # first launch creates the container
xcrun simctl terminate booted net.leerichardson.dayscounter

dart run tool/seed_demo_events.dart        # writes events.json into the booted simulator
xcrun simctl launch booted net.leerichardson.dayscounter
```

The script must terminate the app first (it does this itself) because
`LocalEventRepository` caches events in memory and would overwrite the
file on its next save. Relaunching also pushes the whole event list
through the widget bridge, so the widget's event picker sees the demo
data.

**Build with `--dart-define=SCREENSHOT_MODE=true`.** Screenshots have to
come from a debug build, because Flutter won't run release or profile
mode on a simulator, and a debug build shows the developer bug icon in the
app bar — which can't appear in a store listing. That flag hides it.

**Only one simulator may be booted at a time.** `booted` is ambiguous
otherwise, and the seed script will silently write into whichever device
`simctl` picks — including an iPad you left running from the previous
capture. `xcrun simctl list devices booted` before seeding.

One demo event is pinned to an exact relative offset (100 days) so the
milestone treatment actually appears in the capture. An absolute date
would show it for a single day and never again.

Then clean up the status bar and capture:

```bash
xcrun simctl status_bar booted override --time "9:41" --dataNetwork wifi \
  --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 \
  --batteryState charged --batteryLevel 100
xcrun simctl io booted screenshot app_store_assets/screenshots/iphone-6.7-event-list.png
```

At least three iPhone screenshots are worth uploading, not the minimum
one. App Store search results fill an inline preview row from the first
few portrait screenshots, and with a single screenshot that row tends not
to render at all — the listing then appears with no images beneath it.

Widget screenshots are allowed and worth including, with two constraints:
keep other apps' icons and content out of frame, and capture them on a
**physical device**, because widget configuration doesn't work on the
simulator (see PROJECT_PLAN.md Phase 21g). A device capture won't match an
accepted size, so compose it onto a correctly sized canvas rather than
resizing it — resizing distorts the aspect ratio, which is the rejection
trap below.

Repeat on `iPad Pro 13-inch (M5)` (2064x2752) for
`ipad-13-event-list.png`, omitting the cellular flags. Shut down the first
simulator before booting the second, or `booted` becomes ambiguous.

**Sizing gotcha**: don't assume the newest simulator produces an accepted
size. An iPhone 17 Pro Max screenshot (1320x2868) was rejected — App Store
Connect wants the 6.5"/6.7" buckets (1242x2688 or 1284x2778) and the
13-inch iPad buckets (2064x2752 or 2752x2064). Pick a simulator whose
*native* resolution matches exactly rather than resizing afterward and
distorting the aspect ratio.

### 3. Archive in Xcode

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

Building entirely from the command line is a one-liner, and produces both
the archive and a signed IPA:

```bash
flutter build ipa --export-method app-store
```

Note the value is `app-store`, not `app-store-connect` — the latter is
`xcodebuild -exportArchive`'s spelling of the same thing and Flutter
rejects it. Outputs land in `build/ios/archive/Runner.xcarchive` and
`build/ios/ipa/`.

One surprise with this route: Flutter generates an `ExportOptions.plist`
with `manageAppVersionAndBuildNumber = true`, so **Xcode may silently
raise the build number during export** to clear whatever App Store
Connect already has. The archive and the exported IPA can therefore
disagree. It rewrites the app and the extension together, so they stay
matched. Check what actually shipped, and bring `pubspec.yaml` (and the
widget target) up to it afterward so the repo isn't understating the
released build:

```bash
unzip -q -o build/ios/ipa/*.ipa -d /tmp/ipacheck
plutil -extract CFBundleVersion raw /tmp/ipacheck/Payload/Runner.app/Info.plist
```

### 4. Validate and upload

From Organizer, with the new archive selected:

```text
Validate App → (fix anything it flags) → Distribute App → App Store Connect → Upload
```

This signs with an **Apple Distribution** certificate (not the
Development one used for device testing) via automatic signing, and
uploads the build to App Store Connect. It typically takes 10-30 minutes
to finish processing on Apple's end before it's selectable in the next
step.

To upload an IPA built from the command line, either drag it into
[Transporter](https://apps.apple.com/us/app/transporter/id1450874784)
(free, Mac App Store) and hit Deliver, or generate an app-specific
password at [appleid.apple.com](https://appleid.apple.com) and run:

```bash
xcrun altool --upload-app --type ios -f build/ios/ipa/days_counter.ipa \
  -u <apple-id-email> -p <app-specific-password>
```

Confirm what you're about to upload is what you think it is — the IPA is
just a zip:

```bash
codesign -dvvv /tmp/ipacheck/Payload/Runner.app 2>&1 | grep ^Authority
# expect: Apple Distribution: ... (not Apple Development)
```

### 5. Submit for review in App Store Connect

In the browser at [appstoreconnect.apple.com](https://appstoreconnect.apple.com):

1. Open the app record, and create a new version if one doesn't already
   exist for this release (**+ Version or Platform**, e.g. `1.0.1`).
2. Under Build, select the build you just uploaded.
3. Fill in "What's New in This Version" release notes.
4. Replace the screenshots in the 6.7" iPhone and 13" iPad slots if the
   UI changed.
5. Answer **Export Compliance** (No — the app contains no encryption and
   has no networking code at all). This is asked per build, not once per
   app.
6. Fill in **App Review Information → Contact Information** (first name,
   last name, phone number with country code, email). This lives on the
   version page, not the app record, and the phone number is required.
   No demo account is needed; the app has no login.
7. **Add for Review → Submit to App Review**.

App Privacy ("Data Not Collected"), age rating, category, and the privacy
policy and support URLs carry over from the app record and don't need
re-answering each release. The canonical copy of all the listing text and
answers is [app_store_assets/metadata.md](app_store_assets/metadata.md).

Note: App Store Connect won't let you submit a new version for review
while a previous one is still "Waiting for Review" or "In Review" — you
can still do steps 1-3 to have it staged and ready, but the Submit step
is blocked until the in-flight review resolves (approved or rejected).
Typical review turnaround is 1-2 days, though this varies and is out of
this project's hands.
