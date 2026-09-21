#!/bin/bash
set -e
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$PROJECT_DIR/build"
mkdir -p "/Users/mapmac/studio-projects/customjarvis/apks"

# Build number tracking
BUILD_FILE="$PROJECT_DIR/.build_number"
if [ ! -f "$BUILD_FILE" ]; then
    echo "1" > "$BUILD_FILE"
fi
BUILD_NO=$(cat "$BUILD_FILE")
DATE_STR=$(date +"%Y%m%d")
TIME_STR=$(date +"%H%M")
APK_NAME="TumbleHeroes_b${BUILD_NO}_${DATE_STR}.apk"

echo "=========================================="
echo "🎮 Building Tumble Heroes Android APK"
echo "🔢 Build Number: $BUILD_NO"
echo "📅 Date: $DATE_STR ($TIME_STR)"
echo "📦 Output: $APK_NAME"
echo "=========================================="

# Export debug APK
godot --headless --path "$PROJECT_DIR" --export-debug "Android" "$PROJECT_DIR/build/$APK_NAME"

# Sign with Android v2/v3 signatures
APKSIGNER="/Users/mapmac/Library/Android/sdk/build-tools/35.0.0/apksigner"
if [ -f "$APKSIGNER" ]; then
    echo "Signing with APK Signature Scheme v2/v3..."
    "$APKSIGNER" sign --ks ~/.android/debug.keystore --ks-pass pass:android --key-pass pass:android --ks-key-alias androiddebugkey "$PROJECT_DIR/build/$APK_NAME"
    "$APKSIGNER" verify "$PROJECT_DIR/build/$APK_NAME"
fi

# Copy to global apks directory
cp -f "$PROJECT_DIR/build/$APK_NAME" "/Users/mapmac/studio-projects/customjarvis/apks/$APK_NAME"
cp -f "$PROJECT_DIR/build/$APK_NAME" "/Users/mapmac/studio-projects/customjarvis/apks/TumbleHeroes.apk"
cp -f "$PROJECT_DIR/build/$APK_NAME" "$PROJECT_DIR/build/TumbleHeroes.apk"

# Increment build number for next time
echo $((BUILD_NO + 1)) > "$BUILD_FILE"

echo "=========================================="
echo "🎉 APK built & signed successfully!"
echo "File: /Users/mapmac/studio-projects/customjarvis/apks/$APK_NAME"
echo "Size: $(du -h "/Users/mapmac/studio-projects/customjarvis/apks/$APK_NAME" | cut -f1)"
echo "=========================================="
