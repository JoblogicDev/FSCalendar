#!/bin/bash

set -e

FRAMEWORK_NAME=FSCalendar
SCHEME_NAME=FSCalendar
BUILD_DIR=Build
OUTPUT_XCFRAMEWORK="$FRAMEWORK_NAME.xcframework"

# Clean previous builds
rm -rf "$BUILD_DIR" "$OUTPUT_XCFRAMEWORK"

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
# Paths inside XCFramework
DEVICE_FRAMEWORK_PATH="./$OUTPUT_XCFRAMEWORK/ios-arm64/$FRAMEWORK_NAME.framework"
SIMULATOR_FRAMEWORK_PATH="./$OUTPUT_XCFRAMEWORK/ios-arm64_x86_64-simulator/$FRAMEWORK_NAME.framework"

# Source header folders
HEADER_SOURCE_DIR="./FSCalendar"                    # Public headers
PRIVATE_HEADER_SOURCE_DIR="./FSCalendar/Private"    # Private headers

# Create header folders if missing
mkdir -p "$DEVICE_FRAMEWORK_PATH/Headers"
mkdir -p "$DEVICE_FRAMEWORK_PATH/PrivateHeaders"
mkdir -p "$SIMULATOR_FRAMEWORK_PATH/Headers"
mkdir -p "$SIMULATOR_FRAMEWORK_PATH/PrivateHeaders"

echo "📁 Copying public headers..."
cp $HEADER_SOURCE_DIR/*.h "$DEVICE_FRAMEWORK_PATH/Headers/"
cp $HEADER_SOURCE_DIR/*.h "$SIMULATOR_FRAMEWORK_PATH/Headers/"

echo "🔐 Copying private headers..."
cp $PRIVATE_HEADER_SOURCE_DIR/*.h "$DEVICE_FRAMEWORK_PATH/PrivateHeaders/"
cp $PRIVATE_HEADER_SOURCE_DIR/*.h "$SIMULATOR_FRAMEWORK_PATH/PrivateHeaders/"

echo "✅ Done! XCFramework created at: $OUTPUT_XCFRAMEWORK"
