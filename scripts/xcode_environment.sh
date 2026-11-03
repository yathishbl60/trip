#!/usr/bin/env bash
# Source this file; respect explicit toolchain choices without changing xcode-select.
if [[ -z "${DEVELOPER_DIR:-}" ]]; then
    trip_selected_developer="$(xcode-select -p 2>/dev/null || true)"
    if [[ ! -x "$trip_selected_developer/usr/bin/xcodebuild" ]]; then
        for trip_xcode in /Applications/Xcode.app /Applications/Xcode-beta.app; do
            if [[ -x "$trip_xcode/Contents/Developer/usr/bin/xcodebuild" ]]; then
                export DEVELOPER_DIR="$trip_xcode/Contents/Developer"
                break
            fi
        done
    fi
fi
unset trip_selected_developer trip_xcode
