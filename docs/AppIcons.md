# Trip app icons

Use this guide when updating the app icon or adding a required appearance. Inspect
the existing asset catalog first and preserve the folded map, winding route,
location pin, and teal/mint identity unless a redesign is explicitly in scope.
Keep icon work separate from ordinary feature symbols; see [SF Symbols](../SF-SYMBOLS.md).

## Project assets

- `trip/Assets.xcassets/AppIcon.appiconset`: 1024 × 1024 light, dark, and tinted icons.
- `trip/Assets.xcassets/AppIcon-visionOS.solidimagestack`: 1024 × 1024 foreground
  and background layers, supplied at visionOS's 2x scale.
- The light icon and spatial background are opaque sRGB PNGs.
- The dark icon and spatial foreground preserve the generated transparency.
- The tinted icon is converted to Gray Gamma 2.2 during export.
- Debug and Release use `AppIcon`; SDKs matching `xr*` use `AppIcon-visionOS`.
- Xcode generates the smaller iPhone and iPad icon sizes from the single-size set.

Artwork is kept square without a baked-in outer mask. The system supplies its
platform icon shape. The transparent foreground is shared by dark and spatial
appearances. The visionOS stack lists the foreground before the background.

[Apple's asset-catalog configuration](https://developer.apple.com/documentation/xcode/configuring-your-app-icon)
describes the single-size variants, transparent dark background, grayscale tinted
artwork, and visionOS layers. See also
[Apple's icon design guidance](https://developer.apple.com/design/human-interface-guidelines/app-icons).

## Prepare related appearances

Use one accepted light icon as the source for related variants. Preserve its
silhouette, scale, route, and position so appearance changes do not change the
identity. Inspect transparency around the outer contour and pin opening; repair
fringes before using the foreground in dark and spatial appearances.

The following prompt recipes encode Trip's artwork constraints. Supply the named
reference image for each edit and inspect the result; prompts do not guarantee an
identical output or replace review. Use the image-generation skill when generation
or image editing is requested, rather than regenerating artwork during setup.

### Light icon

```text
Use case: logo-brand
Asset type: Production app icon for Trip, a native Apple travel planning and map exploration app.
Primary request: Create one beautiful, distinctive square app icon. A sculptural folded map and a bold location pin form a single clear central emblem. Use the app's established deep teal (#006B66), pale mint (#75D9D0), and ivory-white palette.
Scene/backdrop: Completely opaque full-bleed deep teal background, softly brighter toward the upper left, extending to all four square edges.
Subject: A clean three-panel folded ivory-white map, viewed almost straight on with just enough dimensional fold shading to feel tactile. A single smooth teal route crosses the map and leads to one large mint-teal location pin standing above the central panel. The pin has a clear circular opening. Keep the map and pin unified, simple, and immediately recognizable.
Style/medium: Premium restrained 3D illustration, crisp smooth geometry, satin paper and softly polished pin, subtle natural fold shadows. Contemporary native Apple app icon polish, no ornamental details.
Composition/framing: Square 1024 by 1024 pixels. Center the complete emblem within the central 68 percent of the canvas, with generous even breathing room. Keep every meaningful part of the emblem inside a centered circle occupying 78 percent of the canvas so it also works in a visionOS circle mask. The background fills the entire square. Large bold silhouette legible at 40 pixels.
Text: None.
Constraints: ONE finished icon only. Square image with straight unrounded corners. No rounded-square tile inside the image, no border, no surrounding mockup, no padding outside the background, no lettering, no watermark, no airplanes, no compass, no buildings, no extra symbols. Do not imitate an existing app brand.
```

### Dark icon and visionOS foreground: extraction

```text
Use case: background-extraction
Asset type: Trip app icon foreground, for the iOS dark icon and the visionOS front layer.
Input images: Image 1 is the edit target, Trip's finished default app icon.
Primary request: Remove only the teal background, leaving the complete folded ivory-white map, winding dark-teal route, and mint-teal location pin isolated on genuine transparency.
Constraints: Preserve the emblem's exact position, silhouette, scale, perspective, folds, route geometry, colors, pin opening, and smooth edge quality from Image 1. Keep the same square canvas and the same margins. The pin opening must be transparent where the background was visible. Remove the background and its cast shadow completely; keep only self-shading within the map and pin. No new objects or changes to the design. No floor, backdrop, checkerboard, text, watermark, border, or rounded icon mask. Output one transparent PNG.
```

### Dark icon and visionOS foreground: edge repair

```text
Use case: precise-object-edit
Asset type: Transparent Trip app icon foreground.
Input images: Image 1 is the edit target, the transparent map-and-pin foreground.
Primary request: Repair ONLY the alpha silhouette. Remove ALL stray opaque pixels, white fringes, cyan fringes, tiny speckles, rough edges, and fragments outside the intended folded map and pin. Make the outer boundary and circular pin opening impeccably smooth and clean as if exported from a professionally modeled icon.
Constraints: Keep the map, route, pin, internal colors, fold lighting, canvas size, object scale, and position unchanged. Use clean continuous antialiased contours; no glow, outline, border, or edge halo. All pixels outside the actual map and pin must be fully transparent, including inside the pin hole. Reconstruct clean edges where needed. Do not leave a white fringe or noise around the shape. No background, floor, shadows beyond the subject, text, or new objects. One production-quality transparent square PNG.
```

### Tinted icon

```text
Use case: style-transfer
Asset type: Trip's tinted iOS/iPadOS app icon.
Input images: Image 1 is the edit target, the finished default Trip icon.
Primary request: Create the grayscale tinted-appearance version of this exact icon.
Constraints: Preserve the exact folded-map and pin design, silhouette, proportions, position, scale, route path, and canvas. Use ONLY neutral gray values: a near-black charcoal full-bleed background, a bright silver-white folded map, a bright silver location pin with visible gentle shading, and a dark graphite route. Keep strong luminance contrast and simplify unnecessary grain. Every pixel must be achromatic with equal red, green, and blue values. Keep the circular hole and folded map visually clear at small app-icon sizes. One opaque square full-bleed icon, straight unrounded corners, no extra border, no mockup, no text or watermark.
```

### visionOS background

```text
Use case: precise-object-edit
Asset type: Opaque background layer for Trip's visionOS app icon.
Input images: Image 1 is the edit target, the default Trip app icon.
Primary request: Remove the entire map, pin, route, and every associated shadow, leaving only the smooth full-bleed teal background.
Constraints: Preserve the original background colors and soft upper-left illumination. Fill the vacated center seamlessly with the same quiet deep teal gradient. A completely empty square opaque gradient, edge to edge, with straight corners. No objects, patterns, silhouettes, holes, highlights shaped like objects, text, icon tiles, borders, watermark, or transparency. Use sRGB deep teal around #006B66, a gently lighter mint-teal upper-left area and a darker teal lower-right area. One square background image.
```

## Export and check

1. Export 1024 × 1024 PNGs without a baked-in outer mask. Keep RGB artwork sRGB,
   the tinted asset Gray Gamma 2.2, and foreground alpha intact. Reuse the same
   accepted foreground for the dark icon and spatial front layer.
2. Inspect dimensions, profile, and alpha with `sips -g pixelWidth -g pixelHeight
   -g profile -g hasAlpha <image.png>`; inspect edge pixels against light and dark
   backgrounds. Metadata alone cannot reveal a fringe or lost pin opening.
3. Confirm filenames, appearance entries, and spatial layer order in the catalog's
   `Contents.json`. Preserve the shared Debug/Release and `xr*` build-setting names.
4. Run `bash scripts/check.sh` for source policy. For requested build/runtime work,
   follow [Contributing](../CONTRIBUTING.md) and inspect installed light, dark, and
   tinted Home Screen appearances plus spatial layering on supported hardware.

Check the emblem at small sizes and through the platform mask. Source checks and
PNG metadata do not establish legibility, appearance switching, or spatial depth.
