"""Oyunun ses efektlerini sifirdan sentezler.

Hicbir hazir ses dosyasi indirilmez; hepsi burada uretilir, boylece telif
riski sifir kalir. Cikti: assets/sfx/*.wav (22.05 kHz, 16-bit mono).

    python dev/make_sfx.py
"""

import math
import os
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "assets", "sfx")


def tone(f0, f1, ms, vol=0.5, decay=4.0, harmonic=0.0):
    """f0 -> f1 arasi kayan bir sinus; kisa atak, ussel sonum."""
    n = int(RATE * ms / 1000)
    attack = max(1, int(RATE * 0.004))
    phase = 0.0
    out = []
    for i in range(n):
        t = i / n
        freq = f0 + (f1 - f0) * t
        phase += 2 * math.pi * freq / RATE
        sample = math.sin(phase) + harmonic * math.sin(2 * phase)
        sample /= 1.0 + harmonic
        out.append(sample * min(1.0, i / attack) * math.exp(-decay * t) * vol)
    return out


def silence(ms):
    return [0.0] * int(RATE * ms / 1000)


def mix(*layers):
    """Ayni anda calan katmanlari toplar."""
    length = max(len(layer) for layer in layers)
    out = [0.0] * length
    for layer in layers:
        for i, value in enumerate(layer):
            out[i] += value
    return out


def save(name, samples):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes(b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32000))
            for s in samples
        ))
    return path, os.path.getsize(path)


SOUNDS = {
    # Yumusak bir tik: her hamlede calar, o yuzden bilerek cok kisik.
    "move.wav": tone(660, 610, 55, vol=0.22, decay=7.0),
    # Boguk bir tok ses: duvara/kapali kapiya carpinca.
    "blocked.wav": tone(150, 105, 110, vol=0.32, decay=5.0, harmonic=0.35),
    # Yukari cikan iki tonlu parilti: kapi acildi.
    "door_open.wav": mix(tone(520, 880, 180, vol=0.24, decay=2.4),
                         tone(1040, 1320, 150, vol=0.10, decay=3.2)),
    # Asagi inen ton: kapi kapandi.
    "door_close.wav": tone(760, 430, 160, vol=0.24, decay=3.0),
    # Geri sarma hissi veren dusen supurme: yeni dongu.
    "loop.wav": mix(tone(920, 250, 320, vol=0.26, decay=1.8),
                    tone(460, 125, 320, vol=0.12, decay=1.8)),
    # Kisa yukari blip: geri al.
    "undo.wav": tone(300, 520, 80, vol=0.22, decay=4.5),
    # Dortlu arpej: seviye bitti.
    "win.wav": (tone(523, 523, 110, vol=0.26, decay=3.0)
                + tone(659, 659, 110, vol=0.26, decay=3.0)
                + tone(784, 784, 110, vol=0.26, decay=3.0)
                + tone(1047, 1047, 260, vol=0.30, decay=2.0)),
}

if __name__ == "__main__":
    total = 0
    for filename, samples in SOUNDS.items():
        path, size = save(filename, samples)
        total += size
        print(f"{filename:16s} {size / 1024:6.1f} KB")
    print(f"{'toplam':16s} {total / 1024:6.1f} KB")
