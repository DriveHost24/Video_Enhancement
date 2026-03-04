import os

# Folder containing your clips
folder = r"ETS2_4K_VERTICAL_444_10bit_NVENC_1G"

# Old part of filename you want removed
old_text = "Euro Truck Simulator 2 DAF XG+ 510hp 324kW 12 speeds 2025-11-13 20-25-54 DriveHost24 Team 2025 DriveHost24_4K60_vertical_444_10bit_1G"

# New part of filename you want added
new_text = "Euro Truck Simulator 2 Volvo FH6 Aero Globetrotter XL 780hp 574kW 12 speeds 2025-11-15 18-28-54 DriveHost24 Team 2025 DriveHost24"

# Loop through all files in the folder
for filename in os.listdir(folder):
    if old_text in filename:
        new_name = filename.replace(old_text, new_text)
        old_path = os.path.join(folder, filename)
        new_path = os.path.join(folder, new_name)

        print(f"Renaming:\n {filename}\n --> {new_name}\n")
        os.rename(old_path, new_path)

print("Batch rename complete!")
