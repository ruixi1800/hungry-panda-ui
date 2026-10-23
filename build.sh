#!/bin/bash
# 编译并打包 HungryPanda.app（Intel + Apple Silicon 通用二进制，ad-hoc 签名）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

APP="$ROOT/HungryPanda.app"
BUILD="$ROOT/.build"
TARGET_MACOS="14.0"

rm -rf "$BUILD" "$APP"
mkdir -p "$BUILD"

echo "==> 编译 Swift 源码…"
for arch in arm64 x86_64; do
  echo "    - $arch"
  swiftc -O -swift-version 5 -parse-as-library \
    -target "${arch}-apple-macos${TARGET_MACOS}" \
    -o "$BUILD/HungryPanda-$arch" \
    Sources/*.swift
done

lipo -create "$BUILD/HungryPanda-arm64" "$BUILD/HungryPanda-x86_64" \
  -output "$BUILD/HungryPanda"

echo "==> 组装 App 包…"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BUILD/HungryPanda" "$APP/Contents/MacOS/HungryPanda"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
cp "$ROOT/Resources/cover.jpg" "$APP/Contents/Resources/cover.jpg"
cp "$ROOT"/Resources/fruits/*.png "$APP/Contents/Resources/"
mkdir -p "$APP/Contents/Resources/audio"
cp "$ROOT"/Resources/audio/*.mp3 "$APP/Contents/Resources/audio/"

echo "==> 签名（ad-hoc）…"
codesign --force --sign - --timestamp=none "$APP" >/dev/null 2>&1 || \
  codesign --force --sign - "$APP"

echo "==> 完成：$APP"
du -sh "$APP"
