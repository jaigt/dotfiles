#!/usr/bin/env python3
"""Build logo.png -- the fastfetch logo -- from luffy-gear5.png.

Three things this does that a plain copy wouldn't:

1. Crops to the alpha bounding box, so the art fills its cells instead of
   sitting inside the source's transparent margin.

2. Mutes the art -- SAT pulls the chroma down and DIM takes the highlights off
   pure white -- so it sits in the Rosé Pine "graphite" palette instead of
   glaring out of it. Only the RGB is touched; ImageEnhance on an RGBA image
   scales the alpha channel too, which would fog the transparent pad rows into
   an opaque block against WezTerm's blurred background.

3. Pads the top with FULLY TRANSPARENT rows. fastfetch has no logo-only
   vertical offset -- `logo.padding.top` prints newlines before the entire
   render, so it moves the module column by exactly as much as the logo and the
   gap between them never closes. Baking transparent rows into the image is the
   only way to drop the art on its own.

   The bar has to be real alpha rather than a fill matching the terminal
   background: WezTerm runs at window_background_opacity 0.88 with blur, so any
   painted colour shows up as an opaque block against the blurred desktop.

Raising PAD_ROWS moves the art down and grows the canvas; keep `logo.height` in
config.jsonc equal to PHOTO_ROWS + PAD_ROWS. PHOTO_ROWS is bounded by the
module column, which the config renders ~15 rows tall.

fastfetch's iterm width/height are terminal cells, and WezTerm stretches the
image to fill them, so `logo.width` has to track the source aspect or the art
skews. The script prints both numbers -- run it, then copy them into
config.jsonc.

Needs Pillow.
"""
import os
import sys

from PIL import Image, ImageEnhance

SRC = os.path.expanduser("~/.config/fastfetch/luffy-gear5.png")
OUT = os.path.expanduser("~/.config/fastfetch/logo.png")

PHOTO_ROWS = 15  # how many terminal rows the art itself occupies
PAD_ROWS = 3     # transparent rows above it; 3 puts the art on OS..BAT
SAT = 0.72       # saturation multiplier; 1.0 is the source, 0.0 greyscale
DIM = 0.90       # brightness multiplier; 0.90 lands pure white near #e0def4

# Cell shape, px wide / px tall, measured off the layout this replaced:
# a 1446x1328 crop that sat correctly in 32 cells x 15 rows.
CELL_ASPECT = (1446 / 32) / (1328 / 15)


def mute(img):
    """SAT/DIM applied to the RGB of an RGBA image, alpha carried over as-is."""
    rgb = Image.merge("RGB", img.split()[:3])
    rgb = ImageEnhance.Color(rgb).enhance(SAT)
    rgb = ImageEnhance.Brightness(rgb).enhance(DIM)
    return Image.merge("RGBA", rgb.split() + (img.getchannel("A"),))


def main():
    src = os.path.expanduser(sys.argv[1]) if len(sys.argv) > 1 else SRC
    if not os.path.exists(src):
        sys.exit(f"no such source image: {src}")

    photo = Image.open(src).convert("RGBA")
    bbox = photo.getbbox()  # alpha-aware: tightest box holding a visible pixel
    if bbox is None:
        sys.exit(f"source image is fully transparent: {src}")
    photo = mute(photo.crop(bbox))

    w, h = photo.size
    row_px = h / PHOTO_ROWS
    pad = round(PAD_ROWS * row_px)

    canvas = Image.new("RGBA", (w, h + pad), (0, 0, 0, 0))
    canvas.paste(photo, (0, pad))
    canvas.save(OUT)

    width_cells = round(w / (row_px * CELL_ASPECT))
    print(f"wrote {OUT}  {w}x{h + pad}")
    print(f"  cropped to alpha bbox {bbox} of {src}")
    print(f"  art {PHOTO_ROWS} rows + {PAD_ROWS} transparent")
    print(f"  muted to SAT {SAT}, DIM {DIM}")
    print("  config.jsonc: set logo.width to "
          f"{width_cells}, logo.height to {PHOTO_ROWS + PAD_ROWS}")


if __name__ == "__main__":
    main()
