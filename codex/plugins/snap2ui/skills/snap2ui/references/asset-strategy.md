# Snap2UI Asset Strategy

Snap2UI must rebuild the interface as real frontend components, but complex visual assets still need to be real bitmap assets. A poor asset strategy causes obvious seams: copied card backgrounds, status labels baked into portraits, icons with old UI fragments, duplicated hero text, or cheap CSS approximations.

## Decision Ladder

Use this ladder for every raster-like element during visual decomposition.

1. **DOM/CSS only**

   Use for layout, panels, borders, separators, tabs, buttons, simple pills, flat badges, plus signs, masks, shadows, gradients, and text.

   Do not use CSS to imitate complex icons, currency gems, trophies, books, characters, game props, painterly illustrations, pixel-art objects, or background scenes. If the asset depends on highlights, material, pixels, expressive shape, or painterly detail, use a bitmap.

2. **Clean source crop**

   Use when the source asset is already isolated, has enough resolution, and its bounding box does not include neighboring UI, labels, panel backgrounds, shadows from a different surface, or text that will be rebuilt as DOM.

3. **Crop plus alpha extraction**

   Use when the source crop is visually good but has removable background. Remove only the connected background, not interior highlights. Validate the output on a checkerboard before using it in the page.

   Avoid one universal threshold for all assets. Portraits, resource icons, navigation icons, and paper-like UI icons need different background-removal rules.

4. **Imagegen-generated replacement**

   Use when crop plus alpha fails or would carry old UI fragments, when the asset is too low quality, when the source is embedded in a panel/status strip, or when CSS would produce a visibly ugly approximation.

   The goal is style compatibility, not pixel-identical reproduction. Generate a similar transparent asset or sprite sheet, then remove chroma-key locally if needed. This is especially appropriate for game icons, resource currencies, small props, decorative badges, and icon sets.

5. **Imagegen-generated background**

   Use for illustrated hero/background layers when the source crop contains UI overlays, text, panels, or duplicated controls. Generate a clean non-UI background in the same art direction, then layer real DOM UI above it.

## Imagegen Workflow For Assets

- Use the imagegen skill when available for raster generation.
- For transparent assets, generate on a flat chroma-key background and remove the key locally, unless true transparency has been explicitly approved through that skill's fallback path.
- For multiple related icons, prefer a single sprite sheet prompt with a fixed grid. This keeps style, lighting, outline weight, and palette consistent.
- Save both the generated source sheet/background and the final sliced assets inside the project. Do not leave project-referenced assets only under `$CODEX_HOME/generated_images`.
- Name generated assets by usage, not by model id, such as `resource-heart.png`, `nav-home.png`, or `hero-office-generated.png`.
- Document the prompt summary and processing script when generated assets become part of the deliverable.

## Asset Validation Checklist

Before final delivery, validate every non-trivial raster asset:

- Show it on a checkerboard or contrasting background to catch halos, old panel fragments, status labels, or rectangular leftovers.
- Check actual page placement at the reference viewport. The asset must align with its DOM container and not look pasted from a different surface.
- Confirm repeated assets share consistent scale, padding, outline weight, and visual style.
- Confirm the source screenshot is not being used as a production-visible whole-page skin.
- Confirm generated backgrounds do not contain fake UI, readable text, buttons, cards, or panels that duplicate DOM components.

## Common Failure Modes

- **CSS-generated complex icons look cheap:** replace them with generated or cropped bitmap assets.
- **Cropped portrait includes a status tag:** crop earlier, regenerate, or separate the status as DOM.
- **Icon crop keeps old card background:** use alpha extraction or imagegen replacement.
- **Hero crop already contains title/KPI UI:** generate or obtain a clean background layer; rebuild title and KPI as DOM.
- **One threshold damages icons:** separate asset classes and use per-class extraction rules.
- **Generated asset style drifts:** generate related assets together as a set, then scale and place them consistently in CSS.
