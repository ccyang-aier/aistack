# Snap2UI Validation Loop

Use this loop for every visually important reconstruction.

## 1. Browser Render

- Open the implemented page in a browser.
- Set the viewport to the reference size or the intended mobile size.
- Capture a screenshot.
- Check that fonts, images, and CSS assets are loaded.
- Check that generated or cropped assets resolve from project-local paths, not only from the imagegen output cache.

## 2. Visual Compare

Compare the rendered screenshot against the source:

- Global alignment.
- Section heights and widths.
- Left/right/top/bottom offsets.
- Text weight, color, and line height.
- Border radius and stroke thickness.
- Shadow direction and opacity.
- Image crop and scale.
- Asset seams: old backgrounds, halos, baked-in labels, mismatched scale, damaged alpha, or CSS-drawn icons that look cheaper than the reference.
- Active/selected states.
- Scroll position and fixed bars.

For complex pages, compare by section instead of only as one full image.

## 3. Interaction Verify

Test all visible interactive controls:

- Buttons have press/click state.
- Tabs switch selected state and content.
- Sliders drag and respond to keyboard when appropriate.
- Toggles change state.
- Nav items update active state or route.
- Scrollable regions actually scroll.

## 4. DOM Contract Verify

Check the implementation for:

- No production-visible whole-source screenshot.
- No full-page skin layer.
- No unapproved canvas-only UI.
- Real text nodes for labels and values.
- Components rather than one-off repeated markup.
- Existing stack conventions preserved.
- Complex visual assets are real bitmap assets when appropriate; CSS is not being used to hand-draw intricate icons, characters, game resources, or illustrated backgrounds.
- Cropped/generated assets are isolated from the source UI and do not carry old panel fragments or duplicated text.

## 5. Asset Audit

For asset-heavy screens, create or inspect a checkerboard/contact-sheet preview of extracted and generated assets before finalizing. Verify:

- Transparent corners and clean alpha edges.
- No source UI fragments or rectangular leftovers.
- Consistent icon scale, outline weight, palette, and padding.
- Generated hero/background layers are clean scene art without fake UI panels or readable text.

## 6. Refine

Create a short mismatch report, fix the highest-impact mismatch first, and repeat the loop.
