# Snap2UI Output Contract

The final implementation must satisfy this contract.

## Visual Contract

- Match the reference at the reference viewport before optimizing other breakpoints.
- Preserve the original hierarchy, density, alignment, spacing, borders, strokes, shadows, texture, and selected states.
- Use stable dimensions for fixed-format UI such as cards, boards, toolbars, tabs, sliders, counters, and nav bars.
- Use real text for visible labels and numbers unless text is part of a tiny icon asset.
- Prefer CSS for surfaces, borders, rounded corners, shadows, gradients, masks, and simple decorative details.
- Prefer local transparent raster assets for portraits, product thumbnails, intricate icons, painterly details, and complex pixel art.
- Do not replace intricate bitmap assets with CSS approximations when the result loses material, pixel-art, painterly, or game-icon quality.
- Generated assets are acceptable for isolated sprites, icons, props, portraits, texture chips, and clean non-UI backgrounds when source cropping is poor. They must be style-compatible and saved into the project.
- Cropped or generated assets must not include unintended UI fragments such as old panel backgrounds, baked-in status badges, source text, separators, or rectangular leftovers.
- Background illustrations used behind rebuilt DOM UI must not contain duplicated source UI overlays, readable text, buttons, cards, or stats panels.

## Component Contract

- Each meaningful repeated UI item must be a reusable component.
- Each meaningful screen region must have a named component.
- User-facing interactions must be wired to state, not decorative-only markup.
- Debug reference overlays must be disabled by default and isolated behind a clear debug flag.

## Prohibited Final States

- A single whole-page screenshot used as the visible page.
- A whole-page screenshot with only transparent click boxes as the final deliverable.
- A canvas-only implementation of an ordinary component UI.
- Default library styling that visibly conflicts with the reference.
- Static markup that looks clickable but has no interaction.
- CSS-only imitations of complex icons, characters, game resources, trophies, gems, books, or illustrated backgrounds when those assets should be bitmaps.
- Raster assets with obvious unremoved backgrounds, halos, old UI fragments, or mismatched scale that make the page look pasted together.

## Allowed Development Aids

- Temporary reference underlay or overlay for alignment.
- Cropped assets extracted from the reference.
- Generated isolated assets with transparent backgrounds.
- Generated clean background layers that intentionally omit source UI overlays.
- Screenshot-diff scripts and visual reports.
- Checkerboard/contact-sheet previews for validating transparent asset quality.
- Hidden measurement guides and bounding-box maps.

Development aids must not become the production visible UI.
