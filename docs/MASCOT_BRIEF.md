# Dayward Mascot — Art Direction Brief

This file is written to be handed to an agent (or a person) whole. Paste it
alongside the canonical SVG when commissioning new mascot artwork.

---

You are helping me design visual assets for **Dayward**, an iOS app for tracking meaningful dates and counting the number of days since or until them.

## Product

Dayward is a simple, friendly date-tracking utility. Examples include:

- Days since starting a job
- Days since quitting something
- Days until a vacation
- Days until an anniversary
- Personal milestones

The app is already launched on the App Store and has an established mascot and visual identity.

## Mascot

The attached SVG is the **canonical reference artwork** for the Dayward mascot.

Use it as the source of truth for the character's:

- Overall proportions
- Calendar shape
- Spiral binding
- Face
- Eyes
- Smile
- Rubber-hose-style arms and legs
- Gloves
- Shoes
- Line weight
- Retro cartoon personality

The mascot is an anthropomorphic blank calendar. Do **not** add dates, numbers, words, grids, or other details to the calendar paper unless specifically requested.

Preserve the character's identity when creating alternate poses. It should clearly look like the same character rather than a reinterpretation.

## Required Illustration Style

All new mascot artwork should be:

- **Flat**
- **Monochrome / one color**
- **Vector-style**
- Clean and highly scalable
- Bold and readable at small sizes
- Simple enough to work as UI artwork
- Consistent with the supplied SVG

Do **not** use:

- Gradients
- Shadows
- Glow
- Lighting effects
- 3D rendering
- Photorealism
- Texture
- Grain
- Multiple colors
- Complex backgrounds
- Excessive detail

Think **clean one-color brand mark / vintage mascot illustration**, not a fully rendered cartoon scene.

When an actual vector deliverable is requested, prefer clean SVG geometry with sensible paths and shapes rather than embedding a raster image inside an SVG container.

## Character Treatment

The character can be expressive and animated through pose, but the design itself should remain restrained.

Good techniques include:

- Changing arm and leg positions
- Changing eye direction
- Small facial-expression changes
- Exaggerated rubber-hose movement
- Simple motion lines
- Simple props when they communicate a feature
- Cropping or partially hiding the character
- Interacting with simple geometric UI-like objects

Avoid adding unnecessary decorative elements.

## Pose Library / Directions to Explore

Useful treatments include:

1. Walking forward while pointing
2. Running
3. Looking at a wristwatch
4. Lounging
5. Peeking over an edge
6. Jumping in celebration
7. Giving a thumbs-up
8. Presenting something with an open palm
9. Thinking with hand on chin
10. Sleeping
11. Dragging a date/card behind itself
12. Carrying a stack of calendar pages
13. Planting a milestone flag
14. Breaking through a finish line
15. Walking forward while looking backward — representing **days since**
16. Looking toward the horizon — representing **days until**
17. Tossing/flipping a calendar page
18. Holding an oversized pencil/checkmark
19. Sitting or leaning against a large number
20. Breaking outside the boundary of a rectangular frame

The **looking backward / looking forward** pair is particularly important because it can visually represent Dayward's two fundamental concepts:

- **Since:** moving onward while looking back
- **Until:** moving onward while looking ahead

## Product Usage

Artwork may eventually be used for:

- Empty states
- Onboarding
- Milestone celebrations
- Feature introductions
- Widgets
- App Store screenshots
- Settings/about screens
- Drag-and-drop interactions
- Error/success states
- Promotional material
- Alternate app icons

Design compositions with those contexts in mind. Many assets should work well without text.

## Guiding Principle

The mascot should become part of Dayward's **UI vocabulary**, not merely decoration.

A pose should ideally communicate something — looking back for elapsed time, looking ahead for upcoming dates, dragging something for drag-and-drop, celebrating for reaching a milestone, peeking for an empty state, etc.

When I request new artwork, first interpret the requested product meaning, then create the simplest expressive pose that communicates it while remaining faithful to the attached canonical SVG.

**Canonical reference:** `dayward_character_flat_black.svg`

---

## Repo notes

Context for agents working inside this repository, rather than part of the
brief above.

**Where the files are.** The canonical reference is
[docs/dayward_character_flat_black.svg](dayward_character_flat_black.svg).
The full-colour original it was traced from is
`~/Downloads/dayward_character.png`, outside the repo.

**What ships is already flat monochrome.** The widget renders
`ios/DaysCounterWidget/Assets.xcassets/Mascot.imageset/` — 150/300/450px
8-bit greyscale PNGs rasterized from the canonical SVG, a single colour plus
alpha. The style rules above therefore describe the shipped asset rather than
proposing a change to it, and new artwork drawn to this brief will sit
alongside it consistently. The colour original is not used anywhere in the
product.

**Treat the canonical SVG as a picture, not as editable geometry.** It is
`potrace` output: six paths, one of which welds 26 subpaths together, with no
groups, no ids, and a single `fill="#000000"`. It is exactly right as the
visual source of truth — flat, one colour, correct proportions and line
weight — but there is nothing inside it to pose. Attempting to reposition a
limb by editing its path data does not work.

**Reconstructing the character from primitives was tried and rejected**
(2026-08-21). A hand-authored SVG rebuild produced a recognisable but clearly
inferior character — flat line weight throughout, simplified gloves and shoes,
and none of the original's warmth. If a new pose is needed, commission it or
generate it against this brief rather than rebuilding the character in code.

**Rendering SVG on this machine needs headless Chrome.** ImageMagick's SVG
delegate shells out to `rsvg-convert`, which is not installed, so Magick
silently falls back to a renderer that mangles clip paths. Chrome also needs an
HTML wrapper that sizes the image: the canonical SVG declares its dimensions in
points, so screenshotting the file directly renders it at 1365px and crops.
`brew install librsvg` is the alternative.

**Where the mascot is allowed to appear.** As of the post-V1 design pass the
mascot appears only on the iOS widget, never inside the Flutter app — an
explicit product decision, made after an earlier pass had put it on the in-app
event cards. The pose library above implies in-app usage (empty states,
onboarding, error states), so treat that decision as open for discussion rather
than settled, but do not change it as a side effect of an artwork task.
