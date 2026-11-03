#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
mode="${1:-all}"
report_path="${2:-$repo_root/.build/performance/latest.json}"
if [[ $# -gt 2 || ! "$mode" =~ ^(all|check|benchmark|system-check)$ ]]; then
    echo "Usage: bash scripts/performance.sh [all|check|benchmark|system-check] [report.json]" >&2
    exit 2
fi
if [[ "$(uname -s)" != Darwin ]]; then
    echo "This harness requires macOS and Xcode 27 / Swift 6.4 (MapKit)." >&2
    exit 2
fi
command -v python3 >/dev/null
xcrun --sdk macosx --find swiftc >/dev/null
build_dir="$repo_root/.build/performance"
mkdir -p "$build_dir"
run_dir="$(mktemp -d "$build_dir/run.XXXXXX")"
localization_bundle="$run_dir/TripLocalization.bundle"
mkdir -p "$localization_bundle"
xcrun xcstringstool compile \
    "$repo_root/Packages/TripKit/Sources/TripLocalization/Resources/Localizable.xcstrings" \
    --output-directory "$localization_bundle"
python3 -c 'import plistlib,sys; plistlib.dump({"CFBundleDevelopmentRegion":"en"}, open(sys.argv[1], "wb"))' \
    "$localization_bundle/Info.plist"
sources=()
while IFS= read -r source; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    sources+=("$repo_root/$source")
done < "$repo_root/Performance/sources.txt"

echo "Compiling the current production algorithms with Swift 6 strict concurrency and -O."
xcrun --sdk macosx swiftc -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
    -D TRIP_STANDALONE -O -whole-module-optimization -parse-as-library -swift-version 6 \
    -strict-concurrency=complete -default-isolation MainActor \
    -enable-upcoming-feature MemberImportVisibility \
    -module-cache-path "$build_dir/ModuleCache" \
    "${sources[@]}" "$repo_root"/Performance/*.swift -o "$run_dir/performance-runner"
TRIP_LOCALIZATION_BUNDLE="$localization_bundle" "$run_dir/performance-runner" "$mode" "$run_dir/raw.json"
if [[ "$mode" == check || "$mode" == all ]]; then
    python3 "$repo_root/scripts/test_performance_comparison.py"
fi
if [[ "$mode" == benchmark || "$mode" == all ]]; then
    python3 "$repo_root/scripts/performance_report.py" "$run_dir/raw.json" "$report_path"
fi
