# Shared text and localization

Use this guide when adding user-facing copy, changing translations, or exposing
native metadata to Siri, Shortcuts or widgets. TripLocalization owns shared text;
app and extension metadata also need their generated main-bundle resources.

## Find the right resource

Paths below are relative to `Packages/TripKit/Sources/TripLocalization`.

| Resource | Ownership |
| --- | --- |
| `Resources/Localizable.xcstrings` | Authored English, Hindi (`hi`) and Kannada (`kn`) copy, plural forms and accessor metadata |
| `HostResources/AppShortcuts.xcstrings` | Siri invocation translations and native parameter tokens |
| `HostResources/InfoPlist.xcstrings` | Location permission explanation translations |
| `HostResources/Localizable.xcstrings` | Generated app/widget metadata subset; do not hand-edit managed entries |
| `TripText.swift` | Explicit package bundle, deferred resources, resolved text and locale override |
| `TripText+*.swift` | Generated typed accessors; edit their catalog entries instead |

The package depends on Foundation, not app types, SwiftUI, MapKit or a runtime
translation service. Consumers should reuse existing accessors before adding keys.

## Use existing text

```swift
Button(TripText.save.resource) { controller.save() }
Text(TripText.dayCount(3).resource)
model.error = TripText.thisTripIsNoLongerAvailable.text
TripText.cancel.localized(locale: Locale(identifier: "kn"))
```

Prefer deferred `.resource` in SwiftUI so bundle and locale context survive until
rendering. Use `.text` when a model or service API requires String. Use explicit
locales for deterministic fixtures. Count accessors take Int and use catalog plural
forms; preserve interpolation positions so translators can reorder arguments.
Never assemble sentences from translated fragments or English plural suffixes.

## Add or change text

1. Search the catalog for an existing key with the same meaning. Keep stable keys
   when changing wording; user-entered names and saved text remain data.
2. Supply English, Hindi and Kannada values. Counts need `one` and `other` variants.
   Explain the UI purpose and interpolation positions for translators.
3. For shared runtime copy, add comment metadata: `@symbol` for the accessor name,
   `@group` for the generated file group, and `@parameters ` followed by comma-separated
   `String`/`Int` types, or an empty value for labels. Preserve the space after the
   parameters directive in the catalog comment.
4. Run `python3 scripts/generate_localization.py` after catalog or native metadata
   changes. Review generated accessors, host resources and any synchronized project
   or performance-source entries together.
5. Follow the source checks in [Contributing](../CONTRIBUTING.md). Check all supported
   languages and plural/interpolation branches before treating the copy as complete.

## Native metadata and runtime dialogs

Use stable literal metadata keys with the `intent_` prefix for new App Intent titles
and descriptions. This avoids collisions with native English Shortcuts summary keys.
The generator collects actual literal references from intents, shared system types
and widgets into the main-bundle catalog.

Runtime errors and dialogs should use generated `TripText` accessors. A new raw key
used only in model code is not automatically native metadata and will not enter the
host subset. Keep its accessor metadata in the authored shared catalog instead.

Siri phrases and Shortcuts Summary interpolation remain native DSL literals for
Apple's extraction. Preserve `${parameter}` tokens exactly. Keep permission fallback
copy synchronized through the generator rather than editing the project setting
independently.

Managed host entries use manual extraction ownership because both app and widget
metadata share the catalog. Preserve both targets' entries. Compiler-owned empty,
separator and format-only artifacts may remain automatic when they contain no
authored words or symbols. Actual copy still requires all supported translations.
The checker detects catalog coverage, placeholder types, Siri tokens, equivalent
plain-key symbol collisions and generation drift; Xcode remains authoritative for
metadata extraction and generated Swift symbols.

Generation sorts entries, compares catalogs by JSON content and writes only changed
files. Do not hand-reorder generated accessors or suppress a missing translation to
make generation pass.

## Review copy and presentation

Keep persisted enum raw values stable and localize separate display titles. User
names, notes, checklist items and MapKit names remain data. Prompts, diagnostic
signposts, SF Symbols, URLs, resource identifiers and preview names are not UI keys.
AI availability must still explain unsupported model languages.

The catalog includes machine-assisted translations. Entries marked `needs_review`
require native-speaker review, especially travel timing, longer guidance and Siri
phrases. English is the source/fallback language; translation generation is an
authoring step, not an app network dependency.

Use `TripLocalizationPreview` for English, compact Kannada and large-text/dark Hindi
states. Check glyphs, truncation, VoiceOver, widgets and permission prompts when
rendered verification is in scope. [Testing](Testing.md) separates source checks,
compilation and runtime evidence; preview declarations alone do not verify visuals.
