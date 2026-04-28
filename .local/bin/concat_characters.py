#!/usr/bin/env python3
"""
concat_characters.py

Concatenates character lifepath, profile, and voice markdown files
into a single reference file per character.

Usage:
    python concat_characters.py \
        --lifepaths /path/to/Lifepaths \
        --profiles /path/to/Character\ Profiles/PCs \
        --voices /path/to/Character\ Profiles/Voice\ Documents/Platonic \
        --output /path/to/output \
        --characters "Alice,Bob,Charlie"
"""

import argparse
import sys
from pathlib import Path


SECTION_ORDER = [
    ("lifepaths", "{name}_lifepath.md"),
    ("profiles",  "{name}_profile.md"),
    ("voices",    "{name}_voice.md"),
]

SEPARATOR = "\n\n---\n\n"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Concatenate character lifepath, profile, and voice files."
    )
    parser.add_argument("--lifepaths",  required=True, help="Directory containing lifepath files.")
    parser.add_argument("--profiles",   required=True, help="Directory containing profile files.")
    parser.add_argument("--voices",     required=True, help="Directory containing voice files.")
    parser.add_argument("--output",     required=True, help="Directory to write concatenated files.")
    parser.add_argument("--characters", required=True, help="Comma-separated list of character names.")
    return parser.parse_args()


def resolve_dirs(args):
    dirs = {
        "lifepaths": Path(args.lifepaths),
        "profiles":  Path(args.profiles),
        "voices":    Path(args.voices),
        "output":    Path(args.output),
    }
    errors = []
    for key, path in dirs.items():
        if key == "output":
            path.mkdir(parents=True, exist_ok=True)
        elif not path.is_dir():
            errors.append(f"  [{key}] not found or not a directory: {path}")
    if errors:
        print("ERROR: One or more input directories are invalid:")
        print("\n".join(errors))
        sys.exit(1)
    return dirs


def parse_characters(raw: str) -> list[str]:
    return [name.strip() for name in raw.split(",") if name.strip()]


def read_file(path: Path, character: str, section: str) -> str | None:
    if not path.exists():
        print(f"  WARNING: Missing {section} file for '{character}': {path}")
        return None
    return path.read_text(encoding="utf-8")


def concatenate(character: str, dirs: dict) -> str | None:
    sections = []
    dir_keys = ["lifepaths", "profiles", "voices"]

    for dir_key, filename_template in SECTION_ORDER:
        filename = filename_template.format(name=character)
        filepath = dirs[dir_key] / filename
        content = read_file(filepath, character, dir_key)
        if content is None:
            return None  # Abort this character — missing file
        sections.append(content.strip())

    return SEPARATOR.join(sections)


def write_output(character: str, content: str, output_dir: Path):
    out_path = output_dir / f"{character}_reference.md"
    out_path.write_text(content + "\n", encoding="utf-8")
    print(f"  Written: {out_path}")


def main():
    args = parse_args()
    dirs = resolve_dirs(args)
    characters = parse_characters(args.characters)

    if not characters:
        print("ERROR: No character names provided.")
        sys.exit(1)

    print(f"\nProcessing {len(characters)} character(s)...\n")

    success, skipped = 0, 0
    for character in characters:
        print(f"[{character}]")
        content = concatenate(character, dirs)
        if content is None:
            print(f"  SKIPPED: '{character}' due to missing file(s).\n")
            skipped += 1
        else:
            write_output(character, content, dirs["output"])
            success += 1
        print()

    print(f"Done. {success} written, {skipped} skipped.")


if __name__ == "__main__":
    main()