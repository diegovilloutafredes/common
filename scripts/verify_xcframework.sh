#!/bin/bash
#
# Usage: scripts/verify_xcframework.sh <path/to/Common.xcframework> [version]
#
# Verifies that a built Common.xcframework is what a consumer can import:
#   1. Info.plist and both slices (device, simulator) are present
#   2. with [version], each slice's CFBundleShortVersionString equals it
#   3. an `import Common` probe type-checks against every interface triple in
#      the framework, with the active compiler and a fresh module cache — the
#      binary ships only textual interfaces, so this is exactly the compilation
#      a consumer's compiler performs (a cache from an earlier run could mask a
#      broken interface, hence fresh)
#
# Runs in `make ci` (on its temporary xcframework), in release.sh (before the
# binary is committed) and in release.yml (on the tag-committed binary).
set -euo pipefail

XCFRAMEWORK=${1:?usage: scripts/verify_xcframework.sh <xcframework> [version]}
VERSION=${2:-}
SLICES=(ios-arm64 ios-arm64_x86_64-simulator)

fail() { echo "❌ verify_xcframework: $*" >&2; exit 1; }

[[ -f "$XCFRAMEWORK/Info.plist" ]] || fail "missing $XCFRAMEWORK/Info.plist"
for SLICE in "${SLICES[@]}"; do
  [[ -d "$XCFRAMEWORK/$SLICE/Common.framework" ]] || fail "missing slice $SLICE"
done

if [[ -n "$VERSION" ]]; then
  for SLICE in "${SLICES[@]}"; do
    ACTUAL=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$XCFRAMEWORK/$SLICE/Common.framework/Info.plist")
    [[ "$ACTUAL" == "$VERSION" ]] || fail "$SLICE reports bundle version $ACTUAL, expected $VERSION"
  done
fi

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
# BaseCoordinator: a long-standing public type, so the probe resolves a symbol, not just the module.
printf 'import Common\n_ = BaseCoordinator.self\n' > "$WORK_DIR/probe.swift"

for SLICE in "${SLICES[@]}"; do
  INTERFACES=()
  for INTERFACE in "$XCFRAMEWORK/$SLICE"/Common.framework/Modules/Common.swiftmodule/*.swiftinterface; do
    if [[ -f "$INTERFACE" && "$INTERFACE" != *.private.swiftinterface ]]; then INTERFACES+=("$INTERFACE"); fi
  done
  [[ ${#INTERFACES[@]} -gt 0 ]] || fail "$SLICE ships no .swiftinterface (was it built with BUILD_LIBRARY_FOR_DISTRIBUTION=YES?)"

  for INTERFACE in "${INTERFACES[@]}"; do
    TRIPLE=$(basename "$INTERFACE" .swiftinterface)
    # The interface records the target it was built for (e.g. arm64-apple-ios16.0-simulator).
    TARGET=$(sed -n 's/^\/\/ swift-module-flags:.* -target \([^ ]*\).*/\1/p' "$INTERFACE")
    [[ -n "$TARGET" ]] || fail "$TRIPLE: no -target in the interface's swift-module-flags"
    if [[ "$TRIPLE" == *-simulator ]]; then SDK=iphonesimulator; else SDK=iphoneos; fi

    echo "  import Common → $TRIPLE"
    xcrun --sdk "$SDK" swiftc -typecheck \
      -sdk "$(xcrun --sdk "$SDK" --show-sdk-path)" \
      -target "$TARGET" \
      -F "$XCFRAMEWORK/$SLICE" \
      -module-cache-path "$WORK_DIR/ModuleCache" \
      "$WORK_DIR/probe.swift" \
      || fail "import Common does not type-check for $TRIPLE"
  done
done

echo "✅ $XCFRAMEWORK imports on every slice${VERSION:+ and reports version $VERSION}"
