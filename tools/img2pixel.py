#!/usr/bin/env python3
"""Convert a 1px-per-stitch image to Pixel Crochet (.txt) pattern format.

Usage:
    python img2pixel.py input.png [-o output.txt] [--name "Pattern Name"]
"""

import argparse
import os
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Missing dependency. Install it with: pip install Pillow")

YARN_COLORS = [
    ("black", (45, 45, 45)),
    ("gray", (158, 158, 158)),
    ("white", (245, 245, 245)),
    ("yellow", (255, 213, 79)),
    ("red", (229, 57, 53)),
    ("blue", (30, 136, 229)),
    ("green", (67, 160, 71)),
    ("brown", (141, 110, 99)),
    ("pink", (240, 98, 146)),
    ("purple", (142, 36, 170)),
    ("orange", (251, 140, 0)),
    ("teal", (0, 137, 123)),
    ("navy", (21, 101, 192)),
    ("cream", (255, 248, 225)),
    ("coral", (229, 115, 115)),
    ("lavender", (155, 142, 196)),
    ("charcoal", (66, 66, 66)),
    ("sky", (100, 181, 246)),
    ("mint", (129, 199, 132)),
    ("forest", (46, 125, 50)),
    ("maroon", (198, 40, 40)),
    ("burgundy", (136, 14, 79)),
    ("beige", (245, 230, 211)),
    ("tan", (212, 165, 116)),
    ("peach", (255, 204, 128)),
    ("gold", (249, 168, 37)),
    ("silver", (189, 189, 189)),
    ("magenta", (233, 30, 99)),
    ("indigo", (40, 53, 147)),
    ("olive", (130, 119, 23)),
    ("turquoise", (0, 188, 212)),
    ("rose", (244, 143, 177)),
]


def closest_color_name(r, g, b):
    min_dist = float("inf")
    best = "white"
    for name, (cr, cg, cb) in YARN_COLORS:
        dr = r - cr
        dg = g - cg
        db = b - cb
        dist = dr * dr + dg * dg + db * db
        if dist < min_dist:
            min_dist = dist
            best = name
    return best


def compress_blocks(pixels):
    blocks = []
    if not pixels:
        return blocks
    current_color = pixels[0]
    count = 1
    for p in pixels[1:]:
        if p == current_color:
            count += 1
        else:
            blocks.append((count, current_color))
            current_color = p
            count = 1
    blocks.append((count, current_color))
    return blocks


def main():
    parser = argparse.ArgumentParser(
        description="Convert a 1px-per-stitch image to Pixel Crochet pattern format."
    )
    parser.add_argument("input", help="Path to input image (PNG, BMP, etc.)")
    parser.add_argument("-o", "--output", help="Output .txt path (default: <input_name>.txt)")
    parser.add_argument("--name", help="Pattern name (if omitted, prompts interactively)")
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        sys.exit(f"File not found: {args.input}")

    # Name
    name = args.name
    if not name:
        name = input("Pattern name: ").strip()
    if not name:
        sys.exit("Pattern name is required.")

    img = Image.open(args.input).convert("RGB")
    w, h = img.size
    pixels = list(img.getdata())

    lines = [name, f"{w} x {h}"]

    for y in range(h):
        row_number = h - y
        row_pixels = [pixels[y * w + x] for x in range(w)]
        row_names = [closest_color_name(r, g, b) for (r, g, b) in row_pixels]

        direction = "<-" if y % 2 == 0 else "->"
        if y % 2 == 1:
            row_names.reverse()
        blocks = compress_blocks(row_names)

        lines.append(f"Row {row_number} {direction}: {', '.join(f'{c} {clr}' for c, clr in blocks)}")

    out_path = args.output or os.path.splitext(args.input)[0] + ".txt"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"Pattern written to {out_path}  ({w}x{h} stitches)")


if __name__ == "__main__":
    main()
