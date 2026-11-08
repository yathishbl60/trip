#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
swift_binary="$(xcrun --find swift)"
host_libraries="$(dirname -- "$swift_binary")/../lib/swift/host"
mkdir -p "$repo_root/.build/audit/ModuleCache"
test_source="$(mktemp "$repo_root/.build/audit/preview-tests.XXXXXX")"
trap 'rm -f "$test_source"' EXIT
cat "$repo_root/scripts/SourceAudit/PreviewAudit.swift" \
    "$repo_root/scripts/SourceAudit/PreviewAuditTests.swift" > "$test_source"
"$swift_binary" -module-cache-path "$repo_root/.build/audit/ModuleCache" \
    -I "$host_libraries" -L "$host_libraries" -lSwiftSyntax -lSwiftParser "$test_source"
