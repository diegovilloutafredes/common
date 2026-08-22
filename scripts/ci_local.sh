#!/bin/bash
#
# Local mirror of .github/workflows/ci.yml's test job (CI's automatic triggers
# are temporarily disabled — this script IS the pipeline until re-enabled).
#
# Steps, same order as CI:
#   1. Generate the Xcode project
#   2. Unit tests — Common scheme (CommonTests hostless + HostedTests keychain
#      lane; ad-hoc signed, so no CODE_SIGNING_ALLOWED=NO here)
#   3. Release gate tests — Common-ReleaseGates scheme, Release config,
#      ENABLE_TESTABILITY=YES (symbol access only; DEBUG stays undefined)
#   4. DemoApp compile check
#   5. XCFramework build (Release archives; validates distribution compile)
#
# Not mirrored: the docs job (Jazzy → gh-pages) — deploy-only, regenerates when
# CI is re-enabled or via `jazzy` manually.
# -o pipefail is load-bearing: the test steps pipe xcodebuild into grep/tail,
# and without it a failing suite would exit through tail's status 0 — the
# script would print the failures and still declare the pipeline green.
set -eo pipefail
cd "$(dirname "$0")/.."

DESTINATION="${CI_LOCAL_DESTINATION:-platform=iOS Simulator,name=iPhone 17}"

echo "▶ [1/5] xcodegen generate"
xcodegen generate

echo "▶ [2/5] Unit tests (Common scheme: CommonTests + HostedTests)"
xcodebuild test \
  -scheme Common \
  -project Common.xcodeproj \
  -destination "$DESTINATION" \
  | grep -E "Test Suite|Executed|error:|failed" | tail -12

echo "▶ [3/5] Release gate tests"
xcodebuild test \
  -scheme Common-ReleaseGates \
  -project Common.xcodeproj \
  -destination "$DESTINATION" \
  -only-testing:CommonTests/ReleaseGateTests \
  ENABLE_TESTABILITY=YES \
  | grep -E "Test Suite|Executed|error:|failed" | tail -6

echo "▶ [4/5] DemoApp build"
xcodebuild build -quiet \
  -scheme DemoApp \
  -project Common.xcodeproj \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

echo "▶ [5/5] XCFramework build (temp output — the tracked XCFramework/ binary"
echo "        is the tag-committed one and must NOT be overwritten between releases)"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
for SDK in iphoneos iphonesimulator; do
  xcodebuild archive -quiet \
    -scheme Common \
    -project Common.xcodeproj \
    -archivePath "$TMP_DIR/Common-$SDK.xcarchive" \
    -sdk "$SDK" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="-"
done
xcodebuild -create-xcframework \
  -framework "$TMP_DIR/Common-iphoneos.xcarchive/Products/Library/Frameworks/Common.framework" \
  -framework "$TMP_DIR/Common-iphonesimulator.xcarchive/Products/Library/Frameworks/Common.framework" \
  -output "$TMP_DIR/Common.xcframework"

echo "✅ Local CI passed"
