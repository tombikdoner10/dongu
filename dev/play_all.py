"""Butun seviyeleri emulatorde bastan sona oynar ve kazanildigini dogrular.

Cozumler dev/solution_export.dart ciktisindan okunur; her hamle gercek bir
dokunusa cevrilir. Dogrulama ekran goruntusuyle degil kayit dosyasindan
yapilir: uygulama bir seviyeyi ancak gercekten kazanirsa best_<id> yazar.

    dart run dev/solution_export.dart > solutions.txt
    python dev/play_all.py solutions.txt
"""

import os
import re
import subprocess
import sys
import time

ADB = os.path.join(os.environ["LOCALAPPDATA"], "Android", "Sdk",
                   "platform-tools", "adb.exe")
PKG = "com.egeayvaz.dongu"
PREFS = "shared_prefs/FlutterSharedPreferences.xml"

# Ekrandaki sabit dokunma noktalari (1080x2400).
TAPS = {
    "U": (540, 1741),
    "D": (540, 2053),
    "L": (360, 1898),
    "R": (718, 1898),
    "W": (540, 1898),
}
NEW_LOOP = (540, 2232)
PLAY = (540, 1405)
BACK = 4  # keyevent


def adb(*args, timeout=60):
    return subprocess.run([ADB, *args], capture_output=True, text=True,
                          timeout=timeout)


def tap(x, y, wait=0.32):
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(wait)


def read_prefs():
    result = adb("shell", f"run-as {PKG} cat {PREFS}")
    return result.stdout


def capture(name):
    """Hata aninda ekrani kaydeder; hangi ekranda takildigi gorulsun."""
    target = os.path.join(os.environ["TEMP"], f"dongu_{name}.png")
    try:
        raw = subprocess.run([ADB, "exec-out", "screencap", "-p"],
                             capture_output=True, timeout=40).stdout
        if raw:
            with open(target, "wb") as handle:
                handle.write(raw)
            print(f"  ekran goruntusu: {target}", flush=True)
    except subprocess.TimeoutExpired:
        print("  ekran goruntusu alinamadi", flush=True)


def recorded_echoes(xml, level_id):
    match = re.search(rf'name="flutter\.best_{level_id}" value="(\d+)"', xml)
    return int(match.group(1)) if match else None


def seed_fresh_progress():
    """Ogretici gorulmus, dil Turkce, hicbir seviye bitirilmemis."""
    local = os.path.join(os.environ["TEMP"], "dongu_fresh_prefs.xml")
    with open(local, "w", encoding="utf-8") as handle:
        handle.write(
            "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n"
            "<map>\n"
            '    <string name="flutter.locale">tr</string>\n'
            '    <boolean name="flutter.introSeen" value="true" />\n'
            '    <boolean name="flutter.sound" value="false" />\n'
            "</map>\n"
        )
    adb("shell", "am", "force-stop", PKG)
    adb("push", local, "/data/local/tmp/fresh_prefs.xml")
    adb("shell", f"run-as {PKG} cp /data/local/tmp/fresh_prefs.xml {PREFS}")


def load_solutions(path):
    solutions = {}
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if not line or "|" not in line:
            continue
        level_id, par, loops = line.split("|", 2)
        if loops == "COZULEMEDI":
            solutions[int(level_id)] = (int(par), None)
        else:
            solutions[int(level_id)] = (int(par), loops.split(","))
    return solutions


def play(level_id, loops):
    tap(*PLAY, wait=3.0)  # Ana ekran -> kalinan seviye
    for index, loop in enumerate(loops):
        for move in loop:
            tap(*TAPS[move])
        if index < len(loops) - 1:
            tap(*NEW_LOOP, wait=1.2)
    time.sleep(1.2)


def main():
    solutions = load_solutions(sys.argv[1])

    seed_fresh_progress()
    adb("shell", "am", "start", "-n", f"{PKG}/.MainActivity")
    # Kurulumdan hemen sonraki ilk acilis yavas olabilir; comert bekle.
    time.sleep(25)

    failures = []
    for level_id in sorted(solutions):
        par, loops = solutions[level_id]
        if loops is None:
            print(f"Seviye {level_id:2d}: COZUM YOK", flush=True)
            failures.append(level_id)
            break

        started = time.time()
        play(level_id, loops)

        echoes = recorded_echoes(read_prefs(), level_id)
        if echoes is None:  # kayit henuz diske inmemis olabilir
            time.sleep(2.5)
            echoes = recorded_echoes(read_prefs(), level_id)

        moves = sum(len(loop) for loop in loops)
        if echoes is None:
            print(f"Seviye {level_id:2d}: KAZANILAMADI "
                  f"({len(loops)} dongu, {moves} hamle)", flush=True)
            capture(f"fail_{level_id}")
            failures.append(level_id)
            break
        if echoes != par:
            print(f"Seviye {level_id:2d}: kazanildi ama {echoes} yanki "
                  f"kaydedildi, par {par}", flush=True)
            failures.append(level_id)
        else:
            print(f"Seviye {level_id:2d}: gecti  "
                  f"{len(loops)} dongu, {moves} hamle, {echoes} yanki, "
                  f"{time.time() - started:.0f}s", flush=True)

        adb("shell", "input", "keyevent", str(BACK))
        time.sleep(1.6)

    print("")
    if failures:
        print(f"BASARISIZ seviyeler: {failures}")
        sys.exit(1)
    print(f"{len(solutions)} seviyenin hepsi emulatorde oynandi ve kazanildi.")


if __name__ == "__main__":
    main()
