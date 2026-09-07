"""Magaza icin ekran goruntulerini emulatorden toplar.

Cozumler dev/solution_export.dart ciktisindan okunur; boylece "guzel an"
elle aranmaz, istenen hamlede durdurulur.

    python dev/make_screenshots.py solutions.txt
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
LEVELS_BUTTON = (540, 1573)
CARD_6 = (792, 1128)     # ilk ekranda 6. seviye karti
CARD_22 = (792, 2040)    # sona kaydirildiginda 22. seviye karti

PARS = {1: 0, 2: 1, 3: 1, 4: 2, 5: 1, 6: 2, 7: 1, 8: 1, 9: 2, 10: 2, 11: 1,
        12: 2, 13: 2, 14: 1, 15: 2, 16: 2, 17: 0, 18: 1, 19: 2, 20: 2, 21: 1,
        22: 2, 23: 1}


def adb(*args, timeout=60):
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


def seed_completed():
    """Butun seviyeler par ile bitirilmis: kilitler acik, yildizlar gorunur."""
    rows = "\n".join(
        f'    <long name="flutter.best_{k}" value="{v}" />'
        for k, v in sorted(PARS.items()))
    local = os.path.join(os.environ["TEMP"], "dongu_shot_prefs.xml")
    with open(local, "w", encoding="utf-8") as handle:
        handle.write(
            "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n<map>\n"
            '    <string name="flutter.locale">tr</string>\n'
            '    <boolean name="flutter.introSeen" value="true" />\n'
            '    <boolean name="flutter.sound" value="false" />\n'
            f"{rows}\n</map>\n")
    adb("shell", "am", "force-stop", PKG)
    adb("push", local, "/data/local/tmp/shot_prefs.xml")
    adb("shell", f"run-as {PKG} cp /data/local/tmp/shot_prefs.xml {PREFS}")


def play(loops, stop_before=0):
    """Cozumu oynar; son dongunun son `stop_before` hamlesini yapmaz."""
    for index, loop in enumerate(loops):
        moves = loop
        if index == len(loops) - 1 and stop_before:
            moves = loop[:-stop_before]
        for move in moves:
            tap(*TAPS[move])
        if index < len(loops) - 1:
            tap(*NEW_LOOP, wait=1.0)
    time.sleep(1.0)


def load(path):
    solutions = {}
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if line and "|" in line:
            level_id, _, loops = line.split("|", 2)
            solutions[int(level_id)] = loops.split(",")
    return solutions


def main():
    solutions = load(sys.argv[1])

    seed_completed()
    adb("shell", "am", "start", "-n", f"{PKG}/.MainActivity")
    time.sleep(20)

    shot("01-ana-ekran.png")

    tap(*LEVELS_BUTTON, wait=2.5)
    shot("02-seviyeler.png")

    # 6. seviye: iki yanki plakalarda, kapilar acik, oyuncu koridorda.
    tap(*CARD_6, wait=2.5)
    play(solutions[6], stop_before=9)
    shot("03-yankilar.png")
    adb("shell", "input", "keyevent", "4")
    time.sleep(1.5)

    # 22. seviye: catlak zemin, agir plaka ve solan kapi bir arada.
    for _ in range(5):
        adb("shell", "input", "swipe", "540", "1800", "540", "700", "250")
        time.sleep(0.8)
    tap(*CARD_22, wait=2.5)
    play(solutions[22], stop_before=4)
    shot("04-mekanikler.png")

    # Ayni seviyeyi bitirip kazanma ekranini yakala.
    for move in solutions[22][-1][-4:]:
        tap(*TAPS[move])
    time.sleep(2.0)
    shot("05-kazanma.png")

    print(f"\nEkran goruntuleri: {OUT}")


if __name__ == "__main__":
    main()
