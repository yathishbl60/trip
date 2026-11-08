#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
target="${1:-app}"
configuration="${2:-Debug}"
trip_build_root="${TRIP_BUILD_ROOT:-$repo_root/.build}"
if [[ "$trip_build_root" != /* ]]; then
    echo "TRIP_BUILD_ROOT must be an absolute path." >&2
    exit 2
fi
if [[ $# -gt 2 || ! "$configuration" =~ ^(Debug|Release)$ ]]; then
    echo "Usage: bash scripts/build.sh [app|visionOS|models|TripLocalization|TripDomain|TripPlaces|TripRouting|MapEngine|TripStorage|TripIntelligence|TripIntegrations] [Debug|Release]" >&2
    exit 2
fi
case "$target" in
    app)
        xcodebuild -project "$repo_root/trip.xcodeproj" -scheme trip \
            -configuration "$configuration" -destination 'generic/platform=iOS Simulator' \
            -derivedDataPath "$trip_build_root/xcode" -parallelizeTargets \
            CODE_SIGNING_ALLOWED=NO build
        ;;
    visionOS)
        xcodebuild -project "$repo_root/trip.xcodeproj" -scheme trip \
            -configuration "$configuration" -destination 'generic/platform=visionOS Simulator' \
            -derivedDataPath "$trip_build_root/visionos" -parallelizeTargets \
            CODE_SIGNING_ALLOWED=NO build
        ;;
    models)
        xcodebuild -project "$repo_root/trip.xcodeproj" -scheme TripAppTests \
            -configuration "$configuration" -destination 'generic/platform=iOS Simulator' \
            -derivedDataPath "$trip_build_root/models" -parallelizeTargets \
            CODE_SIGNING_ALLOWED=NO build-for-testing
        ;;
    TripLocalization|TripDomain|TripPlaces|TripRouting|MapEngine|TripStorage|TripIntelligence|TripIntegrations)
        package_configuration="debug"
        [[ "$configuration" == Release ]] && package_configuration="release"
        xcrun swift build --package-path "$repo_root/Packages/TripKit" \
            --scratch-path "$trip_build_root/modules" --target "$target" \
            --configuration "$package_configuration"
        ;;
    *)
        echo "Unknown target: $target" >&2
        exit 2
        ;;
esac
