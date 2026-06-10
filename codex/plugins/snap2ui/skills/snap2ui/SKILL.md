---
name: snap2ui
description: Use when the user asks to convert a screenshot, design image, game UI, mobile UI, dashboard capture, or reference image into a pixel-faithful frontend page. The final output must be a real componentized frontend, not a whole-image skin. Default to Next.js 15, React 19, Tailwind CSS 4, and Shadcn/UI only for new or unspecified projects; otherwise infer and preserve the existing project stack.
---

# Snap2UI

Snap2UI turns a reference image into a real, componentized frontend page with visual parity as the primary goal. The source image is a ruler and validation oracle, not the final visible implementation.

## Non-Negotiable Outcome

The final page must be a genuine frontend implementation:

- Use DOM, CSS, framework components, and local assets as the visible UI.
- Do not ship the whole source screenshot as the visible page, background, or skin.
- Do not use canvas/SVG drawing as a blanket replacement for the full UI.
- Preserve real text as editable/selectable text unless the source text is part of a tiny icon or raster asset.
- Implement expected interactions for visible controls: buttons, tabs, sliders, toggles, inputs, modals, navigation, hover/press states, and keyboard behavior where appropriate.
- Keep development-only reference overlays hidden from final output and removable without changing the implemented UI.
- Treat complex visual assets as raster assets, not CSS drawing exercises. CSS is for layout, surfaces, simple badges, borders, masks, shadows, and interaction states; do not hand-build intricate icons, game resources, portraits, painterly details, pixel-art objects, or illustrated backgrounds in CSS when a bitmap asset is needed.

## Stack Selection

Before implementing, identify the target stack:

1. If the user explicitly specifies a stack, follow it.
2. If working inside an existing project, inspect the project and use its existing framework, package manager, styling system, component library, routing, and build conventions.
3. If creating a new frontend and no stack is specified, default to:
   - Next.js 15 with App Router
   - React 19
   - Tailwind CSS 4
   - Shadcn/UI source components

When using Shadcn/UI, treat it as accessible component source and interaction primitives. Restyle it to match the screenshot exactly; never accept default Shadcn styling when it conflicts with the reference.

## Required Workflow

### 1. Visual Decomposition

Create a decomposition pass before coding. If multi-agent tools are available, spawn a dedicated visual decomposition agent. If not, perform the same work sequentially and write the decomposition in the working notes.

The decomposition must include:

- Original canvas size, target viewport, safe area, scaling model, and scroll behavior.
- Global background, outer frame, borders, shadows, texture, grain, pixel density, and color palette.
- A full layout tree from page root to leaf nodes.
- Bounding boxes for major regions and repeated components.
- Component inventory: cards, panels, buttons, tabs, sliders, lists, badges, nav items, icons, image assets, decorative strokes, masks, separators, highlights, and selected states.
- Implementation decision for each element: CSS/DOM, Shadcn primitive, local raster asset, generated transparent asset, text, CSS pseudo-element, or custom interaction.
- Asset risk classification for every raster-like element: clean crop, crop-plus-alpha, generated replacement, generated background, or DOM/CSS-only. Mark anything embedded inside another UI surface, touching text, carrying a status badge, or sharing the source page background as high risk.

Use image generation only for isolated assets that are genuinely static art, such as portraits, product thumbnails, tiny icons, texture chips, transparent sprites, or non-UI illustrated backgrounds. Do not generate or reuse the full page as the implementation.

Before implementing asset-heavy screens, read `references/asset-strategy.md` and choose an asset path explicitly. The common escalation is: DOM/CSS for simple surfaces -> source crop when clean -> crop plus alpha when edges are separable -> imagegen-generated transparent/background asset when crop quality is poor or CSS would be ugly.

### 2. Component Architecture

Map the decomposition into small, named components before styling:

- Page shell and viewport frame
- Header/status strip
- Content sections and panels
- Repeated cards or rows
- Interactive controls
- Navigation
- Asset components
- Debug-only reference overlay

For the default stack, prefer this shape:

```text
app/page.tsx
app/globals.css
components/snap2ui/<PageName>.tsx
components/snap2ui/<SectionName>.tsx
components/snap2ui/<RepeatedComponent>.tsx
components/ui/*
lib/snap2ui/visual-tokens.ts
lib/snap2ui/reconstruction-map.ts
public/snap2ui/<asset-files>
```

### 3. Layout First, Effects Second

Rebuild the UI in this order:

1. Match canvas, viewport, scroll area, and page bands.
2. Lock global spacing, section heights, grids, and bounding boxes.
3. Implement repeated components with stable dimensions.
4. Add typography, borders, shadows, gradients, pixel-art edge treatments, and surface textures.
5. Add static assets using the asset strategy: validate crops on a checkerboard, keep generated source sheets/backgrounds in the project, and use CSS only to size/position bitmap assets.
6. Add selected/active states.
7. Add interactions.
8. Add responsive behavior only after the reference-size layout is stable.

Avoid starting from decorative drawing. The page should first look structurally correct with plain boxes; then progressively converge toward the reference.

### 4. Validation Loop

After implementation, use browser rendering and screenshot comparison:

- Render at the original screenshot dimensions or a mathematically equivalent mobile viewport.
- Capture a full-page screenshot.
- Compare global image difference and section-level differences.
- Inspect the DOM contract: real components, real text, interactive controls, no production whole-image skin.
- Test key interactions manually or with browser automation.
- Produce a short validation report listing exact mismatches by region.
- Refine and repeat until the implementation is visually aligned.

Use `scripts/check_output_contract.py` from this plugin when possible to catch stack drift and whole-image-skin regressions.

## Final Delivery Checklist

Before final response, confirm:

- The final visible UI does not depend on the full original screenshot.
- The project stack matches the user request or existing project.
- Major visual regions match the source at reference viewport size.
- Repeated components are implemented as components, not copied manually.
- All visible controls have useful click/drag/toggle/navigation behavior.
- The source image is only used as a hidden/debug reference or for asset extraction.
- Build, lint, typecheck, or the closest available local verification has run.
- Browser screenshot validation has run for visually important work.

## Final Response

Keep the response concise. Include the changed files, validation performed, known residual mismatches if any, and how to preview the result.
