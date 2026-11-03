# Place photo gallery

The gallery implementation remains in Explore for a future place-photo source.
The twelve bundled mock images have been removed, so place details currently hide
the gallery entry. When photos are provided, the place sheet and map selection
remain underneath a full-screen gallery on iOS; visionOS uses a resizable native sheet.

## Interactions

- Pinch the grid continuously between three density levels. The layout derives
  its column counts from available width, with 5 / 3 / 1 columns at phone widths
  and more columns in wide containers. Photo IDs survive every density change.
- The pinch chooses the nearest photo at the gesture origin and compensates
  vertical scrolling as its frame changes. Rows stay packed from the leading edge,
  without introducing empty slots as density changes.
- View Options also exposes Zoom In, Zoom Out, and Aspect Ratio Grid. The latter
  uses justified rows to reveal original proportions. Enlarged single-column
  photos preserve their aspect ratios even with square-grid mode selected. The
  largest zoom level also preserves proportions when a wide container fits
  multiple photos in a row.
- Opening a photo pushes a destination in the gallery's NavigationStack with
  SwiftUI's native zoom transition and Back action. Swipe between photos,
  tap a thumbnail, or scroll the filmstrip to move through the collection.
- Pinch or double-tap a photo to zoom, then pan within the image. Paging is
  disabled while enlarged. Double-tap chooses a scale based on the image and
  viewport proportions; a completed pan uses its predicted translation to coast
  within the image bounds. This is custom SwiftUI gesture handling, not the
  private Photos zoom implementation.
- Tap once to hide the controls and use a black background; tap again to restore
  them. Zooming also hides the controls. The pager measures the full viewport so
  hiding toolbars does not change its page size. Back returns to the grid and
  keeps the last viewed photo visible. Already-visible photos retain their grid
  position instead of forcing a new centered scroll position.
- The filmstrip uses fixed scroll targets, with sufficient end insets to center
  the first and last photos. Selection changes the image inside its slot, not
  the slot's width. This avoids moving scroll targets during scrubbing.
- Compact-height layouts hide the filmstrip to give the photo more space; paging
  and toolbar actions remain available. At accessibility text sizes, navigation
  titles simplify to the sample label rather than crowding two scaled text lines.
- The native toolbar's Share action exports the sample through the system share sheet. Info
  explains the sample content and links to the photo license.

The implementation uses SwiftUI exclusively. Native toolbar/menu actions and
VoiceOver photo actions supplement gestures. Reduce Motion removes custom
animations and interactive grid interpolation, and uses a cross-fade for opening
photos. Large text, long place names, dark appearance, empty data, wide layouts,
and selected/immersive viewer states have local, same-file previews.

## Ownership and resource limits

Explore owns the window-local gallery, grid, zoom, and filmstrip models. Struct
controllers delegate all actions. The gallery never changes trip data, map
camera state, place selection, or navigation paths. It requests no photo-library
permissions and makes no runtime network requests.

The custom Layout handles the bounded twelve-image sample catalog; it is not an
unbounded photo-library implementation. Filmstrip cells use 360-pixel thumbnails.
Grid cells retain the same 1600-pixel asset throughout zooming, eliminating asset
swaps at density/viewport thresholds. Grid scrolling no longer recalculates every
photo frame separately for each cell. Layout measurement and placement share a
geometry cache. These choices are bounded to the twelve sample images. Full-screen
paging uses LazyHStack; offscreen pages are not eagerly rendered. A future live
catalog needs a bounded image pipeline and pagination before removing this cap.

The former sample images and their provenance file were removed. New Hindi and
Kannada strings are marked for translation review.

## Verification

Reference inspection: Photos on iPhone 18 Pro Max, iOS 27.2 Simulator, in portrait
and landscape. Observed the 1 / 3 / 5 grid levels, view-options menu, aspect-ratio
option, thumbnail chooser, full-screen controls, immersive mode, and double-tap
zoom. Device Hub's available pointer controls did not establish multitouch pinch
fidelity. This does not establish identical Photos behavior on iPad or iPhone Duo.

Source verification: `bash scripts/check.sh` checks architecture, generated text,
Swift syntax, file/member limits, preview presence, controller storage, and UIKit
exclusion. It does not compile the app or validate the rendered gallery.

Before release, explicitly build and exercise Trip on compact/wide/rotated
containers, including pinch cancellation and anchoring, paging versus zoom/pan,
filmstrip scrubbing, interactive dismissal and return targeting, sharing,
VoiceOver, Reduce Motion, dark appearance, accessibility text, and fold poses.
After the reported build failure, `bash scripts/build.sh app Debug` succeeded for
the generic iOS Simulator destination, including the widget extension. The build
used the installed Xcode toolchain with code signing disabled. Its log is
`.build/gallery-build-fix.log`. No compiler warnings remained in that earlier build.

UX revision: inspected the already-running Trip gallery on iPhone 18 Pro Max
iOS 27.2, including the grid, selected viewer, thumbnail presentation, and
double-tap enlargement. The baseline showed the large share button and controls
remaining over an enlarged photo. Pointer swipe attempts did not establish paging
behavior. The revised source passes `bash scripts/check.sh`, including architecture,
localization, file/member limits, previews, and UIKit exclusion. Installation and
compilation of the revision were declined, so the earlier successful build does
not verify this revision. Revised rendering, navigation, gesture arbitration,
multitouch smoothness, accessibility behavior, and adaptive layouts remain
unverified. No performance measurements or benchmarks were run.

Completion repair: connected the grid's viewport and rendered anchor measurements,
added the missing zoom geometry helpers, and wired pinch/menu completion to the
generation-checked cleanup. Gesture cancellation settles through the same path;
leaving the grid invalidates pending cleanup. Dismissal clears viewer, scrubbing,
and gesture state while keeping the selected photo available for the next visit.
Photo panning yields to magnification, invalid geometry is rejected, and VoiceOver
Zoom In only enlarges. View actions delegate through the struct controllers.

The completed source passes `bash scripts/check.sh`; results are recorded in
`.build/gallery-completion-audit.log`. This includes architecture, catalog generation,
Swift syntax, file/member limits, same-file previews, and UIKit exclusion. The latest
build identified duplicate localization symbols in literal Shortcuts summaries.
The colliding metadata keys now use an `intent_` namespace; translations and public
TripText accessors are unchanged, and native symbol generation stays enabled.
Verification now succeeds with `bash scripts/build.sh app Debug`: generic iOS
Simulator, app and widget extension, signing disabled, with no warnings or errors.
The final log is `.build/localization-workflow-build.log`. The source audit also
passes after Xcode extraction without regenerating the catalogs; its log is
`.build/localization-workflow-audit.log`. Device/Canvas interaction verification
remains outstanding; compilation does not establish gesture feel or frame pacing.
