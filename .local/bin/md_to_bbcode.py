#!/usr/bin/env python3
"""
md_to_bbcode.py — Converts Raven's Call scene Markdown files to RPGG BBCode format.

Usage:
    python md_to_bbcode.py <input_file> [--offset N] [--output <output_file>]

Arguments:
    input_file      Path to the Markdown scene file.
    --offset N      Integer offset applied to the internal scene number to get
                    the published session number. Default: 0.
                    Example: if Scene 28 publishes as Session 26, use --offset -2
    --output PATH   Path for the output file. Default: same directory as input,
                    with _bbcode.txt suffix.

Examples:
    python md_to_bbcode.py "Scenes/Scene 20.md" --offset -2
    python md_to_bbcode.py "Scenes/Scene 20.md" --offset -2 --output "output/session_18.txt"
"""

import re
import sys
import argparse
from pathlib import Path


# ---------------------------------------------------------------------------
# Metadata table parsing
# ---------------------------------------------------------------------------

def parse_metadata_table(text: str) -> dict[str, str]:
    """
    Extract key/value pairs from the Mythic metadata Markdown table.

    Expected format (the column separator row is ignored):
        | **Key** | Value |
        |---------|-------|
    """
    metadata = {}
    # Match rows with exactly two cells; strip bold markers from keys
    row_pattern = re.compile(r'^\|\s*\*?\*?(.+?)\*?\*?\s*\|\s*(.+?)\s*\|', re.MULTILINE)
    for match in row_pattern.finditer(text):
        key = match.group(1).strip()
        value = match.group(2).strip()
        # Skip the separator row (e.g. |---|---|)
        if re.match(r'^[-:| ]+$', key):
            continue
        metadata[key] = value
    return metadata


# ---------------------------------------------------------------------------
# Markdown → BBCode inline conversion
# ---------------------------------------------------------------------------

def inline_md_to_bbcode(text: str) -> str:
    """Convert inline Markdown formatting to BBCode equivalents."""

    # Bold+italic (***text*** or ___text___) — must come before bold/italic
    text = re.sub(r'\*\*\*(.+?)\*\*\*', r'[b][i]\1[/i][/b]', text)
    text = re.sub(r'___(.+?)___', r'[b][i]\1[/i][/b]', text)

    # Bold (**text** or __text__)
    text = re.sub(r'\*\*(.+?)\*\*', r'[b]\1[/b]', text)
    text = re.sub(r'__(.+?)__', r'[b]\1[/b]', text)

    # Italic (*text* or _text_)
    text = re.sub(r'\*(.+?)\*', r'[i]\1[/i]', text)
    text = re.sub(r'(?<!\w)_(.+?)_(?!\w)', r'[i]\1[/i]', text)

    # Inline code (`code`)
    text = re.sub(r'`(.+?)`', r'[tt]\1[/tt]', text)

    # Strikethrough (~~text~~)
    text = re.sub(r'~~(.+?)~~', r'[s]\1[/s]', text)

    # Hyperlinks [text](url) → [url=url]text[/url]
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'[url=\2]\1[/url]', text)

    # Images — replace with placeholder tag
    # ![alt](url) → [TODO IMG: filename]
    def image_placeholder(m):
        url = m.group(2)
        filename = url.rstrip('/').split('/')[-1]
        return f'[TODO IMG: {filename}]'
    text = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', image_placeholder, text)

    return text


# ---------------------------------------------------------------------------
# Block-level Markdown → BBCode conversion
# ---------------------------------------------------------------------------

