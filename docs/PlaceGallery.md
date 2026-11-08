# Place photo gallery

Use this guide to maintain the retained gallery or connect a real photo source.
The gallery code is in Explore, but the app currently supplies no photos.
`PlaceDetailPhotoView` constructs `PlaceGalleryModel(photos: [])`, so the gallery
entry is hidden. There is no live photo provider or bundled gallery image set.

## Ownership and entry points

| Responsibility | Source under `trip/Features/Explore` |
| --- | --- |
| Presentation, selection and viewer state | `Models/Gallery/PlaceGalleryModel.swift` |
| Photo identity, aspect ratio and asset names | `Models/Gallery/GalleryPhoto.swift` |
| Grid density, anchors and layout cache | `Models/Gallery/GalleryGridModel*` and `GalleryGridGeometry*` |
| Image magnification and viewport bounds | `Models/Gallery/GalleryPhotoZoomModel*` |
| Thumbnail navigation | `Models/Gallery/GalleryFilmstripModel.swift` |
| Actions | `Controllers/Gallery` |
| Grid, viewer, controls and presentation | `Views/Gallery` |
| Place-details entry | `Views/Details/PlaceDetailPhotoView.swift` |

`GalleryPhoto.samples` retains twelve metadata fixtures. Its image names follow
`Gallery-<id>` and `Gallery-<id>-thumb`, but those assets are absent. Previews using
the default sample model can exercise layout/state definitions; they cannot prove
photo rendering or image sharing works.

## Interaction contract

The grid supports three density levels, pinch anchoring, menu zoom controls, and
an aspect-ratio layout. Phone widths use 5 / 3 / 1 columns; wider layouts derive
column counts from available space. Stable photo IDs preserve selection and scroll
position through density changes.

Opening a photo presents a viewer with paging, a filmstrip, pinch/double-tap zoom,
and bounded panning. Paging is disabled while enlarged. Returning to the grid
reveals the last viewed photo. Compact-height layouts hide the filmstrip while
retaining navigation and toolbar actions. iOS uses full-screen presentation;
visionOS uses a resizable sheet.

Controllers delegate to window-local models. The gallery does not mutate saved
trips, place selection, or camera state. It uses SwiftUI and requests neither
photo-library permission nor network access. VoiceOver actions supplement gestures;
Reduce Motion suppresses custom motion and interactive grid interpolation.

## Before connecting a photo source

1. Provide licensed, place-specific media with stable identities and reliable aspect
   ratios. Add a bounded loading/cache strategy and pagination for a live catalog.
2. Replace the retained sample labels, information/license view, asset-name lookup,
   and image-sharing assumptions with the real source's metadata and behavior.
3. Supply the photos to the place-details entry and add useful local rendering fixtures.
4. Check compact/wide layouts, pinch cancellation and anchors, paging versus zoom,
   return positioning, sharing, accessibility and Reduce Motion.

Keep loading and layout bounded: the implementation targets a small collection.
It has no enforced twelve-photo
limit and should not be treated as an unbounded library implementation. Source
checks are available through `bash scripts/check.sh`; compilation and interaction
verification require separate requested builds and runtime checks.
