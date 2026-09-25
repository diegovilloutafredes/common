#!/bin/bash
#
# Builds XCFramework/Common.xcframework from device + simulator Release archives.
# The xcframework is assembled in Archives/ and replaces the tracked copy only
# after -create-xcframework succeeds, so a failed build never removes it.
# COMMON_VERSION=x.y.z (set by release.sh) stamps MARKETING_VERSION and
# CURRENT_PROJECT_VERSION; unset, the bundle keeps project.yml's version.
set -euo pipefail
cd "$(dirname "$0")"

ARCHIVES_DIR="Archives"
SCHEME="Common"
XCFRAMEWORK_NAME="Common"
XCFRAMEWORK_DIR="XCFramework"

VERSION_SETTINGS=()
if [[ -n "${COMMON_VERSION:-}" ]]; then
    VERSION_SETTINGS=(MARKETING_VERSION="$COMMON_VERSION" CURRENT_PROJECT_VERSION="$COMMON_VERSION")
fi

rm -rf $ARCHIVES_DIR

# Archive for iOS Device
echo "Archiving for iOS..."
xcodebuild archive -quiet \
-scheme $SCHEME \
-project Common.xcodeproj \
-archivePath $ARCHIVES_DIR/$SCHEME-iphoneos.xcarchive \
-sdk iphoneos \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO \
CODE_SIGNING_ALLOWED=NO \
CODE_SIGN_IDENTITY="-" \
${VERSION_SETTINGS[@]+"${VERSION_SETTINGS[@]}"}

# Archive for iOS Simulator
echo "Archiving for iOS Simulator..."
xcodebuild archive -quiet \
-scheme $SCHEME \
-project Common.xcodeproj \
-archivePath $ARCHIVES_DIR/$SCHEME-iphonesimulator.xcarchive \
-sdk iphonesimulator \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO \
CODE_SIGNING_ALLOWED=NO \
CODE_SIGN_IDENTITY="-" \
${VERSION_SETTINGS[@]+"${VERSION_SETTINGS[@]}"}

echo "Creating XCFramework..."
xcodebuild -create-xcframework \
-framework $ARCHIVES_DIR/$SCHEME-iphoneos.xcarchive/Products/Library/Frameworks/$SCHEME.framework \
-framework $ARCHIVES_DIR/$SCHEME-iphonesimulator.xcarchive/Products/Library/Frameworks/$SCHEME.framework \
-output $ARCHIVES_DIR/$XCFRAMEWORK_NAME.xcframework

# Assembly succeeded: only now replace the tracked binary.
mkdir -p $XCFRAMEWORK_DIR
rm -rf $XCFRAMEWORK_DIR/$XCFRAMEWORK_NAME.xcframework
mv $ARCHIVES_DIR/$XCFRAMEWORK_NAME.xcframework $XCFRAMEWORK_DIR/

rm -rf $ARCHIVES_DIR
echo "Finished!"
