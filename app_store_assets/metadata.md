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

Answer **"Data Not Collected"** across the board. This is accurate,
not just convenient: the app has no networking code anywhere
(verified via `grep -r "http\|Socket\|URLSession" lib/ ios/`), no
accounts, and no analytics/third-party SDKs.

## Privacy Policy URL

https://leerichardson.net/dayward-privacy/

## Bundle ID

net.leerichardson.dayscounter
