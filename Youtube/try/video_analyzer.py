import os
import subprocess
import json
import pandas as pd
import matplotlib.pyplot as plt

VIDEO_ROOT = r"C:\Users\sivatech24\Desktop\try"   # 🔴 CHANGE THIS
OUTPUT_DIR = "analysis_output"

os.makedirs(OUTPUT_DIR, exist_ok=True)

def probe_video(filepath):
    cmd = [
        "ffprobe",
        "-v", "quiet",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        filepath
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    if not result.stdout:
        return None

    try:
        return json.loads(result.stdout.decode("utf-8", errors="ignore"))
    except json.JSONDecodeError:
        print(f"⚠️ JSON decode failed: {filepath}")
        return None


records = []

for root, _, files in os.walk(VIDEO_ROOT):
    for file in files:
        if file.lower().endswith((".mp4", ".mov")):
            full_path = os.path.join(root, file)
            data = probe_video(full_path)

            if not data:
                continue

            video_stream = next(
                (s for s in data.get("streams", []) if s.get("codec_type") == "video"),
                None
            )

            if not video_stream:
                continue

            size_mb = os.path.getsize(full_path) / (1024 * 1024)
            duration = float(data["format"].get("duration", 0))
            bitrate = int(data["format"].get("bit_rate", 0)) / 1_000_000 if data["format"].get("bit_rate") else 0

            fps = 0
            if "r_frame_rate" in video_stream:
                try:
                    fps = eval(video_stream["r_frame_rate"])
                except:
                    fps = 0

            records.append({
                "File": file,
                "Format": os.path.splitext(file)[1].upper(),
                "Size_MB": round(size_mb, 2),
                "Duration_sec": round(duration, 2),
                "Bitrate_Mbps": round(bitrate, 2),
                "Codec": video_stream.get("codec_name"),
                "Profile": video_stream.get("profile"),
                "Pixel_Format": video_stream.get("pix_fmt"),
                "Resolution": f'{video_stream.get("width")}x{video_stream.get("height")}',
                "FPS": round(fps, 2),
                "Folder": os.path.basename(root)
            })


# ==========================
# EXPORT RESULTS
# ==========================
df = pd.DataFrame(records)

csv_path = os.path.join(OUTPUT_DIR, "video_analysis.csv")
df.to_csv(csv_path, index=False)

# ==========================
# PLOTS
# ==========================
plt.figure()
plt.scatter(df["Size_MB"], df["Bitrate_Mbps"])
plt.xlabel("File Size (MB)")
plt.ylabel("Bitrate (Mbps)")
plt.title("File Size vs Bitrate")
plt.grid(True)
plt.savefig(os.path.join(OUTPUT_DIR, "size_vs_bitrate.png"))
plt.close()

plt.figure()
df.groupby("Format")["Bitrate_Mbps"].mean().plot(kind="bar")
plt.ylabel("Average Bitrate (Mbps)")
plt.title("Average Bitrate by Format")
plt.savefig(os.path.join(OUTPUT_DIR, "bitrate_by_format.png"))
plt.close()

# ==========================
# README
# ==========================
readme = f"""
# Video Encoding Analysis Report

Total Files Analyzed: {len(df)}

## Average by Format
{df.groupby("Format")[["Size_MB", "Bitrate_Mbps"]].mean().round(2).to_markdown()}

## Codec Distribution
{df["Codec"].value_counts().to_markdown()}

## Notes
- Data extracted using ffprobe
- Unicode-safe parsing (Windows compatible)
- Suitable for MOV & MP4 comparison
"""

with open(os.path.join(OUTPUT_DIR, "README.md"), "w", encoding="utf-8") as f:
    f.write(readme)

print("✅ Analysis completed successfully")
print(f"📂 Output directory: {OUTPUT_DIR}")
