import os
import shutil
from pathlib import Path

base_path = Path(os.getenv("APPDATA")) / "MetaQuotes" / "Terminal" / "Common" / "Files" / "SimulationData"

for target_folder in os.listdir(base_path):
    target_path = os.path.join(base_path, target_folder)
    if not os.path.isdir(target_path):
        continue

    for folder in os.listdir(target_path):
        folder_path = os.path.join(target_path, folder)
        if not os.path.isdir(folder_path):
            continue

        parts = folder.split("_")
        if len(parts) < 3:
            continue

        group_value = parts[1]  # e.g. "1.00", "1.25", etc.
        dest_group_folder = os.path.join(target_path, group_value)

        # Skip if already inside the group folder to avoid moving into itself
        if os.path.commonpath([folder_path, dest_group_folder]) == folder_path:
            print(f"⚠ Skipping (already inside correct folder): {folder}")
            continue

        os.makedirs(dest_group_folder, exist_ok=True)

        # Move only if not already moved
        if not os.path.exists(os.path.join(dest_group_folder, folder)):
            shutil.move(folder_path, os.path.join(dest_group_folder, folder))
            print(f"✔ Moved: {folder} → {group_value}")
        else:
            print(f"⚠ Skipped (already in destination): {folder}")