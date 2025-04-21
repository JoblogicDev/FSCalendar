#!/bin/bash

set -e

FRAMEWORK_NAME=FSCalendar
SCHEME_NAME=FSCalendar
BUILD_DIR=Build
OUTPUT_XCFRAMEWORK="$FRAMEWORK_NAME.xcframework"
ZIP_OUTPUT="$OUTPUT_XCFRAMEWORK.zip"

# Clean previous builds
rm -rf "$BUILD_DIR" "$OUTPUT_XCFRAMEWORK" "$ZIP_OUTPUT"

echo "📦 Building $FRAMEWORK_NAME for iOS (device)..."
xcodebuild archive \
  -scheme "$SCHEME_NAME" \
  -sdk iphoneos \
  -archivePath "$BUILD_DIR/ios_devices.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "🧪 Building $FRAMEWORK_NAME for iOS Simulator..."
xcodebuild archive \
  -scheme "$SCHEME_NAME" \
  -sdk iphonesimulator \
  -archivePath "$BUILD_DIR/ios_simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$BUILD_DIR/ios_devices.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -framework "$BUILD_DIR/ios_simulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -output "$OUTPUT_XCFRAMEWORK"

# === Copy Headers ===
DEVICE_FRAMEWORK_PATH="./$OUTPUT_XCFRAMEWORK/ios-arm64/$FRAMEWORK_NAME.framework"
SIMULATOR_FRAMEWORK_PATH="./$OUTPUT_XCFRAMEWORK/ios-arm64_x86_64-simulator/$FRAMEWORK_NAME.framework"

HEADER_SOURCE_DIR="./FSCalendar"
PRIVATE_HEADER_SOURCE_DIR="./FSCalendar/Private"

mkdir -p "$DEVICE_FRAMEWORK_PATH/Headers"
mkdir -p "$DEVICE_FRAMEWORK_PATH/PrivateHeaders"
mkdir -p "$SIMULATOR_FRAMEWORK_PATH/Headers"
mkdir -p "$SIMULATOR_FRAMEWORK_PATH/PrivateHeaders"

echo "📁 Copying public headers..."
cp $HEADER_SOURCE_DIR/*.h "$DEVICE_FRAMEWORK_PATH/Headers/"
cp $HEADER_SOURCE_DIR/*.h "$SIMULATOR_FRAMEWORK_PATH/Headers/"

echo "🔐 Copying private headers..."
if compgen -G "$PRIVATE_HEADER_SOURCE_DIR/*.h" > /dev/null; then
  cp $PRIVATE_HEADER_SOURCE_DIR/*.h "$DEVICE_FRAMEWORK_PATH/PrivateHeaders/"
  cp $PRIVATE_HEADER_SOURCE_DIR/*.h "$SIMULATOR_FRAMEWORK_PATH/PrivateHeaders/"
  echo "🔐 Private headers copied."
else
  echo "⚠️  No private headers found at $PRIVATE_HEADER_SOURCE_DIR — skipping copy."
fi

# === Zip the XCFramework ===
echo "📦 Zipping $OUTPUT_XCFRAMEWORK into $ZIP_OUTPUT..."
zip -r "$ZIP_OUTPUT" "$OUTPUT_XCFRAMEWORK" > /dev/null

echo "✅ Done! Zip created at: $ZIP_OUTPUT"
