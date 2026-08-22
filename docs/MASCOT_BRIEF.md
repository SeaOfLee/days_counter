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

## Producing the SVG Deliverable

Everything above governs *what to draw*. This section governs *how to turn an
approved pose into the shipped file*. The pipeline has two stages, and they
are usually two different tools: generate or commission the pose as a raster
image, then trace that image into vector. Do not skip the first stage and draw
from the written description — a pose invented from prose is a reinterpretation
of the character, not the character.

### What to attach

1. **A PNG showing the exact pose and composition wanted.** This is the source
   of truth for pose, proportions, expression, limbs, gloves, shoes, calendar
   binding, and any confetti or motion marks.
2. **The canonical Dayward mascot SVG**, as a style and construction reference —
   confirmation of how the existing mascot is represented as flat monochrome
   vector artwork.

If either reference file is unavailable, **stop and ask for it to be attached
again.** Do not deliver an approximation based only on this brief.

### Process

1. Inspect both files before creating anything.
2. Confirm the PNG's dimensions, transparency, and artwork bounds.
3. Crop away unnecessary transparent margins without cutting off any artwork.
4. Flatten the PNG onto white solely for tracing.
5. Convert to greyscale and apply a threshold that retains the clean black
   outlines and details while removing grey shading, antialiasing artifacts,
   texture, and shadows.
6. Explicitly remove the ground shadow beneath the mascot.
7. Trace the processed black-and-white image into genuine SVG paths using
   Potrace or an equivalent vector tracer.
8. Preserve white areas as transparent negative space. The output must contain
   only one artwork colour: solid black.
9. Keep the calendar page free of dates, numbers, words, and grids, per the
   Mascot section above. The character's facial features are allowed.
10. Retain everything the source artwork shows — the pose itself, rubber-hose
    limbs, gloves, shoes, spiral binding, facial expression, and any sparse
    confetti or motion marks. Confetti and motion marks are wanted when the
    approved pose has them and they carry the meaning (celebration, movement);
    they are not licence to add decoration the source doesn't have.
11. Do not redraw or reinterpret the mascot from the written description. The
    attached pose image must be traced faithfully.
12. Do not embed the PNG inside an SVG container.

### The finished SVG must have

- Real vector paths
- A transparent background
- Solid black artwork
- No gradients, shadows, glow, filters, masks, texture, or embedded raster
- No unnecessary background rectangle
- A tight, accurate `viewBox`
- Preserved aspect ratio
- A descriptive `<title>` and `<desc>` for accessibility

### Before delivering

1. Validate the SVG as well-formed XML.
2. Render it on a white background for visual inspection.
3. Compare the render against the supplied PNG and verify that the silhouette,
   face, hands, feet, binding, and pose match.
4. Search the SVG for `<image>`, gradients, filters, masks, and patterns to
   confirm none are present.
5. If the preview is blank or solid black, correct the transparency-flattening
   step and render again.
6. Deliver the finished `.svg` and show a preview.

**"Real vector paths" means not an embedded raster — it does not mean
riggable.** A trace produces welded outline paths, which is the right delivery
format: each pose is a finished picture, scalable and recolourable, rather than
a skeleton to be re-posed. That is how the canonical SVG itself is built. Every
new pose is traced independently from its own source image.

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

**The canonical SVG is itself a trace, and that is the intended format.** It is
`potrace` output: six paths, one of which welds 26 subpaths together, with no
groups, no ids, and a single `fill="#000000"`. That is exactly what the
procedure above produces, and it is right for the job — a finished picture per
pose, flat, one colour, correct proportions and line weight, scalable and
recolourable.

What it is *not* is a rig. There is nothing inside it to pose: repositioning a
limb by editing path data does not work, because a limb is not a separate
object. Each new pose is traced independently from its own source image rather
than derived from this one.

**Reconstructing the character from primitives was tried and rejected**
(2026-08-21). A hand-authored SVG rebuild — named groups, limbs as stroked
paths, poses as coordinate edits — produced a recognisable but clearly inferior
character: flat line weight throughout, simplified gloves and shoes, and none
of the original's warmth. The trace-per-pose pipeline above replaced it. Do not
revisit rebuilding the character in code.

**Tooling on this machine.** `potrace` and ImageMagick (`magick`) are both
installed via Homebrew, covering the crop, threshold, and trace steps.

Rendering the result for inspection needs **headless Chrome** — ImageMagick's
SVG delegate shells out to `rsvg-convert`, which is *not* installed, so Magick
silently falls back to a renderer that mangles clip paths. Chrome also needs an
HTML wrapper that sizes the image: the canonical SVG declares its dimensions in
points, so screenshotting the file directly renders it at 1365px and crops.
`brew install librsvg` is the alternative.

**On delivery inside this repo.** The procedure's last step says to deliver the
file and show a preview. Here that means writing the `.svg` into the repo and
rendering a PNG next to it for inspection — an agent working in this repository
cannot hand over a download, and neither can a published artifact, where the
viewer sandbox blocks page-initiated downloads.

**Where the mascot is allowed to appear.** As of the post-V1 design pass the
mascot appears only on the iOS widget, never inside the Flutter app — an
explicit product decision, made after an earlier pass had put it on the in-app
event cards. The pose library above implies in-app usage (empty states,
onboarding, error states), so treat that decision as open for discussion rather
than settled, but do not change it as a side effect of an artwork task.
