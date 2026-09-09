"""Magaza icin ekran goruntulerini emulatorden toplar.

Cozumler dev/solution_export.dart ciktisindan okunur; boylece "guzel an"
elle aranmaz, istenen hamlede durdurulur.

    dart run dev/solution_export.dart > solutions.txt
    python dev/make_screenshots.py solutions.txt

Gezinme koordinatla kart aramaz. Istenen seviyeden onceki butun bolumler
bitmis gibi tohumlanir; uygulama "Oyna" dedigimizde zaten oraya acilir.
Eski surum kartlari kaydirarak buluyordu ve haritalar degisince sessizce
yanlis ekrani cekiyordu - iki kare birebir ayni cikmisti.
"""

import os
import subprocess
import sys
import time

ADB = os.path.join(os.environ["LOCALAPPDATA"], "Android", "Sdk",
                   "platform-tools", "adb.exe")
PKG = "com.egeayvaz.dongu"
PREFS = "shared_prefs/FlutterSharedPreferences.xml"
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "store", "screenshots")

TAPS = {"U": (540, 1741), "D": (540, 2053), "L": (360, 1898),
        "R": (718, 1898), "W": (540, 1898)}
NEW_LOOP = (540, 2232)
PLAY = (540, 1406)
LEVELS = (540, 1574)
ENDING = (540, 1645)   # yalnizca oyun bitince cikan baglanti


def adb(*args, timeout=90):
    return subprocess.run([ADB, *args], capture_output=True, text=True,
                          timeout=timeout)


def tap(x, y, wait=0.32):
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(wait)


def shot(name):
    os.makedirs(OUT, exist_ok=True)
    raw = subprocess.run([ADB, "exec-out", "screencap", "-p"],
                         capture_output=True, timeout=60).stdout
    path = os.path.join(OUT, name)
    with open(path, "wb") as handle:
        handle.write(raw)
    print(f"{name:28s} {len(raw) / 1024:6.1f} KB", flush=True)


def seed(done_through, pars, locale="tr"):
    """1..done_through arasi par ile bitirilmis; sonrasi kilitli.

    Boylece hem yildizlar gorunur hem de "Oyna" tam istenen bolume acilir.
    """
    rows = "\n".join(
        f'    <long name="flutter.best_{i}" value="{pars[i]}" />'
        for i in range(1, done_through + 1))
    local = os.path.join(os.environ["TEMP"], "dongu_shot_prefs.xml")
    with open(local, "w", encoding="utf-8") as handle:
        handle.write(
            "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n<map>\n"
            f'    <string name="flutter.locale">{locale}</string>\n'
            '    <boolean name="flutter.introSeen" value="true" />\n'
            '    <boolean name="flutter.sound" value="false" />\n'
            f"{rows}\n</map>\n")
    adb("shell", "am", "force-stop", PKG)
    adb("push", local, "/data/local/tmp/shot_prefs.xml")
    adb("shell", f"run-as {PKG} cp /data/local/tmp/shot_prefs.xml {PREFS}")


def launch(wait=15):
    adb("shell", "am", "start", "-n", f"{PKG}/.MainActivity")
    time.sleep(wait)


def play(loops, stop_before=0):
    """Cozumu oynar; son dongunun son `stop_before` hamlesini yapmaz."""
    for index, loop in enumerate(loops):
        moves = loop
        if index == len(loops) - 1 and stop_before:
            moves = loop[:len(loop) - stop_before]
        for move in moves:
            tap(*TAPS[move])
        if index < len(loops) - 1:
            tap(*NEW_LOOP, wait=1.1)
    time.sleep(1.2)


def load(path):
    pars, loops = {}, {}
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if line and "|" in line:
            level_id, par, rest = line.split("|", 2)
            pars[int(level_id)] = int(par)
            loops[int(level_id)] = rest.split(",")
    return pars, loops


def level_shot(name, level_id, pars, loops, stop_before):
    """Istenen bolumu acar, cozumu belli bir ana kadar oynar, kareyi alir."""
    seed(level_id - 1, pars)
    launch()
    tap(*PLAY, wait=3.2)
    play(loops[level_id], stop_before=stop_before)
    shot(name)


def main():
    pars, loops = load(sys.argv[1])
    total = max(pars)

    # 1-2: ana ekran ve liste. Yarisi bitmis bir kayit hem yildizlari hem
    # kilitleri gosterir; liste artik kalinan yerden aciliyor.
    seed(59, pars)
    launch()
    shot("01-ana-ekran.png")
    tap(*LEVELS, wait=2.5)
    shot("02-seviyeler.png")

    # 3: iki yanki iki plakada, ucuncu kilidi dugme aciyor; uc kapi da acik.
    level_shot("03-yankilar.png", 78, pars, loops, stop_before=4)

    # 4: bastan asagi buz. Kayma, dugme, plaka ve iki kapi tek karede.
    level_shot("04-mekanikler.png", 94, pars, loops, stop_before=1)

    # 5: kazanma katmani.
    level_shot("05-kazanma.png", 98, pars, loops, stop_before=0)

    # 6: kapanis ekrani. Halka 0.62'de kapanip oyuncu merkeze cekiliyor;
    # yaklasik dorduncu saniyede tam kare olusuyor.
    seed(total, pars)
    launch()
    tap(*ENDING, wait=4.2)
    shot("06-kapanis.png")

    print(f"\nEkran goruntuleri: {OUT}")


if __name__ == "__main__":
    main()
