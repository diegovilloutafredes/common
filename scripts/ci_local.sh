#!/bin/bash
#
# Local mirror of .github/workflows/ci.yml's test job (CI's automatic triggers
# are temporarily disabled — this script IS the pipeline until re-enabled).
#
# Prints the Xcode version, then runs the test lanes on a dedicated `Common-CI`
# simulator: created on first use on the newest installed iOS runtime, so other
# projects testing on the shared "iPhone 17" can't collide with this run.
# CI_LOCAL_DESTINATION overrides the destination.
#
# Steps, same order as CI:
#   1. Generate the Xcode project
#   2. Unit tests — Common scheme (CommonTests hostless + HostedTests keychain
#      lane; ad-hoc signed, so no CODE_SIGNING_ALLOWED=NO here)
#   3. Release gate tests — Common-ReleaseGates scheme, Release config,
#      ENABLE_TESTABILITY=YES (symbol access only; DEBUG stays undefined). Judged
#      from the result bundle: at least one test run, none skipped, none failed
#   4. DemoApp compile check (Debug and Release schemes)
#   5. XCFramework build (Release archives; validates distribution compile) and
#      import check (scripts/verify_xcframework.sh)
#
# Not mirrored: the docs job (Jazzy → gh-pages) — deploy-only, regenerates when
# CI is re-enabled or via `jazzy` manually.
# -o pipefail is load-bearing: the test steps pipe xcodebuild into grep/tail,
# and without it a failing suite would exit through tail's status 0 — the
# script would print the failures and still declare the pipeline green.
set -eo pipefail
cd "$(dirname "$0")/.."

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Prints the UDID of the `Common-CI` simulator on the newest installed iOS
# runtime, creating it (newest plain "iPhone N" model) when missing.
common_ci_simulator() {
  python3 - <<'PY'
import json, re, subprocess

def simctl_list(kind):
    return json.loads(subprocess.check_output(["xcrun", "simctl", "list", kind, "-j"]))[kind]

runtime = max((r for r in simctl_list("runtimes") if r["platform"] == "iOS" and r["isAvailable"]),
              key=lambda r: [int(part) for part in r["version"].split(".")])
for device in simctl_list("devices").get(runtime["identifier"], []):
    if device["name"] == "Common-CI" and device["isAvailable"]:
        print(device["udid"])
        break
else:
    models = [(int(m.group(1)), t["identifier"]) for t in runtime["supportedDeviceTypes"]
              if (m := re.fullmatch(r"iPhone (\d+)", t["name"]))]
    print(subprocess.check_output(["xcrun", "simctl", "create", "Common-CI", max(models)[1], runtime["identifier"]],
                                  text=True).strip())
PY
}

xcodebuild -version
if [[ -n "$CI_LOCAL_DESTINATION" ]]; then
  DESTINATION="$CI_LOCAL_DESTINATION"
else
  DESTINATION="platform=iOS Simulator,id=$(common_ci_simulator)"
fi
echo "Destination: $DESTINATION"

echo "▶ [1/5] xcodegen generate"
xcodegen generate

echo "▶ [2/5] Unit tests (Common scheme: CommonTests + HostedTests)"
xcodebuild test \
  -scheme Common \
  -project Common.xcodeproj \
  -destination "$DESTINATION" \
  | grep -E "Test Suite|Executed|error:|failed" | tail -12

echo "▶ [3/5] Release gate tests (at least one run, none skipped)"
xcodebuild test \
  -scheme Common-ReleaseGates \
  -project Common.xcodeproj \
  -destination "$DESTINATION" \
  -only-testing:CommonTests/ReleaseGateTests \
  -resultBundlePath "$TMP_DIR/ReleaseGates.xcresult" \
  ENABLE_TESTABILITY=YES \
  | grep -E "Test Suite|Executed|error:|failed" | tail -6
# A renamed test class runs zero tests and a DEBUG leak into Release skips them
# all — both exit 0, so the lane is judged from its result bundle.
xcrun xcresulttool get test-results summary --path "$TMP_DIR/ReleaseGates.xcresult" | python3 -c '
import json, sys
summary = json.load(sys.stdin)
total, skipped, failed = (summary.get(key, 0) for key in ("totalTestCount", "skippedTests", "failedTests"))
result = f"{total} run, {skipped} skipped, {failed} failed"
if total == 0 or skipped or failed:
    sys.exit(f"❌ Release gate lane must run at least one test and skip none: {result}")
print(f"  Release gates: {result}")'

echo "▶ [4/5] DemoApp build (Debug + Release)"
xcodebuild build -quiet \
  -scheme DemoApp \
  -project Common.xcodeproj \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
# Release catches demo code that only compiles under DEBUG (e.g. Debug-only Logger helpers).
xcodebuild build -quiet \
  -scheme DemoApp-Release \
  -project Common.xcodeproj \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

echo "▶ [5/5] XCFramework build + import check (temp output — the tracked XCFramework/"
echo "        binary is the tag-committed one and must NOT be overwritten between releases)"
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
scripts/verify_xcframework.sh "$TMP_DIR/Common.xcframework"

echo "✅ Local CI passed"
