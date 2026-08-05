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
