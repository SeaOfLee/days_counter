# App Store Connect metadata — Dayward

Drafted content for the app record's "Prepare for Submission" section.
Paste directly; adjust as needed.

## App name

Dayward: Days Since & Until

("Dayward" alone collided with an existing App Store listing —
App Store names must be globally unique, unrelated to bundle ID or
trademark. `CFBundleDisplayName` and the in-app branding stay just
"Dayward"; only this store-listing field needed the qualifier.)

## Subtitle (30 char max)

With a Home Screen widget

(Changed from "Track days since & until" — that's now redundant with
the app name above.)

## Promotional Text (170 char max)

Track the days that matter — since a big moment, until the next one.
See your count right on your Home Screen with an auto-updating widget.

(Unlike the rest of this metadata, promotional text can be updated any
time without a new version submission — worth revisiting later.)

## Category

Utilities

## Description

Dayward keeps track of the days that matter to you — count down to an
upcoming event, or count up from a meaningful date.

- Add unlimited events with a title, date, and optional emoji
- Count "since" a date (e.g. days sober, days at a new job) or "until"
  one (e.g. days to a trip)
- See your count at a glance from your Home Screen with a widget that
  updates automatically
- Choose which event your widget features
- Everything stays on your device — no account, no tracking, no ads

## Keywords

days,counter,countdown,widget,tracker,dates,anniversary,habit

## Age rating questionnaire

Answer "None"/"No" throughout — no mature content, no user-generated
content, no gambling, no web access. Should land at **4+**.

## App Privacy ("nutrition label")

Answer **"Data Not Collected"** across the board. The app has no
accounts, no analytics, and no first-party networking code of its own
(verified via `grep -r "http\|Socket\|URLSession" lib/ ios/`).

**Caveat, as of 1.0.1:** the `google_fonts` package fetches the
Quicksand font over HTTPS from `fonts.gstatic.com` on first launch,
because the font is not bundled as an asset — so the app is not
literally network-free, and the device's IP address reaches Google in
the course of that request. "Data Not Collected" still holds: the IP
is transient request routing, not something this app collects, stores,
or uses for tracking, advertising, or analytics. Bundling the
Quicksand TTFs (planned for 1.0.2) removes the fetch and makes the
no-networking claim literally true again.

## Privacy Policy URL

https://leerichardson.net/dayward-privacy/

## Support URL

https://leerichardson.net/dayward-support/

(Source drafted to `~/Downloads/dayward-support.md` — getting
started, adding the widget, FAQ, contact email. Not yet published;
publish to that path once ready.)

## Copyright

2026 Lee Richardson

## Bundle ID

net.leerichardson.dayscounter

## Export Compliance

Answer **No** — the app does not use encryption. It implements none of
its own, and the one network request it does make (the `google_fonts`
Quicksand fetch described above) is ordinary HTTPS, which falls under
the standard exemption for using platform-provided TLS rather than
implementing or bundling cryptography.

## App Review Information (contact)

- Name: Lee Richardson
- Email: l.richardson1@gmail.com
- Phone: entered directly in App Store Connect (deliberately not
  recorded here)

No demo account needed; the app has no login/accounts.
