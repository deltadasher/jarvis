#!/usr/bin/env python3
"""Headless renders of the Orrery: stills and an animation frame sequence.

QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software python3 tools/capture.py OUTDIR
"""
import sys, calendar
from pathlib import Path
from PySide6.QtCore import QUrl, QEventLoop, QTimer
import os
# Zodiac signs are emoji-presentation codepoints; keep Qt from routing them to a (missing) colour-emoji font.
os.environ.setdefault("QT_DISABLE_EMOJI_SEGMENTER", "1")
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow  # noqa: F401  (so the root maps to QQuickWindow)

J2000 = calendar.timegm((2000, 1, 1, 12, 0, 0))
def days(y, m, d): return (calendar.timegm((y, m, d, 0, 0, 0)) - J2000) / 86400

app = QGuiApplication(sys.argv)
out = Path(sys.argv[1] if len(sys.argv) > 1 else "shots"); out.mkdir(parents=True, exist_ok=True)
engine = QQmlApplicationEngine()
engine.load(QUrl.fromLocalFile(str(Path(__file__).resolve().parents[1] / "Main.qml")))
win = engine.rootObjects()[0]
win.setProperty("playing", False)

def settle(ms=60):
    loop = QEventLoop(); QTimer.singleShot(ms, loop.quit); loop.exec()

def shot(name, **props):
    for k, v in props.items(): win.setProperty(k, v)
    settle(250)
    win.grabWindow().save(str(out / name))
    print("wrote", out / name)

shot("today.png", days=days(2026, 9, 24), selected=3)
shot("saturn-retrograde.png", days=days(2026, 10, 10), selected=5)
shot("mars-opposition.png", days=days(2027, 2, 19), selected=3)
win.setProperty("trueScale", True); settle(1800)
shot("true-scale.png", days=days(2026, 9, 24), selected=4)
win.setProperty("trueScale", False); settle(1800)

if "--frames" in sys.argv:
    fd = out / "frames"; fd.mkdir(exist_ok=True)
    start = days(2026, 9, 24); win.setProperty("selected", 3)
    for i in range(240):                       # ~2.6 years, Mars through opposition
        win.setProperty("days", start + i * 4)
        settle(20)
        win.grabWindow().save(str(fd / f"f{i:04d}.png"))
    print("frames done")
