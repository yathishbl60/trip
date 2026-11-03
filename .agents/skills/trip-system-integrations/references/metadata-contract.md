# Trip App Intents metadata contracts

General static DSL rules and the recorded Xcode 27.2 KeyPath-interpolation issue live
in global `app-development` system-integration guidance. Recheck that SDK issue on toolchain changes.

- Preserve OpenSavedTripIntent's parameterized Summary and SavedTripEntity parameter type.
- Keep TripShortcuts' ten static AppShortcut declarations directly in its builder.
- TripShortcuts.appShortcuts has the sole approved 22-line member exception; all other members stay within 20 lines.
- Existing inline concrete KeyPath casts preserve metadata extraction; do not introduce dynamic helper values.
- Preserve useful parameters and application-name tokens rather than removing them to pass export.
- Control trip parameters retain optional Swift types even when UI configuration is required.
- Shared/System and app-only intents must retain their current target membership.

A requested `bash scripts/build.sh app Debug` must finish AppIntentsMetadataProcessing
for host and widget integration. Source audits and Swift type checking alone do not prove exported Siri metadata.
