#!/usr/bin/env bash

# Validate without invoking Xcode or choosing a device on the caller's behalf.
validate_model_test_destination() {
    local destination="$1" field key value platform="" identity="" seen="," fields
    IFS=',' read -r -a fields <<< "$destination"
    [[ "$destination" != *, && ${#fields[@]} -ge 2 ]] || return 1
    for field in "${fields[@]}"; do
        [[ "$field" == *=* ]] || return 1
        key="${field%%=*}"
        value="${field#*=}"
        [[ -n "$value" && "$seen" != *",$key,"* ]] || return 1
        seen+="$key,"
        case "$key" in
            platform) platform="$value" ;;
            id|name)
                [[ -z "$identity" ]] || return 1
                identity="$value"
                ;;
            OS|arch) ;;
            *) return 1 ;;
        esac
    done
    [[ -n "$identity" && ( "$platform" == 'iOS Simulator' || "$platform" == 'visionOS Simulator' ) ]]
}
