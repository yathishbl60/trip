#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="$repo_root/.build/annotation-preview"
mkdir -p "$build_dir/ModuleCache"
xcrun actool "$repo_root/trip/Assets.xcassets" --compile "$build_dir" \
    --platform macosx --minimum-deployment-target 27.0 --target-device mac \
    --output-format human-readable-text > "$build_dir/assets.log" 2>&1

sources=(
    trip/Shared/Places/PlaceCategory+Appearance.swift
    trip/Shared/Places/Place+Annotation.swift
    Packages/TripKit/Sources/TripDomain/Places/Coordinate.swift
    Packages/TripKit/Sources/TripDomain/Places/Place.swift
    Packages/TripKit/Sources/TripDomain/Places/PlaceCategory.swift
    Packages/TripKit/Sources/MapEngine/Configuration/MapMotion.swift
    Packages/TripKit/Sources/MapEngine/Layout/MarkerStyle.swift
    Packages/TripKit/Sources/MapEngine/Layout/MarkerStyle+Appearance.swift
)
for index in "${!sources[@]}"; do sources[$index]="$repo_root/${sources[$index]}"; done
xcrun --sdk macosx swiftc -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
    -D TRIP_STANDALONE -O -parse-as-library -swift-version 6 -strict-concurrency=complete \
    -default-isolation MainActor -enable-upcoming-feature MemberImportVisibility \
    -module-cache-path "$build_dir/ModuleCache" "${sources[@]}" \
    "$repo_root"/trip/Features/Explore/Views/Markers/*.swift "$repo_root"/scripts/AnnotationPreview/*.swift \
    -o "$build_dir/annotation-preview"
"$build_dir/annotation-preview" "$build_dir"
