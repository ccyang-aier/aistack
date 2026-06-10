# Snap2UI Agent Roles

Use these roles when multi-agent tools are available. If they are unavailable, perform the roles sequentially in the main agent and keep the same outputs.

## Visual Decomposer

Goal: turn the screenshot into an implementation-ready map.

Output:

- Canvas and viewport metrics.
- Full layout tree.
- Region bounding boxes.
- Component inventory.
- Per-element implementation strategy.
- Asset extraction/generation list.
- Asset risk list: which assets are clean crops, which need alpha extraction, which should be regenerated with imagegen, and which should remain DOM/CSS.
- Interaction expectations.
- Risk list for areas likely to drift.

## Component Architect

Goal: convert the decomposition into frontend structure.

Output:

- Framework and stack decision.
- Component tree.
- File plan.
- Token plan for colors, radius, shadows, spacing, typography, and z-index.
- Asset plan for source crops, generated sprites, generated backgrounds, processing scripts, and project-local output paths.
- Shared component boundaries.
- State and interaction model.

## Implementer

Goal: create the real componentized frontend.

Rules:

- Build visible UI with DOM/CSS/components.
- Use reference image only as a hidden or debug-only oracle.
- Use local/generated assets only for isolated static art.
- Do not hand-draw complex game icons, characters, gems, trophies, books, painterly props, or illustrated backgrounds in CSS. Use bitmap assets and CSS only for placement, sizing, shadows, and simple surfaces.
- When source crops carry old UI fragments or fail alpha validation, generate style-compatible replacement assets rather than forcing poor crops into the UI.
- Preserve existing project conventions.
- Keep layout stable at reference viewport dimensions before adding responsive behavior.

## Visual Validator

Goal: verify visual parity and interaction behavior.

Output:

- Screenshot comparison notes.
- Section-level mismatch report.
- DOM contract failures.
- Asset contract failures: CSS approximations of complex art, source UI fragments in crops, poor alpha, inconsistent icon scale, or background art containing duplicated UI.
- Interaction failures.
- Concrete fix list ordered by visual impact.

## Refiner

Goal: close the mismatch report.

Output:

- Exact changed regions.
- Before/after validation summary.
- Remaining acceptable deltas, if any.
