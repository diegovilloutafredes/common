#!/usr/bin/env bash
#
# fetch-common-xcframework.sh
#
# Downloads a version of Common.xcframework from this repository's GitHub
# Releases into a local directory, intended for non-SPM consumers
# (CocoaPods + xcworkspace projects, manual vendored deps, etc.).
#
# Usage:
#   ./fetch-common-xcframework.sh                 # latest published release
#   ./fetch-common-xcframework.sh 1.3.0           # specific version
#   ./fetch-common-xcframework.sh v1.3.0          # equivalent
#
# Environment overrides:
#   COMMON_REPO   GitHub "owner/repo". Defaults to diegovilloutafredes/common
#   OUTPUT_DIR    Where Common.xcframework will land. Defaults to ./Frameworks
#   FORCE         If "1", redownload even if the target already exists at the same version
#
# Exit codes:
#   0  success
#   1  usage error / network failure / asset not found
#   2  missing required tool (curl + unzip — both ship with macOS by default)

set -euo pipefail

REPO="${COMMON_REPO:-diegovilloutafredes/common}"
OUTPUT_DIR="${OUTPUT_DIR:-Frameworks}"
FORCE="${FORCE:-0}"
REQUESTED="${1:-latest}"

# ---------- helpers ----------

err()  { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; }
info() { printf '\033[36m→ %s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓ %s\033[0m\n' "$*"; }

require() {
    command -v "$1" >/dev/null 2>&1 || { err "missing required tool: $1"; exit 2; }
}

resolve_tag() {
    # Echo the resolved git tag for the requested version, e.g. "v1.3.0".
    if [ "$REQUESTED" = "latest" ]; then
        if command -v gh >/dev/null 2>&1; then
            gh release view --repo "$REPO" --json tagName --jq .tagName
        else
            curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
                | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
                | head -n1
        fi
    else
        # Normalise "1.3.0" → "v1.3.0", leave "v1.3.0" alone.
        case "$REQUESTED" in
            v*) printf '%s' "$REQUESTED" ;;
            *)  printf 'v%s' "$REQUESTED" ;;
        esac
    fi
}

current_installed_version() {
    # If Common.xcframework already exists at OUTPUT_DIR, print the version we
    # know it was extracted from (via the marker file written below); otherwise
    # print "".
    local marker="$OUTPUT_DIR/.common-xcframework.version"
    [ -f "$marker" ] && cat "$marker" || true
}

download_asset() {
    local tag="$1"
    local asset="Common-${tag}.xcframework.zip"

    if command -v gh >/dev/null 2>&1; then
        gh release download "$tag" --repo "$REPO" --pattern "$asset" --clobber
    else
        local url="https://github.com/${REPO}/releases/download/${tag}/${asset}"
        curl -fsSL --retry 3 -o "$asset" "$url"
    fi
}

# ---------- main ----------

require curl
require unzip

TAG="$(resolve_tag)"
[ -n "$TAG" ] || { err "could not resolve version '$REQUESTED' on $REPO"; exit 1; }

info "Target: Common $TAG  (repo: $REPO  →  $OUTPUT_DIR/)"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

INSTALLED="$(current_installed_version)"
if [ "$INSTALLED" = "$TAG" ] && [ -d "Common.xcframework" ] && [ "$FORCE" != "1" ]; then
    ok "Already at $TAG — nothing to do (use FORCE=1 to redownload)"
    exit 0
fi

ASSET="Common-${TAG}.xcframework.zip"

info "Downloading $ASSET..."
download_asset "$TAG"

info "Extracting..."
rm -rf Common.xcframework
unzip -q "$ASSET"
rm "$ASSET"

# Stamp the version so future runs can short-circuit.
printf '%s\n' "$TAG" > .common-xcframework.version

ok "Installed: $(pwd)/Common.xcframework (version $TAG)"
