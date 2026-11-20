#!/usr/bin/env python3
"""Packs every app in apps/ into dist/<name>-<version>.zip and rewrites catalog.json.

    python build.py

Each folder under apps/ is one app (it needs a manifest.json). The zips are
deterministic (fixed timestamps, sorted files), so the same sources always give
the same SHA-256 and git shows no change when nothing changed.
"""
import hashlib
import json
import zipfile
from pathlib import Path

REPO = "DaryeDev/vista-tally-app"   # where catalog.json and dist/ are published
BRANCH = "main"
CATALOG_NAME = "DaryeDev apps"

root = Path(__file__).parent
(root / "dist").mkdir(exist_ok=True)


def pack(app_dir: Path, manifest: dict) -> tuple[Path, str]:
    slug = manifest["name"].lower().replace(" ", "-")
    zip_path = root / "dist" / f"{slug}-{manifest['version']}.zip"
    files = sorted(
        p for p in app_dir.rglob("*")
        if p.is_file() and not any(part.startswith(".") for part in p.relative_to(app_dir).parts)
    )
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
        for f in files:
            info = zipfile.ZipInfo(f.relative_to(app_dir).as_posix(), date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            z.writestr(info, f.read_bytes())
    return zip_path, hashlib.sha256(zip_path.read_bytes()).hexdigest()


entries = []
for manifest_path in sorted((root / "apps").glob("*/manifest.json")):
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    zip_path, digest = pack(manifest_path.parent, manifest)
    print(f"{zip_path.relative_to(root).as_posix()}  {zip_path.stat().st_size} bytes  sha256 {digest[:12]}...")
    entries.append({
        "id": manifest["id"],
        "name": manifest["name"],
        "developer": manifest["developer"],
        "version": manifest["version"],
        "accent": manifest["accent"],
        "icon": manifest["icon"],
        "description": manifest["description"],
        "package": f"https://raw.githubusercontent.com/{REPO}/{BRANCH}/dist/{zip_path.name}",
        "sha256": digest,
        "permissions": manifest["permissions"],
    })

catalog = {"name": CATALOG_NAME, "maintainer": REPO.split("/")[0], "apps": entries}
(root / "catalog.json").write_text(json.dumps(catalog, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"catalog.json: {len(entries)} apps -> https://raw.githubusercontent.com/{REPO}/{BRANCH}/catalog.json")
