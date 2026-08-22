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
- Give each widget its own event, and stack several to swipe between them
- Enter a date from the calendar, or just say how many days away it is
- Drag your events into whatever order suits you
- Get a reminder on the morning a countdown arrives
- Milestone days look the part — reaching one changes how the event reads
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

## What's New in This Version (1.2.0)

Release notes for the version page in App Store Connect. 1.1.0 already
shipped configurable widgets, drag-to-reorder, relative day entry and the
dark-mode fixes, so these cover only what is new since.

```text
Milestone days now look like milestones. The day you've been counting
down to reads "Today" instead of zero, and round-number days — 100, 365,
1,000 — stand out on your Home Screen widget and in your list.

You can also turn on a reminder for anything you're counting down to, and
Dayward will tell you on the morning it arrives. Reminders are scheduled
on your device and never leave it — and they don't name the event, so
nothing private ends up on your lock screen.
```

Note on the reminder wording: the notification text really is generic
("Dayward — Today's the day"), and the release note says so deliberately
rather than overselling it. It's a lock-screen privacy decision, not a
limitation to hide.
