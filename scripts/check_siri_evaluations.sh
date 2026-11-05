#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
sdk_path="$(xcrun --sdk iphoneos --show-sdk-path)"
platform_path="$(xcrun --sdk iphoneos --show-sdk-platform-path)"
compiler_path="$(xcrun --sdk iphoneos --find swiftc)"
testing_plugins="$(dirname -- "$compiler_path")/../lib/swift/host/plugins/testing"
build_dir="$repo_root/.build/siri-evaluations"
mkdir -p "$build_dir/ModuleCache"

# Compile public evaluation APIs without adding a test target or driving a device.
xcrun --sdk iphoneos swiftc -typecheck -parse-as-library -swift-version 6 \
    -strict-concurrency=complete -enable-upcoming-feature MemberImportVisibility \
    -target arm64-apple-ios27.3 -sdk "$sdk_path" \
    -plugin-path "$testing_plugins" \
    -F "$platform_path/Developer/Library/Frameworks" \
    -module-cache-path "$build_dir/ModuleCache" \
    "$repo_root"/Performance/SiriEvaluations/*.swift

echo "Siri evaluation sources type-check for iOS 27.3; no device scenarios were run."
