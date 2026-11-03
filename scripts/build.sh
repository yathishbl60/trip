#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
target="${1:-app}"
configuration="${2:-Debug}"
if [[ $# -gt 2 || ! "$configuration" =~ ^(Debug|Release)$ ]]; then
    echo "Usage: bash scripts/build.sh [app|visionOS|TripLocalization|TripDomain|TripRouting|MapEngine|TripStorage|TripIntelligence|TripIntegrations] [Debug|Release]" >&2
    exit 2
fi
case "$target" in
    app)
        xcodebuild -project "$repo_root/trip.xcodeproj" -scheme trip \
            -configuration "$configuration" -destination 'generic/platform=iOS Simulator' \
            -derivedDataPath "$repo_root/.build/xcode" -parallelizeTargets \
            CODE_SIGNING_ALLOWED=NO build
        ;;
    visionOS)
        xcodebuild -project "$repo_root/trip.xcodeproj" -scheme trip \
            -configuration "$configuration" -destination 'generic/platform=visionOS Simulator' \
            -derivedDataPath "$repo_root/.build/visionos" -parallelizeTargets \
            CODE_SIGNING_ALLOWED=NO build
        ;;
    TripLocalization|TripDomain|TripRouting|MapEngine|TripStorage|TripIntelligence|TripIntegrations)
        package_configuration="debug"
        [[ "$configuration" == Release ]] && package_configuration="release"
        xcrun swift build --package-path "$repo_root/Packages/TripKit" \
            --scratch-path "$repo_root/.build/modules" --target "$target" \
            --configuration "$package_configuration"
        ;;
    *)
        echo "Unknown target: $target" >&2
        exit 2
        ;;
esac
