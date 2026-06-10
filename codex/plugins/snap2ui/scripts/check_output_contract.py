#!/usr/bin/env python3
"""Check common Snap2UI output-contract regressions.

This script is intentionally conservative. It does not prove pixel perfection;
it catches the most common failures before visual review:

- shipping the whole source image as production UI
- relying on full-page skin/debug layers
- using canvas as the main implementation
- drifting away from the requested default stack for new projects
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Iterable


TEXT_EXTENSIONS = {
    ".css",
    ".html",
    ".js",
    ".jsx",
    ".md",
    ".mjs",
    ".mts",
    ".scss",
    ".ts",
    ".tsx",
}

IGNORED_PARTS = {
    ".git",
    ".next",
    "dist",
    "build",
    "node_modules",
    "coverage",
}

SKIN_PATTERNS = [
    r"source[-_ ]?page",
    r"source[-_ ]?image",
    r"source[-_ ]?screenshot",
    r"reference[-_ ]?skin",
    r"skin[-_ ]?layer",
    r"full[-_ ]?source[-_ ]?image",
    r"whole[-_ ]?page[-_ ]?image",
    r"debug[-_ ]?reference",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate a Snap2UI frontend output contract.")
    parser.add_argument("project", help="Generated frontend project root")
    parser.add_argument(
        "--source-filename",
        action="append",
        default=[],
        help="Original screenshot filename that must not be referenced by production UI",
    )
    parser.add_argument(
        "--allow-canvas",
        action="store_true",
        help="Allow canvas usage when the user explicitly requested a canvas-based result",
    )
    parser.add_argument(
        "--expect-next-stack",
        action="store_true",
        help="Require Next.js 15, React 19, Tailwind CSS 4, and Shadcn/UI markers",
    )
    return parser.parse_args()


def iter_text_files(root: Path) -> Iterable[Path]:
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        if any(part in IGNORED_PARTS for part in path.parts):
            continue
        yield path


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def scan_contract(root: Path, source_filenames: list[str], allow_canvas: bool) -> list[str]:
    errors: list[str] = []
    skin_re = re.compile("|".join(SKIN_PATTERNS), re.IGNORECASE)
    canvas_re = re.compile(r"<canvas\b|document\.createElement\([\"']canvas[\"']\)", re.IGNORECASE)
    source_names = [name.lower() for name in source_filenames if name.strip()]

    for path in iter_text_files(root):
        rel = path.relative_to(root)
        text = read_text(path)
        lowered = text.lower()

        for source_name in source_names:
            if source_name in lowered and not is_debug_path(rel):
                errors.append(f"{rel}: production code references source screenshot `{source_name}`")

        if skin_re.search(text) and not is_debug_path(rel):
            errors.append(f"{rel}: possible production full-image skin/reference layer")

        if not allow_canvas and canvas_re.search(text):
            errors.append(f"{rel}: canvas usage found; Snap2UI final UI should be component/DOM-first")

    return errors


def is_debug_path(path: Path) -> bool:
    normalized = "/".join(path.parts).lower()
    return any(part in normalized for part in ("/debug/", "/dev/", ".debug.", "debug-reference"))


def package_dependencies(root: Path) -> dict[str, str]:
    package_path = root / "package.json"
    if not package_path.is_file():
        return {}
    payload = json.loads(package_path.read_text(encoding="utf-8"))
    deps: dict[str, str] = {}
    for key in ("dependencies", "devDependencies"):
        value = payload.get(key, {})
        if isinstance(value, dict):
            deps.update({str(name): str(version) for name, version in value.items()})
    return deps


def major(version: str) -> int | None:
    match = re.search(r"(\d+)", version)
    if not match:
        return None
    return int(match.group(1))


def scan_next_stack(root: Path) -> list[str]:
    errors: list[str] = []
    deps = package_dependencies(root)
    checks = {
        "next": 15,
        "react": 19,
        "react-dom": 19,
        "tailwindcss": 4,
    }
    for package, expected_major in checks.items():
        found = deps.get(package)
        if found is None:
            errors.append(f"package.json: missing `{package}`")
            continue
        actual_major = major(found)
        if actual_major is None or actual_major < expected_major:
            errors.append(
                f"package.json: `{package}` should be major {expected_major}+; found `{found}`"
            )

    has_shadcn = (root / "components.json").is_file() or (root / "components" / "ui").is_dir()
    if not has_shadcn:
        errors.append("project: missing Shadcn/UI marker (`components.json` or `components/ui`)")

    return errors


def main() -> None:
    args = parse_args()
    root = Path(args.project).expanduser().resolve()
    errors: list[str] = []

    if not root.is_dir():
        raise SystemExit(f"Project root does not exist: {root}")

    errors.extend(scan_contract(root, args.source_filename, args.allow_canvas))
    if args.expect_next_stack:
        errors.extend(scan_next_stack(root))

    if errors:
        print("Snap2UI contract check failed:")
        for error in errors:
            print(f"- {error}")
        raise SystemExit(1)

    print(f"Snap2UI contract check passed: {root}")


if __name__ == "__main__":
    main()
