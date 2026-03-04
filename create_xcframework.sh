ARCHIVES_DIR="Archives"
SCHEME="Common"
XCFRAMEWORK_NAME="Common"
XCFRAMEWORK_DIR="XCFramework"

rm -rf $ARCHIVES_DIR

# Archive for iOS Device
xcodebuild archive \
-scheme $SCHEME \
-archivePath $ARCHIVES_DIR/$SCHEME-iphoneos.xcarchive \
-sdk iphoneos \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO

# Archive for iOS Simulator
xcodebuild archive \
-scheme $SCHEME \
-archivePath $ARCHIVES_DIR/$SCHEME-iphonesimulator.xcarchive \
-sdk iphonesimulator \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
SKIP_INSTALL=NO

rm -rf $XCFRAMEWORK_DIR/$SCHEME.xcframework

# Create XCFramework
xcodebuild -create-xcframework \
-framework $ARCHIVES_DIR/$SCHEME-iphoneos.xcarchive/Products/Library/Frameworks/$SCHEME.framework \
-framework $ARCHIVES_DIR/$SCHEME-iphonesimulator.xcarchive/Products/Library/Frameworks/$SCHEME.framework \
-output $XCFRAMEWORK_DIR/$XCFRAMEWORK_NAME.xcframework

rm -rf $ARCHIVES_DIR