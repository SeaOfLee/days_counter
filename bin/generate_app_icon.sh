#!/usr/bin/env bash
set -euo pipefail

# Regenerates ios/Runner/Assets.xcassets/AppIcon.appiconset (all 15 sizes)
# from the vector mascot at docs/dayward_character_flat_black.svg, centered
# on the same pale lavender used for the widget's card background (#E3D9F3).
#
# Usage: bin/generate_app_icon.sh [mascot-size-px]
#   mascot-size-px: mascot's rendered bounding box within the 1024x1024
#                   canvas before centering (default 940).

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SVG="$REPO_ROOT/docs/dayward_character_flat_black.svg"
DEST="$REPO_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
MASCOT_SIZE="${1:-940}"
LAVENDER="#E3D9F3"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

magick -background none "$SVG" -resize "${MASCOT_SIZE}x${MASCOT_SIZE}" "$WORKDIR/fg.png"
magick -size 1024x1024 xc:"$LAVENDER" "$WORKDIR/bg.png"
magick "$WORKDIR/bg.png" "$WORKDIR/fg.png" -gravity center -composite \
  -background "$LAVENDER" -alpha remove -alpha off "$WORKDIR/master.png"

while IFS=: read -r name px; do
  [ -z "$name" ] && continue
  sips -z "$px" "$px" "$WORKDIR/master.png" --out "$DEST/$name" >/dev/null
done <<'SIZES'
Icon-App-20x20@1x.png:20
Icon-App-20x20@2x.png:40
Icon-App-20x20@3x.png:60
Icon-App-29x29@1x.png:29
Icon-App-29x29@2x.png:58
Icon-App-29x29@3x.png:87
Icon-App-40x40@1x.png:40
Icon-App-40x40@2x.png:80
Icon-App-40x40@3x.png:120
Icon-App-60x60@2x.png:120
Icon-App-60x60@3x.png:180
Icon-App-76x76@1x.png:76
Icon-App-76x76@2x.png:152
Icon-App-83.5x83.5@2x.png:167
Icon-App-1024x1024@1x.png:1024
SIZES

echo "Generated app icon at mascot size ${MASCOT_SIZE}px -> $DEST"