def blocks_to_bbcode(text: str) -> str:
    """
    Convert a block of Markdown text to BBCode, line by line.
    Handles:
        - Headings (## and ###) → [b][size=12]...[/size][/b]
        - Horizontal rules (---) → [hr]
        - Unordered list items (- item, * item) → [list][*]...[/list]
        - Numbered list items → [list=1][*]...[/list]
        - Blank lines → paragraph breaks
        - Inline formatting via inline_md_to_bbcode()
    """
    lines = text.split('\n')
    output_parts = []
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Horizontal rule
        if re.match(r'^---+$', stripped) or re.match(r'^\*\*\*+$', stripped):
            output_parts.append('[hr]')
            i += 1
            continue

        # H2 heading (## Heading)
        if stripped.startswith('## '):
            heading_text = inline_md_to_bbcode(stripped[3:].strip())
            output_parts.append(f'[b][size=12]{heading_text}[/size][/b]')
            i += 1
            continue

        # H3 heading (### Heading)
        if stripped.startswith('### '):
            heading_text = inline_md_to_bbcode(stripped[4:].strip())
            output_parts.append(f'[b]{heading_text}[/b]')
            i += 1
            continue

        # H1 headings inside body text (shouldn't normally appear, but handle gracefully)
        if stripped.startswith('# '):
            heading_text = inline_md_to_bbcode(stripped[2:].strip())
            output_parts.append(f'[b][size=14]{heading_text}[/size][/b]')
            i += 1
            continue

        # Unordered list — collect consecutive list items
        if re.match(r'^[-*+] ', stripped):
            list_items = []
            while i < len(lines) and re.match(r'^[-*+] ', lines[i].strip()):
                item_text = inline_md_to_bbcode(lines[i].strip()[2:].strip())
                list_items.append(f'[*]{item_text}')
                i += 1
            output_parts.append('[list]' + ''.join(list_items) + '[/list]')
            continue

        # Ordered list — collect consecutive numbered items
        if re.match(r'^\d+\. ', stripped):
            list_items = []
            while i < len(lines) and re.match(r'^\d+\. ', lines[i].strip()):
                item_text = inline_md_to_bbcode(re.sub(r'^\d+\. ', '', lines[i].strip()))
                list_items.append(f'[*]{item_text}')
                i += 1
            output_parts.append('[list=1]' + ''.join(list_items) + '[/list]')
            continue

        # Blank line → paragraph break (empty string, cleaned up later)
        if stripped == '':
            output_parts.append('')
            i += 1
            continue

        # Regular paragraph line
        output_parts.append(inline_md_to_bbcode(stripped))
        i += 1

    # Collapse runs of more than one blank line into a single blank line
    result_lines = []
    prev_blank = False
    for part in output_parts:
        if part == '':
            if not prev_blank:
                result_lines.append('')
            prev_blank = True
        else:
            result_lines.append(part)
            prev_blank = False

    return '\n'.join(result_lines).strip()


# ---------------------------------------------------------------------------
# Document structure parsing
# ---------------------------------------------------------------------------

def extract_scene_number(filepath: Path) -> int | None:
    """
    Extract the integer scene number from the filename.
    Handles: 'Scene 20.md', 'Scene_20.md', 'Scene 0 - Prelude.md'
    Returns None if no number found.
    """
    match = re.search(r'Scene[\s_]+(\d+)', filepath.stem, re.IGNORECASE)
    if match:
        return int(match.group(1))
    return None


def extract_title_from_h1(h1_text: str) -> str:
    """Return the full H1 text as the scene title, stripped of leading/trailing whitespace."""
    return h1_text.strip()

def parse_scene_file(text: str) -> dict:
    """
    Parse a scene Markdown file into its component parts.

    Returns a dict with keys:
        h1_raw        — raw H1 text (empty string if absent)
        metadata      — dict of Mythic metadata key/value pairs
        action_body   — Markdown text of the narrative body
        mechanics     — Markdown text of the Mechanics section
        bookkeeping   — Markdown text of the Bookkeeping section
    """
    result = {
        'h1_raw': '',
        'metadata': {},
        'action_body': '',
        'mechanics': '',
        'bookkeeping': '',
    }

    text = re.sub(r'<br\s*/?>', ' ', text)  # replace <br> with double space
    text = re.sub(r'<[^>]+>', '', text)       # strip remaining HTML tags

    # Extract H1 (first line starting with a single #)
    h1_match = re.match(r'^# (.+)$', text, re.MULTILINE)
    if h1_match:
        result['h1_raw'] = h1_match.group(1).strip()

    # Remove the H1 line from the text for further parsing
    text_no_h1 = re.sub(r'^# .+\n?', '', text, count=1, flags=re.MULTILINE)

    # Split on ## section headings
    # Sections we care about: Mechanics, Bookkeeping
    # Everything before the first ## section is the action body (plus metadata table)
    mechanics_match = re.search(r'^## Mechanics\s*$', text_no_h1, re.MULTILINE | re.IGNORECASE)
    bookkeeping_match = re.search(r'^## Bookkeeping\s*$', text_no_h1, re.MULTILINE | re.IGNORECASE)

    # Determine slice boundaries
    mech_start = mechanics_match.start() if mechanics_match else len(text_no_h1)
    book_start = bookkeeping_match.start() if bookkeeping_match else len(text_no_h1)

    pre_sections = text_no_h1[:min(mech_start, book_start)]

    if mechanics_match and bookkeeping_match:
        mech_end = min(book_start, len(text_no_h1))
        result['mechanics'] = text_no_h1[mechanics_match.end():mech_end].strip()
        result['bookkeeping'] = text_no_h1[bookkeeping_match.end():].strip()
    elif mechanics_match:
        result['mechanics'] = text_no_h1[mechanics_match.end():].strip()
    elif bookkeeping_match:
        result['bookkeeping'] = text_no_h1[bookkeeping_match.end():].strip()

    # Parse metadata table from the pre-sections block
    result['metadata'] = parse_metadata_table(pre_sections)

    # Strip the metadata table from the action body
    # The table is a block of lines matching | ... | ... |
    # It ends at the first blank line or --- after the table
    action_body = re.sub(
        r'(\|[^\n]*\|\s*\n)+',  # one or more table rows
        '',
        pre_sections
    )
    # Also strip leading/trailing horizontal rules and blank lines
    action_body = re.sub(r'^---+\s*\n', '', action_body, flags=re.MULTILINE)
    result['action_body'] = action_body.strip()

    return result


