#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/scripts/xcode_environment.sh"
swift_binary="$(xcrun --find swift)"
host_libraries="$(dirname -- "$swift_binary")/../lib/swift/host"
audit_cache="$repo_root/.build/audit/ModuleCache"
mkdir -p "$audit_cache"
audit_source="$(mktemp "$repo_root/.build/audit/source-audit.XXXXXX")"
trap 'rm -f "$audit_source"' EXIT
cat "$repo_root/scripts/SourceAudit/MemberAudit.swift" "$repo_root/scripts/SourceAudit/PreviewAudit.swift" \
    "$repo_root/scripts/audit_sources.swift" > "$audit_source"

"$swift_binary" -module-cache-path "$audit_cache" \
    -I "$host_libraries" -L "$host_libraries" -lSwiftSyntax -lSwiftParser \
    "$audit_source" "$repo_root"
