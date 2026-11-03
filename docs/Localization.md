# Shared text and localization

Author user-facing copy in `Packages/TripKit/Sources/TripLocalization`, shared by
Trip, all TripKit modules, and the widget extension. The package has no dependency
on app types, MapKit, SwiftUI, or a translation service at runtime.

- `Resources/Localizable.xcstrings` is the authored English, Kannada (`kn`), and
  Hindi (`hi`) catalog. It includes controls, accessibility, errors, sharing,
  packing templates, and system summaries.
- `HostResources/AppShortcuts.xcstrings` owns Siri invocation translations.
- `HostResources/InfoPlist.xcstrings` owns location permission translations.
- `HostResources/Localizable.xcstrings` is a generated subset for native app and
  extension metadata, whose lookups use their own main bundles.
- `TripText.swift` resolves the package bundle explicitly and provides deferred
  resources, localized strings, and a deterministic locale override for previews.
- `TripText+*.swift` files are generated, grouped, and capped below the project's
  physical line limit. Edit the catalog instead of these accessors.

## Contents

- [Use existing text](#use-existing-text)
- [Add or change text](#add-or-change-text)
- [Translation review and verification](#translation-review-and-verification)

## Use existing text

```swift
// SwiftUI keeps bundle and locale context until rendering.
Button(TripText.save.resource) { controller.save() }
Text(TripText.dayCount(3).resource)

// Existing model/service contracts requiring String resolve explicitly.
model.error = TripText.thisTripIsNoLongerAvailable.text

// Explicit locale for deterministic preview text.
TripText.cancel.localized(locale: Locale(identifier: "kn"))
```

Prefer deferred `.resource` at native SwiftUI display sites. Use `.text` where an
existing API needs a resolved String. The resource and all translations come from
the same key. A count accessor accepts Int; its catalog owns plural forms. Other
message accessors preserve interpolation positions so translators can reorder them.
Do not construct sentences from translated fragments or English plural suffixes.

## Add or change text

1. Update the catalog's English value and the `hi` / `kn` translations. Keep stable
   keys independent of copy edits. Add `one` and `other` variants for counts.
   New App Intent metadata keys use `intent_` (for example `intent_open_my_trips`)
   so they cannot collide with native English Shortcuts summary keys.
2. New shared entries have comment metadata: `@symbol save`, `@group Common`, and
   `@parameters ` (empty for labels, or comma-separated `String` / `Int` types).
   Include the UI purpose and explain each interpolation position for translators.
3. Run `python3 scripts/generate_localization.py` after catalog or native metadata
   changes. It updates accessors and the main-bundle metadata subset.
4. Run `bash scripts/check.sh`. It checks catalog coverage, placeholder types, Siri
   tokens, generation drift, architecture, and source/skill limits without an app build.

Siri invocation phrases and Shortcuts `Summary` interpolation must remain native
DSL literals so Apple can extract parameter tokens. Their translations live in the
central catalogs; preserve `${parameter}` tokens exactly. Metadata titles use stable
literal keys for compiler extraction and resolve through the generated host catalog.
The base location explanation in project settings is synchronized from its catalog
by the generator, preserving a meaningful permission fallback.

Generation sorts accessor keys and serializes the generated host catalog in a
stable order, so Xcode's catalog reordering does not move accessors between files.
The generator collects literal metadata references from intents, shared system
types, and widgets. Only those keys become managed host entries. A missing
translation fails generation with the key and catalog path. Removed metadata
references disappear on regeneration.
Generated host entries are manually managed because the catalog combines app and
widget metadata. Each target must retain the other target's translations. The
source audit checks that generated keys match the actual metadata references.
Xcode may add compiler-owned interpolation/separator entries during extraction.
These retain automatic ownership and are preserved only when the key and every
value contain placeholders or punctuation, with no authored words or symbols.
All real copy still requires complete translations. Catalog comparisons use JSON
content so Xcode formatting changes do not report false generation drift. Generation
writes only changed files, preserving incremental-build timestamps.
Swift symbol generation stays enabled. Stable metadata keys use a distinct name
from literal Shortcuts summaries, while existing `TripText` APIs remain unchanged.
The audit detects equivalent plain keys such as `Open my trips` and `open_my_trips`
before compilation. Xcode's build remains authoritative for generated Swift symbols.
The source audit accepts Xcode's empty and format-only extraction placeholders;
actual labels and authored symbols still require all supported translations.

User-entered trip names, notes, saved checklist items, and MapKit/source catalog
names stay as data. Enum raw values used as IDs remain stable; separate `title`
properties supply localized labels. AI prompts, symbols, resource names, URLs,
diagnostic signposts, and preview fixture names are not UI translation keys. The
AI assistant still reports when the selected model does not support a language.

## Translation review and verification

The initial Hindi and Kannada translations were generated with Google Translate,
with common controls and selected terminology reviewed during implementation.
Entries marked `needs_review` still require native-speaker review, particularly
long guidance, travel timing, and Siri phrases. English remains the source
and fallback language. Translation generation is an authoring step; the app makes
no translation-service requests.

`TripLocalizationPreview.swift` provides deterministic English, compact Kannada,
and large-text/dark Hindi previews. Preview source is not visual verification.
Request an app build and device/Canvas review separately to verify compilation,
App Intents metadata extraction, language selection, glyphs, and truncation across
Explore, trip editors, directions, widgets, and system permission prompts.

The standalone performance harness includes the shared text sources and prepares
an isolated localization bundle when explicitly run. It continues to exercise the
production domain and presentation code; no localized fallback stubs replace them.
