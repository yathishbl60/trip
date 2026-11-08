#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
source "$repo_root/scripts/test_destination.sh"
trip_build_root="${TRIP_BUILD_ROOT:-$repo_root/.build}"
if [[ "$trip_build_root" != /* || $# -lt 1 || $# -gt 2 || ( $# -eq 2 && "$1" != models ) ]]; then
    echo "Usage: bash scripts/test.sh [tooling|package|models] [model-test destination]" >&2
    exit 2
fi
case "$1" in
    tooling)
        python3 -m unittest discover -s "$repo_root/scripts" -p 'test_*.py'
        bash "$repo_root/scripts/test_source_audit.sh"
        ;;
    package)
        xcrun swift test --package-path "$repo_root/Packages/TripKit" \
            --scratch-path "$trip_build_root/modules"
        ;;
    models)
        trip_test_destination="${2:-${TRIP_TEST_DESTINATION:-}}"
        if [[ -z "$trip_test_destination" ]]; then
            echo "Supply a Simulator destination for model tests; no device is selected implicitly." >&2
            exit 2
        fi
        if ! validate_model_test_destination "$trip_test_destination"; then
            echo "Model checks require an iOS/visionOS Simulator platform and one explicit id or name." >&2
            exit 2
        fi
        xcodebuild -project "$repo_root/trip.xcodeproj" -scheme TripAppTests \
            -testPlan TripModels -configuration Debug -destination "$trip_test_destination" \
            -derivedDataPath "$trip_build_root/models" \
            CODE_SIGNING_ALLOWED=NO test
        ;;
    *) echo "Unknown test suite: $1" >&2; exit 2 ;;
esac
