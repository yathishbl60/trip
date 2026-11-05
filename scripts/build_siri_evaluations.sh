#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
configuration="${1:-Debug}"
if [[ $# -gt 1 || ! "$configuration" =~ ^(Debug|Release)$ ]]; then
    echo "Usage: bash scripts/build_siri_evaluations.sh [Debug|Release]" >&2
    exit 2
fi

# Compile and link the host, widget, and Siri test bundle; never execute tests.
xcodebuild -project "$repo_root/trip.xcodeproj" -scheme TripSiriEvaluations \
    -configuration "$configuration" -sdk iphoneos -destination 'generic/platform=iOS' \
    -derivedDataPath "$repo_root/.build/siri-evaluations/xcode" \
    CODE_SIGNING_ALLOWED=NO build-for-testing
