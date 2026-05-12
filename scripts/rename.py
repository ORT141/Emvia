from pathlib import Path
import re
import shutil
from unidecode import unidecode

ASSETS_DIR = Path(r".\\assets\\sounds\\liam")
LIB_DIR = Path(r".\\lib")

SAFE = re.compile(r"[^a-zA-Z0-9._-]")

replacements = {}


for file in ASSETS_DIR.glob("*"):
    if not file.is_file():
        continue

    old_name = file.name
    stem = file.stem
    ext = file.suffix.lower()

    new_stem = unidecode(stem)
    new_stem = new_stem.lower()
    new_stem = new_stem.replace(" ", "_")
    new_stem = SAFE.sub("_", new_stem)
    new_stem = re.sub(r"_+", "_", new_stem).strip("_.")

    if not new_stem:
        new_stem = "audio"

    new_stem = new_stem[:50]

    new_name = f"{new_stem}{ext}"
    new_path = file.with_name(new_name)

    counter = 1
    while new_path.exists() and new_path != file:
        new_name = f"{new_stem}_{counter}{ext}"
        new_path = file.with_name(new_name)
        counter += 1

    print(f"{old_name} -> {new_name}")

    replacements[old_name] = new_name

    shutil.move(str(file), str(new_path))


for dart_file in LIB_DIR.rglob("*.dart"):
    try:
        text = dart_file.read_text(encoding="utf-8")
        original = text

        replaced_any = False

        for old_name, new_name in replacements.items():
            if old_name in text:
                text = text.replace(old_name, new_name)
                print(f"[REPLACED] {old_name} -> {new_name} in {dart_file}")
                replaced_any = True

        if replaced_any:
            dart_file.write_text(text, encoding="utf-8")

    except Exception as e:
        print(f"FAILED: {dart_file} -> {e}")

print("\nDONE")
