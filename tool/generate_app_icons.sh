#!/usr/bin/env bash
# Regenerates the app launcher icons from the master 1024px source.
# Design: dark radial gradient, white "?", purple orbit arc with cyan accent.
# Requires ImageMagick (`brew install imagemagick`).
set -euo pipefail

cd "$(dirname "$0")/.."
MASTER="assets/icon/icon-1024.png"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Rebuild the master icon from scratch (edit colours/layout here).
magick -size 1024x1024 radial-gradient:'#3A4780-#0B1020' "$TMP/bg.png"
magick "$TMP/bg.png" -stroke '#8E72FF' -strokewidth 42 -fill none \
  -draw "arc 152,152 872,872 340,640" "$TMP/step1.png"
magick "$TMP/step1.png" -stroke '#29C7D8' -strokewidth 22 -fill none \
  -draw "arc 116,116 908,908 288,352" "$TMP/step2.png"
magick "$TMP/step2.png" -fill '#8E72FF' \
  -draw "circle 850,389 862,389" "$TMP/step3.png"
magick "$TMP/step3.png" -fill '#29C7D8' \
  -draw "circle 815,257 827,257" "$TMP/base.png"

magick -size 1024x1024 xc:none \
  -font "/System/Library/Fonts/Helvetica.ttc" -pointsize 640 \
  -fill white -gravity center -annotate +0+40 "?" \
  PNG32:"$TMP/q.png"

magick composite -compose over "$TMP/q.png" "$TMP/base.png" "$MASTER"

IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
for spec in \
  "20x20@1x:20" "20x20@2x:40" "20x20@3x:60" \
  "29x29@1x:29" "29x29@2x:58" "29x29@3x:87" \
  "40x40@1x:40" "40x40@2x:80" "40x40@3x:120" \
  "60x60@2x:120" "60x60@3x:180" \
  "76x76@1x:76" "76x76@2x:152" "83.5x83.5@2x:167" \
  "1024x1024@1x:1024"; do
  name="${spec%%:*}"
  size="${spec##*:}"
  magick "$MASTER" -resize "${size}x${size}" "$IOS_DIR/Icon-App-${name}.png"
done

for spec in "mdpi:48" "hdpi:72" "xhdpi:96" "xxhdpi:144" "xxxhdpi:192"; do
  density="${spec%%:*}"
  size="${spec##*:}"
  magick "$MASTER" -resize "${size}x${size}" \
    "android/app/src/main/res/mipmap-${density}/ic_launcher.png"
done

echo "App icons regenerated."
