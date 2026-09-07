"""Kendi basina calisan gizlilik politikasi sayfasini uretir.

Ortak metin ve tasarim `dev/privacy-fragment.html` icinde durur; yayinlanan
Artifact surumu de ayni parcadan uretilmistir. Bu betik parcayi tam bir HTML
belgesine sarar ve **yazi tiplerini yanina indirir**: sayfanin kendisi disari
hicbir istek atmamali, cunku uygulamanin butun iddiasi bu.

    python dev/build_privacy_page.py

Cikti: docs/gizlilik.html, docs/fonts/*.woff2, docs/fonts/README.md
"""

import pathlib
import re
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
FONT_DIR = DOCS / "fonts"
FRAGMENT = ROOT / "dev" / "privacy-fragment.html"
OUTPUT = DOCS / "gizlilik.html"

# Sayfada gercekten kullanilan agirliklar; fazlasini indirmiyoruz.
FAMILIES = (
    "family=Sora:wght@600"
    "&family=IBM+Plex+Sans:wght@400;600"
    "&family=IBM+Plex+Mono:wght@400;500"
)
# Turkce icin latin-ext sart: ğ, ş, ı, İ o alt kumede.
WANTED_SUBSETS = {"latin", "latin-ext"}

# Google Fonts, tarayici olmayan istemcilere eski bicimleri gonderir.
BROWSER_UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)

LICENSES = {
    "Sora": ("Copyright 2020 The Sora Project Authors "
             "(https://github.com/be-fore/sora-typeface)"),
    "IBM Plex Sans": ("Copyright 2017 IBM Corp. "
                      "(https://github.com/IBM/plex)"),
    "IBM Plex Mono": ("Copyright 2017 IBM Corp. "
                      "(https://github.com/IBM/plex)"),
}


def fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": BROWSER_UA})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def download_fonts() -> str:
    """Yazi tiplerini indirir ve yerel @font-face kurallarini dondurur."""
    FONT_DIR.mkdir(parents=True, exist_ok=True)
    css = fetch(f"https://fonts.googleapis.com/css2?{FAMILIES}&display=swap")
    css = css.decode("utf-8")

    blocks = re.findall(
        r"/\*\s*([\w-]+)\s*\*/\s*@font-face\s*\{([^}]*)\}", css)
    if not blocks:
        raise RuntimeError("Google Fonts CSS'i beklenen bicimde degil.")

    rules = []
    for subset, body in blocks:
        if subset not in WANTED_SUBSETS:
            continue
        family = re.search(r"font-family:\s*'([^']+)'", body).group(1)
        weight = re.search(r"font-weight:\s*(\d+)", body).group(1)
        source = re.search(r"url\((https://[^)]+\.woff2)\)", body).group(1)
        unicode_range = re.search(r"unicode-range:\s*([^;]+);", body).group(1)

        name = f"{family.replace(' ', '')}-{weight}-{subset}.woff2"
        target = FONT_DIR / name
        if not target.exists():
            target.write_bytes(fetch(source))
            print(f"  indirildi  {name:34s} "
                  f"{target.stat().st_size / 1024:5.1f} KB")

        rules.append(
            "  @font-face {\n"
            f"    font-family: '{family}';\n"
            "    font-style: normal;\n"
            f"    font-weight: {weight};\n"
            "    font-display: swap;\n"
            f'    src: url("fonts/{name}") format("woff2");\n'
            f"    unicode-range: {unicode_range};\n"
            "  }"
        )

    write_font_notice()
    css_rules = "\n".join(rules)
    # Ayni kurallari tanitim sayfasi da kullanir; ortak dosyaya da yazilir.
    (DOCS / "fonts.css").write_text(css_rules + "\n", encoding="utf-8")
    return css_rules


def write_font_notice() -> None:
    """OFL, lisans metninin yazi tipleriyle birlikte dagitilmasini sart kosar."""
    lines = [
        "# Yazı tipleri",
        "",
        "Bu klasördeki `.woff2` dosyaları Google Fonts'tan indirilip sayfanın",
        "yanına konmuştur. Amaç, gizlilik politikası sayfasının kendisinin",
        "dışarıya hiçbir istek atmaması.",
        "",
        "Tamamı **SIL Open Font License 1.1** ile lisanslıdır; bu lisans",
        "yeniden dağıtıma izin verir ve lisans metninin yazı tipleriyle",
        "birlikte dağıtılmasını şart koşar (bkz. `OFL.txt`).",
        "",
    ]
    for family, notice in LICENSES.items():
        lines.append(f"- **{family}** — {notice}")
    lines.append("")
    lines.append("Lisans metni: <https://openfontlicense.org/>")
    lines.append("")
    (FONT_DIR / "README.md").write_text("\n".join(lines), encoding="utf-8")

    ofl = FONT_DIR / "OFL.txt"
    if not ofl.exists():
        try:
            ofl.write_bytes(fetch(
                "https://raw.githubusercontent.com/google/fonts/main/"
                "ofl/sora/OFL.txt"))
            print("  indirildi  OFL.txt")
        except Exception as error:  # noqa: BLE001 - lisans metni kritik degil
            print(f"  UYARI: OFL.txt indirilemedi ({error}); "
                  f"elle eklenmeli")


# Artifact sarmalayicisinin kendiliginden verdigi kurallar burada elle eklenir.
RESET = """
  *, *::before, *::after { box-sizing: border-box; }
  html { color-scheme: light; }
  @media (prefers-color-scheme: dark) {
    html:not([data-theme="light"]) { color-scheme: dark; }
  }
  html[data-theme="dark"] { color-scheme: dark; }
  body { margin: 0; }
  img { max-width: 100%; }
"""


def build(font_rules: str) -> None:
    source = FRAGMENT.read_text(encoding="utf-8")
    marker = '<div class="page">'
    head, body = source.split(marker, 1)
    body = marker + body

    # Google Fonts baglantisi yerel @font-face kurallariyla degistirilir.
    head = re.sub(r'<link rel="stylesheet" href="https://fonts\.googleapis[^>]*>\n?',
                  "", head)
    head = head.replace("<style>", "<style>\n" + font_rules + "\n" + RESET, 1)
    head = head.replace(
        "<title>Döngü Gizlilik Politikası</title>",
        "<title>Döngü — Gizlilik Politikası</title>", 1)

    OUTPUT.write_text(
        "<!DOCTYPE html>\n"
        '<html lang="tr">\n'
        "<head>\n"
        '<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
        '<meta name="description" content="Döngü hiçbir izin istemez, hiçbir '
        'veri toplamaz. Oyunun iki dilli gizlilik politikası.">\n'
        + head.strip()
        + "\n</head>\n<body>\n\n"
        + body.strip()
        + "\n\n</body>\n</html>\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    print("Yazi tipleri:")
    rules = download_fonts()
    build(rules)
    total = sum(f.stat().st_size for f in FONT_DIR.glob("*.woff2"))
    print(f"\n{OUTPUT.relative_to(ROOT)}  "
          f"{OUTPUT.stat().st_size / 1024:.1f} KB")
    print(f"{'yazi tipleri toplam':<24s}  {total / 1024:.1f} KB "
          f"({len(list(FONT_DIR.glob('*.woff2')))} dosya)")
    print(f"{'dis istek':<24s}  yok")
