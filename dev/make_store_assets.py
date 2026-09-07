"""Play Store gorsellerini sifirdan cizer.

Hicbir hazir gorsel ya da font kullanilmaz; her sey burada geometriyle
uretilir, boylece telif/lisans riski sifir kalir. Uygulama adi magaza
listesinde metin olarak zaten duruyor, o yuzden gorsellerde yazi yok.

    python dev/make_store_assets.py

Cikti: store/icon-512.png, store/feature-1024x500.png
"""

import os

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "store")

# Her sey bu kat kadar buyuk cizilip sonunda kucultulur. Pillow kalin cizgiyi
# parca parca cizdigi icin ek yerlerinde tirtik olusur; buyuk cizip kucultmek
# (supersampling) bunu temizler.
SS = 4

BG = (11, 18, 38)
BG_DEEP = (7, 11, 24)
GHOST = (127, 182, 255)
PLAYER = (255, 241, 210)
GLOW = (255, 200, 98)
AMBER = (255, 180, 84)
EXIT = (77, 224, 192)
FLOOR = (20, 30, 55)
EDGE = (31, 46, 82)

# Uygulama ikonundaki sonsuzluk yolu (108x108 birim uzayinda, vektorle ayni).
LOOP_PATH = [
    ((30, 54), (30, 42), (42, 42), (54, 54)),
    ((54, 54), (66, 66), (78, 66), (78, 54)),
    ((78, 54), (78, 42), (66, 42), (54, 54)),
    ((54, 54), (42, 66), (30, 66), (30, 54)),
]


def bezier(p0, p1, p2, p3, steps=160):
    """Kubik Bezier'i cizgi parcalarina orneklerim; Pillow egri cizemez."""
    points = []
    for i in range(steps + 1):
        t = i / steps
        u = 1 - t
        x = (u ** 3 * p0[0] + 3 * u * u * t * p1[0]
             + 3 * u * t * t * p2[0] + t ** 3 * p3[0])
        y = (u ** 3 * p0[1] + 3 * u * u * t * p1[1]
             + 3 * u * t * t * p2[1] + t ** 3 * p3[1])
        points.append((x, y))
    return points


def loop_points(scale, offset=(0, 0)):
    points = []
    for segment in LOOP_PATH:
        for x, y in bezier(*segment):
            points.append((x * scale + offset[0], y * scale + offset[1]))
    return points


def add_glow(image, halo, divisor=3):
    """Bulanik katmani zemine toplayarak isima etkisi verir."""
    return ImageChops.add(image, halo.point(lambda v: v // divisor))


def stroke_path(draw, points, radius, colour):
    """Yol boyunca dolu daireler damgalar.

    Pillow'un kalin `line` cizimi her parcayi ayri bir dikdortgen olarak koyar
    ve birlesim yerlerinde disari taşan diş diş kenarlar birakir. Daire
    damgalamak bu sorunu tamamen ortadan kaldirir: kenarlar dogal olarak
    yuvarlak ve puruzsuz olur.
    """
    for x, y in points:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius),
                     fill=colour)


def draw_loop(image, scale, offset, width, colour, blur=0):
    """Sonsuzluk isaretini, istenirse arkasina parilti koyarak cizer."""
    points = loop_points(scale, offset)
    if blur:
        halo = Image.new("RGB", image.size, (0, 0, 0))
        stroke_path(ImageDraw.Draw(halo), points, width * 1.1, colour)
        image = add_glow(image, halo.filter(ImageFilter.GaussianBlur(blur)))
    stroke_path(ImageDraw.Draw(image), points, width / 2, colour)
    return image


def vertical_gradient(size, top, bottom):
    image = Image.new("RGB", size)
    draw = ImageDraw.Draw(image)
    for y in range(size[1]):
        t = y / max(1, size[1] - 1)
        draw.line(
            [(0, y), (size[0], y)],
            fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)),
        )
    return image


def make_icon(path, size=512):
    big = size * SS
    image = Image.new("RGB", (big, big), BG)
    scale = big / 108
    image = draw_loop(image, scale, (0, 0), round(7 * scale), GHOST,
                      blur=big // 22)
    image.resize((size, size), Image.LANCZOS).save(path)
    return path


def make_feature(path, size=(1024, 500)):
    big = (size[0] * SS, size[1] * SS)
    image = vertical_gradient(big, BG, BG_DEEP)

    # Sol tarafta buyuk sonsuzluk isareti.
    scale = 3.1 * SS
    image = draw_loop(
        image, scale,
        (-2 * SS, big[1] / 2 - 54 * scale),
        round(7 * scale), GHOST, blur=26 * SS,
    )

    draw = ImageDraw.Draw(image)

    # Sag tarafta kucuk bir tahta: yanki, oyuncu, kapali kapi ve cikis.
    cell = 74 * SS
    cols, rows = 5, 3
    left = big[0] - cols * cell - 70 * SS
    top = (big[1] - rows * cell) // 2
    for r in range(rows):
        for c in range(cols):
            draw.rounded_rectangle(
                (left + c * cell + 5 * SS, top + r * cell + 5 * SS,
                 left + (c + 1) * cell - 5 * SS, top + (r + 1) * cell - 5 * SS),
                radius=14 * SS, fill=FLOOR, outline=EDGE, width=2 * SS,
            )

    def centre(c, r):
        return (left + c * cell + cell / 2, top + r * cell + cell / 2)

    # Kapali kapi (kehribar dolu blok)
    gx, gy = centre(3, 1)
    draw.rounded_rectangle(
        (gx - cell / 2 + 8 * SS, gy - cell / 2 + 8 * SS,
         gx + cell / 2 - 8 * SS, gy + cell / 2 - 8 * SS),
        radius=13 * SS, fill=AMBER)

    # Cikis: ic ice iki halka
    ex, ey = centre(4, 1)
    for radius, width in ((23 * SS, 4 * SS), (14 * SS, 3 * SS)):
        draw.ellipse((ex - radius, ey - radius, ex + radius, ey + radius),
                     outline=EXIT, width=width)

    # Yanki: mavi halka
    hx, hy = centre(1, 1)
    draw.ellipse((hx - 20 * SS, hy - 20 * SS, hx + 20 * SS, hy + 20 * SS),
                 outline=GHOST, width=5 * SS)

    # Oyuncu: sicak isik, arkasinda parilti
    px, py = centre(2, 1)
    halo = Image.new("RGB", big, (0, 0, 0))
    ImageDraw.Draw(halo).ellipse(
        (px - 26 * SS, py - 26 * SS, px + 26 * SS, py + 26 * SS), fill=GLOW)
    image = add_glow(image, halo.filter(ImageFilter.GaussianBlur(22 * SS)),
                     divisor=2)
    ImageDraw.Draw(image).ellipse(
        (px - 19 * SS, py - 19 * SS, px + 19 * SS, py + 19 * SS), fill=PLAYER)

    image.resize(size, Image.LANCZOS).save(path)
    return path


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for produced in (
        make_icon(os.path.join(OUT, "icon-512.png")),
        make_feature(os.path.join(OUT, "feature-1024x500.png")),
    ):
        print(f"{os.path.basename(produced):24s} "
              f"{os.path.getsize(produced) / 1024:6.1f} KB")
