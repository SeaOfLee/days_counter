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

## Promotional Text

See [listing-copy.md](listing-copy.md). Kept there with the Description
and release notes, since all three change from release to release.

(Unlike the rest of this metadata, promotional text can be updated any
time without a new version submission — worth revisiting later.)

## Category

Utilities

## Description

See [listing-copy.md](listing-copy.md).

## Keywords

days,counter,countdown,widget,tracker,dates,anniversary,habit

## Age rating questionnaire

Answer "None"/"No" throughout — no mature content, no user-generated
content, no gambling, no web access. Should land at **4+**.

## App Privacy ("nutrition label")

Answer **"Data Not Collected"** across the board. The app has no
accounts, no analytics, and no first-party networking code of its own
(verified via `grep -r "http\|Socket\|URLSession" lib/ ios/`).

**Resolved after 1.0.1:** the shipped 1.0.1 build fetched the
Quicksand font over HTTPS from `fonts.gstatic.com` on first launch via
the `google_fonts` package, so it was not literally network-free, and
the device's IP address reached Google in the course of that request.
"Data Not Collected" held regardless: the IP was transient request
routing, not something the app collects, stores, or uses for tracking,
advertising, or analytics. The font is now bundled in `assets/fonts/`
and the `google_fonts` dependency is gone, so builds after 1.0.1 make
no network requests at all.

## Privacy Policy URL

https://leerichardson.net/dayward-privacy/

## Support URL

https://leerichardson.net/dayward-support/

(Source drafted to `~/Downloads/dayward-support.md` — getting
started, adding the widget, FAQ, contact email. Published and
confirmed live.)

## Copyright

2026 Lee Richardson

## Bundle ID

net.leerichardson.dayscounter

## Export Compliance

Answer **No** — the app does not use encryption. It implements none of
its own. Builds after 1.0.1 make no network requests whatsoever; 1.0.1
itself made one ordinary HTTPS font fetch, which fell under the
standard exemption for platform-provided TLS rather than bundled or
implemented cryptography.

## App Review Information (contact)

- Name: Lee Richardson
- Email: l.richardson1@gmail.com
- Phone: entered directly in App Store Connect (deliberately not
  recorded here)

No demo account needed; the app has no login/accounts.

## What's New in This Version

See [listing-copy.md](listing-copy.md), which also keeps the previous
releases' notes.
