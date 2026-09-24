#!/usr/bin/env python3
"""Launch the Orrery.  pip install PySide6  &&  python3 main.py"""
import sys
from pathlib import Path
import os
# Zodiac signs are emoji-presentation codepoints; keep Qt from routing them to a (missing) colour-emoji font.
os.environ.setdefault("QT_DISABLE_EMOJI_SEGMENTER", "1")
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
app.setApplicationName("Orrery")
engine = QQmlApplicationEngine()
engine.load(Path(__file__).with_name("Main.qml").as_uri())
if not engine.rootObjects():
    sys.exit(1)
sys.exit(app.exec())
