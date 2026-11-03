# Search across Trip

## Prefix suggestions · 2026-10-20

Explore and Add places now use `MKLocalSearchCompleter` while typing, with up to
20 native suggestions and location subtitles. A full `MKLocalSearch` query can
interpret “Ph” as one place/country; it is not an autocomplete list. The change
uses Apple's [completion API](https://developer.apple.com/documentation/mapkit/mklocalsearchcompleter).
Actual choices and their count depend on Apple's provider, query and regional hint.
Preview examples are explicitly illustrative local fixtures, not promised live results.

Explore preserves the background map while typing. It resolves a selected native
completion before opening one exact place; if that completion returns several
places, it displays those choices instead of choosing the first. Keyboard submission
still performs a full search. Add places resolves a chosen suggestion, then keeps
the existing explicit Add action and Undo. Saved matches remain directly available.
Typing cancels superseded resolution. Clearing, dismissal, day changes and
backgrounding cancel owned work; foregrounding resumes the active search.

The subsequent supplied compiler diagnostics were addressed by importing TripDomain
in consuming autocomplete files and moving `arrivalClock` onto TripStopTiming's
primary declaration. The separate extension source was removed from the manifest.
Source/architecture/preview-definition checks pass. The latest build attempt stopped
at sandbox-protected Swift/Xcode caches; the escalated rerun was declined. Compilation,
live “Ph” suggestions and actual selection/add interactions remain unverified for
this autocomplete revision. Earlier successful builds apply to the preceding code.

Search improvements · 2026-10-20. The integration baseline was committed first as
`da79d50`; this search work follows that baseline.

## Matching and relevance

TripDomain's `PlaceSearchQuery` matches every word across relevant fields, ignoring
case, accents, width differences and punctuation separators. Extra whitespace is
removed from service queries while text fields keep the user's raw input, including
spaces between words. A punctuation-only query does not match every record.
For example, a saved café can match “cafe Paris” using its name and address.

Local place results prioritize exact names, name prefixes, other name matches,
then category/address matches. Equal ranks keep their original order. MapKit's
live results retain provider order and semantic matching; they are not discarded
merely because a provider result doesn't contain the literal query words.

Library and Save to Trip searches cover trip names, places/addresses/categories,
day and collection names, trip notes, booking names/locations/notes and checklist
titles. Existing user-selected trip sorting remains in effect. Private content
stays in the app library; it is not added to system projections or AI prompts.
Assistant place selection uses names, addresses and categories. Time-zone search
also recognizes localized standard names and abbreviations, alongside identifiers.
Shortcuts' trip-name and checklist entity searches use the same word matching.

## Search state and actions

- Explore refines compatible displayed matches immediately. Its repository actor
  prepares up to 100 cached matches after debounce, before the live search. Clearing
  restores the complete loaded catalog. No additional network request is added.
- An explicit map submission can run while camera motion is settling. Reopening
  a cancelled search reschedules missing work. Generation checks reject late results.
- No-results messages suggest changing the query or map area. Retry is reserved for
  actual errors/timeouts, with a contextual Search this area action for an idle query.
- Add places retains compatible results during retries/refinements. Switching days
  still cancels and clears old-area results. Saved matches and Maps results remain
  separate; an empty Maps section is omitted when saved matches already answer the query.
- Route search matches its full loaded catalog before applying the result limit,
  combines relevant cached and live results, and offers Retry after errors/timeouts.
- Trip and route searches remove duplicate listing IDs and same-name listings within
  five meters, preserving separate branches, different names and provider order.
- Explore, route and trip add actions validate current result/session identities.
  Explore resolves the choice before dismissing native search, which may clear its text.
  Existing duplicate protection, explicit Add, destination selection and Undo remain.

## Saved details without Intelligence

Ask my trip has native text search for saved names, locations and booking kinds.
It works when Apple Intelligence is unavailable. Day, category and text filters
combine instead of resetting one another, and their menus display the current scope.
No-results recovery can restore all details. Natural-language questions still use
the existing cancellable interpretation and saved-data results.

## Verification

`bash scripts/check.sh` passes: architecture/source manifests, 100-line files,
20-line members, previews, controller storage, UIKit prohibition and whitespace.
Local preview definitions cover populated Explore results with Save enabled,
route retry/no-results, a trip search failure retaining results, and detail search
with combined filters while Intelligence is unavailable.

`PlaceSearchChecks` is registered in the existing system-check harness. It defines
cross-field/Unicode matching, stable relevance, limits applied after matching,
duplicate branches and combined detail scope. These executable checks were not run.
The previous integration build does not verify this search revision. No app/package
build, rendered preview, Simulator interaction or benchmark was run in the initial
source-only pass. The subsequent build repair below supersedes its compilation status.

## Build repair · 2026-10-20

The user reported a compiler failure in the chained ranking expression. Replaced
the enumerated/filter/map/sort chain with an explicitly typed ranking array and
stable sort, keeping the matching and result order policy. The Debug iOS Simulator
build passed with Xcode-beta / iOS 27.2, arm64/x86_64 and signing disabled, including
the app, widget extension and App Intents metadata processing. No warnings/errors
were reported in `.build/build-errors-fix.log`. Source audits pass. Executable
regression checks, rendered previews and device interactions remain unverified.
