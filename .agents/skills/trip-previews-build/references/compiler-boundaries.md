# Trip compiler and module boundaries

General inference, isolation, and import diagnosis lives in global `app-development` compiler-diagnostics.
These are concrete Trip ownership traps, not universal Swift recipes.

- Preserve PlaceSearchQuery's ranking order when splitting expressions for type inference.
- Keep TripSurfaceAgenda's pure priority extension explicitly nonisolated under default MainActor isolation.
- PlaceCategory.annotationTitle belongs to Shared, not TripDomain; inferred member access can hide app-only dependencies.
- Locate defining members before moving helpers into packages; lexical ownership checks cannot resolve every extension.
- MemberImportVisibility requires explicit imports in every consuming file, including extensions.
- Shared/System compiles in both app and widget targets; check both consumers.
- Metadata builders have a separate exporter; follow [Trip metadata](../../trip-system-integrations/references/metadata-contract.md).
- Trip uses strict Swift 6 isolation and its declared deployment targets; do not relax them to pass.

`bash scripts/check.sh` is structural evidence. Requested app compilation uses
`bash scripts/build.sh app Debug`; inspect app, widget, and metadata diagnostics.
Rebuild the same requested configuration after source fixes before reporting it passed.
