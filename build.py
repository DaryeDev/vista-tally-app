#!/usr/bin/env python3
"""Packs the app into dist/<name>-<version>.zip and rewrites catalog.json.

    python build.py

The zip is deterministic (fixed timestamps, sorted files), so the same sources
always give the same SHA-256 and git shows no change when nothing changed.
"""
import hashlib
import json
import zipfile
from pathlib import Path

REPO = "DaryeDev/vista-tally-app"   # where catalog.json and dist/ are published
BRANCH = "main"
CATALOG_NAME = "DaryeDev apps"
FILES = ["manifest.json", "logic.lua", "view.lua", "phone.ui.json"]

root = Path(__file__).parent
manifest = json.loads((root / "manifest.json").read_text(encoding="utf-8"))
slug = manifest["name"].lower().replace(" ", "-")
zip_name = f"{slug}-{manifest['version']}.zip"
(root / "dist").mkdir(exist_ok=True)
zip_path = root / "dist" / zip_name

with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
    for name in sorted(FILES):
        info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
        info.compress_type = zipfile.ZIP_DEFLATED
        info.external_attr = 0o644 << 16
        z.writestr(info, (root / name).read_bytes())

digest = hashlib.sha256(zip_path.read_bytes()).hexdigest()
catalog = {
    "name": CATALOG_NAME,
    "maintainer": REPO.split("/")[0],
    "apps": [
        {
            "id": manifest["id"],
            "name": manifest["name"],
            "developer": manifest["developer"],
            "version": manifest["version"],
            "accent": manifest["accent"],
            "icon": manifest["icon"],
            "description": manifest["description"],
            "package": f"https://raw.githubusercontent.com/{REPO}/{BRANCH}/dist/{zip_name}",
            "sha256": digest,
            "permissions": manifest["permissions"],
        }
    ],
}
(root / "catalog.json").write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"{zip_path.relative_to(root)}  {zip_path.stat().st_size} bytes")
print(f"sha256 {digest}")
print(f"catalog: https://raw.githubusercontent.com/{REPO}/{BRANCH}/catalog.json")
