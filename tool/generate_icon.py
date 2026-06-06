#!/usr/bin/env python3
"""Generate the Loops branded app icon source images.

Produces two master 1024x1024 PNGs under assets/icon/:
  * app_icon.png            — full icon (brand-pink rounded square + white loop/play mark)
  * app_icon_foreground.png — transparent, logo only, sized for the Android adaptive safe zone

Everything is drawn at 4x and downscaled with LANCZOS for crisp anti-aliasing.
The mark is a circular "loop" arrow wrapping a play triangle — i.e. a looping video.
"""
import math
from PIL import Image, ImageDraw

BRAND = (255, 45, 85, 255)        # #FF2D55 Loops brand pink
BRAND_DARK = (214, 32, 70, 255)   # subtle darker pink for the diagonal gradient
WHITE = (255, 255, 255, 255)

SS = 4                 # supersampling factor
SIZE = 1024
S = SIZE * SS


def vertical_gradient(size, top, bottom):
    """A simple top->bottom linear gradient image."""
    grad = Image.new("RGBA", (1, size), top)
    px = grad.load()
    for y in range(size):
        t = y / (size - 1)
        px[0, y] = tuple(round(top[i] * (1 - t) + bottom[i] * t) for i in range(4))
    return grad.resize((size, size))


def rounded_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


def draw_mark(draw, cx, cy, R, stroke):
    """White circular loop arrow + centered play triangle.

    cx, cy   center; R loop radius; stroke ring thickness.
    The ring has a gap near the top-right where an arrowhead sits, giving the
    "refresh / loop" feel.
    """
    # Loop ring with a gap (start/end leave room for the arrowhead).
    bbox = [cx - R, cy - R, cx + R, cy + R]
    draw.arc(bbox, start=-50, end=210, fill=WHITE, width=stroke)

    # Arrowhead at the open end of the arc (~ -50deg position), pointing along
    # the tangent (counter-clockwise sweep) to read as motion.
    ang = math.radians(-50)
    ex = cx + R * math.cos(ang)
    ey = cy + R * math.sin(ang)
    h = stroke * 1.7  # arrowhead half-size
    # Tangent direction (derivative of the circle) for a clockwise-closing arrow.
    tx, ty = math.sin(ang), -math.cos(ang)
    # Normal direction.
    nx, ny = math.cos(ang), math.sin(ang)
    p1 = (ex + tx * h * 1.3, ey + ty * h * 1.3)
    p2 = (ex - tx * h * 0.4 + nx * h, ey - ty * h * 0.4 + ny * h)
    p3 = (ex - tx * h * 0.4 - nx * h, ey - ty * h * 0.4 - ny * h)
    draw.polygon([p1, p2, p3], fill=WHITE)

    # Centered play triangle.
    pr = R * 0.46
    # Equilateral-ish triangle pointing right, optically centered.
    off = pr * 0.18
    t1 = (cx - pr * 0.55 + off, cy - pr * 0.85)
    t2 = (cx - pr * 0.55 + off, cy + pr * 0.85)
    t3 = (cx + pr * 0.95 + off, cy)
    draw.polygon([t1, t2, t3], fill=WHITE)


def make_full():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    # Brand gradient clipped to a rounded square.
    grad = vertical_gradient(S, BRAND, BRAND_DARK)
    mask = rounded_mask(S, radius=int(S * 0.235))   # ~iOS squircle-ish corner
    img.paste(grad, (0, 0), mask)

    draw = ImageDraw.Draw(img)
    draw_mark(draw, S // 2, S // 2, R=int(S * 0.255), stroke=int(S * 0.072))

    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    img.save("assets/icon/app_icon.png")


def make_foreground():
    # Transparent canvas; logo scaled into the adaptive-icon safe zone (~62%).
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_mark(draw, S // 2, S // 2, R=int(S * 0.205), stroke=int(S * 0.058))
    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    img.save("assets/icon/app_icon_foreground.png")


if __name__ == "__main__":
    import os
    os.makedirs("assets/icon", exist_ok=True)
    make_full()
    make_foreground()
    print("wrote assets/icon/app_icon.png and assets/icon/app_icon_foreground.png")
