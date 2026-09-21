#!/usr/bin/env python3
from pathlib import Path
import re

root = Path(r"d:\capstone 2\scenes")
for f in root.glob("zone0*/Zone0*_Floor*.tscn"):
    t = f.read_text(encoding="utf-8")
    orig = t
    t = re.sub(
        r'(\[sub_resource type="RectangleShape2D" id="Rect_amb_body_[^"]+"\]\n)size = Vector2\(36, 20\)',
        r"\1size = Vector2(90, 50)",
        t,
    )
    t = re.sub(
        r'(\[sub_resource type="RectangleShape2D" id="Rect_amb_prox_[^"]+"\]\n)size = Vector2\(120, 140\)',
        r"\1size = Vector2(300, 350)",
        t,
    )
    if t != orig:
        f.write_text(t, encoding="utf-8")
        print("updated shapes", f.name)
    else:
        print("no shape change", f.name)
