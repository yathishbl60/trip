# Search across Trip

Use this guide when a search change crosses feature boundaries. Start with the
owning feature for its presentation and cancellation lifetime; do not create a
second shared search coordinator. Setup/check commands live in
[Contributing](../CONTRIBUTING.md).

## Ownership

| Responsibility | Owner |
| --- | --- |
| Immutable query values, matching, deduplication | `TripDomain` |
| Native text search and MapKit conversion/category mapping | `TripPlaces` |
| Observable autocomplete and native completion tokens | `trip/Shared/Places` |
| Camera discovery, catalog, cached map results | Explore and MapEngine's `PlaceRepository` |
| Day-picker search and destination session | Trips' picker/search models |
| Directions stop/origin search | `TripRouting` |

Native request handles stay inside their adapter. Each operation cancels/releases
its own handle; an obsolete completion cannot clear a newer request. Feature models
own debounce, deadlines, selection, navigation, and stale-result checks.

`AppTripServices` injects a `PlaceSearching` factory into Trips. `TripPlaceSearchModel`
never constructs a live provider. Without a factory, native autocomplete/submission
stay disabled while local supplied results can render; production explicitly injects
`PlaceTextSearch`. Explore has its own provider/catalog composition.

## Native suggestions and submission

Explore and Add places use `MKLocalSearchCompleter` while typing, capped at 20
suggestions with location subtitles. Full `MKLocalSearch` submission is a different
operation, not a prefix suggestion list. Choices/counts depend on Apple's provider,
query, and regional hint; preview suggestions are illustrative local fixtures.

Explore keeps the map while typing and resolves a selected completion before
opening a place. Multiple matches remain choices instead of silently choosing the
first. Keyboard submission still performs full search. Add places resolves the
choice but retains explicit Add and Undo; saved matches remain directly available.

Typing cancels superseded resolution. Clearing, dismissal, destination changes,
and backgrounding cancel owned work; foregrounding resumes the active session.
Submitted map searches may update results after the field closes. See
[Explore](Explore.md) for that distinction and native keyboard dismissal.

## Matching and identity

`PlaceSearchQuery` matches every word across relevant fields, ignoring case,
accents, width differences, and punctuation separators. Service queries normalize
whitespace while fields retain raw user input. Punctuation alone must not match
every record. For example, “cafe Paris” can match a café's name and address.

Local ranking favors exact names, name prefixes, other name matches, then
category/address matches; ties preserve source order. Live MapKit results retain
provider order and semantic matching, even when they lack literal query words.
Trip/route searches remove repeated listing IDs and same-name listings within
five meters, retaining separate branches and differently named places.

Library and Save to Trip search cover trip names, places/addresses/categories,
days/collections, trip notes, booking names/locations/notes, and checklist titles.
User-selected sorting remains in effect. This private app-library search does not
publish those fields to system projections or AI prompts. Assistant selection
uses place names/addresses/categories; time-zone search includes localized names,
abbreviations, and identifiers. System entity name searches reuse word matching.

## Preserve results and recover

- Explore prepares up to 100 compatible cached matches after debounce, before live
  search. Clearing restores its loaded catalog. Explicit submission/retry bypasses
  cache; camera discovery retains its bounded debounce/cache policy.
- Compatible results remain visible through refinements and retry. Switching day
  destinations cancels/clears old-area results. Saved and Maps results stay separate;
  an empty Maps section can be omitted when saved matches answer the query.
- Route search matches the full loaded catalog before its result limit, merges
  relevant cached/live results, and offers Retry for errors/timeouts.
- No-results recovery suggests another query or map area; Retry denotes an actual
  failure. Reopening a cancelled search reschedules missing work.
- Add/select actions validate current result and session identities. Explore
  resolves its choice before dismissing native search, which may clear the field.
  Preserve explicit Add, duplicate protection, destination choice, and Undo.

Ask my trip also supports native saved-name/location/kind search without Apple
Intelligence. Day, category, and text filters combine and expose their scope;
no-results recovery can restore all details. Natural-language interpretation is
cancellable and returns saved facts, not generated booking data. See
[System integrations](../SYSTEM-INTEGRATIONS.md).

## Check a search change

`TripPlacesTests` uses local MapKit values to check public conversion/category
contracts without live searches. Matching/identity checks and preview declarations
are separate from keyboard, VoiceOver, rendering, and provider-result acceptance.
Use [Testing](Testing.md) to select authorized checks; report their scope explicitly.

Native API reference: [MKLocalSearchCompleter](https://developer.apple.com/documentation/mapkit/mklocalsearchcompleter).