# ---------------------------------------------------------------------------
# BBCode assembly
# ---------------------------------------------------------------------------

# Mapping from metadata table keys to template field labels
METADATA_MAP = {
    'Expectation': 'Mythic Scene Expectation',
    'Chaos': 'Chaos Factor',
    'Scene Type': 'Scene Type',
    'Location & Time': 'Location & time',
    'Ship Credits': 'Ship Credits',
}


def assemble_bbcode(parsed: dict, session_number: int, filename_stem: str = '') -> str:
    """Assemble the final BBCode output from parsed scene components."""

    meta = parsed['metadata']

    # --- Title line ---
    # Use full H1 as title; fall back to filename stem if H1 is absent
    scene_title = extract_title_from_h1(parsed['h1_raw']) if parsed['h1_raw'] else filename_stem
    if scene_title:
        title_line = f"The Raven's Call: Scene {session_number} - {scene_title}"
    else:
        title_line = f"The Raven's Call: Scene {session_number}"

    # --- Metadata fields ---
    def meta_val(key):
        return meta.get(key, '')

    expectation = meta_val('Expectation')
    chaos = meta_val('Chaos')
    scene_type = meta_val('Scene Type')
    location = meta_val('Location & Time')
    credits = meta_val('Ship Credits')

    # --- Body sections ---
    action_bbcode = blocks_to_bbcode(parsed['action_body'])
    mechanics_bbcode = blocks_to_bbcode(parsed['mechanics'])
    bookkeeping_bbcode = blocks_to_bbcode(parsed['bookkeeping'])

    # --- Static character sheets line ---
    char_sheets_line = '[b]Character Sheets & Setting: [/b][listitem=11665035]Game Info[/listitem]. Character sheets, game info, supplements, & solo tools.'

    output = f"""\
[b][size=18]{title_line}[/size][/b]
[b]Last Scene: [/b]-
[b]Next Scene: [/b]-
{char_sheets_line}
[b]Mythic Scene Expectation: [/b]{expectation}
[b]Chaos Factor: [/b]{chaos}
[b]Scene Type: [/b]{scene_type}
[b]Location & time: [/b]{location}
[b]Ship Credits: [/b]{credits}
[hr][b][size=14]Action[/size][/b]

{action_bbcode}
[hr][b][size=14]Mechanics[/size][/b]

{mechanics_bbcode}
[hr][b][size=14]Mythic Bookkeeping[/size][/b]

{bookkeeping_bbcode}"""

    return output


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description='Convert a Raven\'s Call Markdown scene file to RPGG BBCode.'
    )
    parser.add_argument('input_file', help='Path to the input Markdown scene file.')
    parser.add_argument(
        '--offset', type=int, default=0,
        help='Integer offset: published_session = scene_number + offset. Default: 0.'
    )
    parser.add_argument(
        '--output', default=None,
        help='Output file path. Default: input filename with _bbcode.txt suffix.'
    )
    args = parser.parse_args()

    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f'Error: file not found: {input_path}', file=sys.stderr)
        sys.exit(1)

    # Determine scene number and apply offset
    scene_number = extract_scene_number(input_path)
    if scene_number is None:
        print(
            f'Warning: could not extract scene number from filename "{input_path.name}". '
            'Using session number 0.',
            file=sys.stderr
        )
        session_number = 0
    else:
        session_number = scene_number + args.offset

    # Read and parse input
    text = input_path.read_text(encoding='utf-8')
    parsed = parse_scene_file(text)

    # Assemble output
    bbcode = assemble_bbcode(parsed, session_number, filename_stem=input_path.stem)

    # Write output
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.parent / (input_path.stem + '_bbcode.txt')

    output_path.write_text(bbcode, encoding='utf-8')
    print(f'Output written to: {output_path}')


if __name__ == '__main__':
    main()