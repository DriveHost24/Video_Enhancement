import os
import subprocess
import json
import pandas as pd
import matplotlib.pyplot as plt
import re
import numpy as np

TEST_UPLOAD = r"C:\Users\sivatech24\Desktop\try\Test Upload"
YOUTUBE_UPLOAD = r"C:\Users\sivatech24\Desktop\try\YoutubeUpload"
OUTPUT_DIR = "youtube_comparison_output"

os.makedirs(OUTPUT_DIR, exist_ok=True)

# ==========================
# FFPROBE SAFE
# ==========================
def probe_video(path):
    cmd = [
        "ffprobe", "-v", "quiet",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        path
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        return json.loads(result.stdout.decode("utf-8", errors="ignore"))
    except:
        return None

def get_video_info(path):
    data = probe_video(path)
    if not data:
        return None

    video_stream = next(
        (s for s in data.get("streams", []) if s.get("codec_type") == "video"),
        None
    )
    if not video_stream:
        return None

    size_mb = os.path.getsize(path) / (1024 * 1024)
    duration = float(data["format"].get("duration", 0))
    bitrate = (size_mb * 8) / duration if duration > 0 else 0

    return round(size_mb, 2), round(bitrate, 2)

# ==========================
# EXTRACT SIZE TAG (80M, 100M ...)
# ==========================
def extract_size_tag(filename):
    match = re.search(r"(\d{2,4})M", filename)
    return match.group(1) + "M" if match else None

# ==========================
# BUILD FILE MAPS
# ==========================
mov_files = {}
for f in os.listdir(TEST_UPLOAD):
    if f.lower().endswith(".mov"):
        tag = extract_size_tag(f)
        if tag:
            mov_files[tag] = os.path.join(TEST_UPLOAD, f)

mp4_files = {}
for f in os.listdir(YOUTUBE_UPLOAD):
    if f.lower().endswith(".mp4"):
        tag = extract_size_tag(f)
        if tag:
            mp4_files[tag] = os.path.join(YOUTUBE_UPLOAD, f)

common_tags = mov_files.keys() & mp4_files.keys()

# ==========================
# COLLECT DATA
# ==========================
records = []

for tag in sorted(common_tags, key=lambda x: int(x[:-1])):
    mov_size, mov_bitrate = get_video_info(mov_files[tag])
    mp4_size, mp4_bitrate = get_video_info(mp4_files[tag])

    records.append({
        "Video": tag,
        "MOV_Size_MB": mov_size,
        "MOV_Bitrate_Mbps": mov_bitrate,
        "MP4_Size_MB": mp4_size,
        "MP4_Bitrate_Mbps": mp4_bitrate
    })

df = pd.DataFrame(records)

# ==========================
# SAFETY CHECK
# ==========================
if df.empty:
    raise RuntimeError("❌ No matching videos found. Check naming or folders.")

df.to_csv(f"{OUTPUT_DIR}/youtube_compression_comparison.csv", index=False)

# ==========================
# BITRATE GRAPH (FIXED)
# ==========================
x = np.arange(len(df))
width = 0.35

plt.figure(figsize=(10, 6))
plt.bar(x - width/2, df["MOV_Bitrate_Mbps"],
        width=width, label="Original MOV", color="red")

plt.bar(x + width/2, df["MP4_Bitrate_Mbps"],
        width=width, label="YouTube MP4", color="blue")

plt.xticks(x, df["Video"])
plt.ylabel("Bitrate (Mbps)")
plt.title("YouTube Compression – Bitrate Comparison")
plt.legend()
plt.tight_layout()
plt.savefig(f"{OUTPUT_DIR}/bitrate_comparison.png")
plt.close()

plt.figure(figsize=(10, 6))
plt.bar(x - width/2, df["MOV_Bitrate_Mbps"],
        width=width, label="Original MOV", color="red")

plt.bar(x + width/2, df["MP4_Bitrate_Mbps"],
        width=width, label="YouTube MP4", color="blue")

plt.yscale("log")  # 🔥 KEY LINE

plt.xticks(x, df["Video"])
plt.ylabel("Bitrate (Mbps) [log scale]")
plt.title("YouTube Compression – Bitrate Comparison (Log Scale)")
plt.legend()
plt.tight_layout()
plt.savefig(f"{OUTPUT_DIR}/bitrate_comparison_log.png")
plt.close()

# ==========================
# SIZE GRAPH (FIXED)
# ==========================
plt.figure(figsize=(10, 6))
plt.bar(x - width/2, df["MOV_Size_MB"],
        width=width, label="Original MOV", color="darkred")

plt.bar(x + width/2, df["MP4_Size_MB"],
        width=width, label="YouTube MP4", color="steelblue")

plt.xticks(x, df["Video"])
plt.ylabel("File Size (MB)")
plt.title("YouTube Compression – File Size Comparison")
plt.legend()
plt.tight_layout()
plt.savefig(f"{OUTPUT_DIR}/size_comparison.png")
plt.close()

df["Extra_Gain_%"] = (
    (df["MOV_Bitrate_Mbps"] - df["MOV_Bitrate_Mbps"].shift(1))
    / df["MOV_Bitrate_Mbps"].shift(1)
) * 100

plt.figure(figsize=(10, 6))
plt.plot(df["Video"], df["Extra_Gain_%"], marker="o")
plt.ylabel("Incremental Bitrate Gain (%)")
plt.title("Diminishing Returns at High Upload Bitrates")
plt.grid(True)
plt.tight_layout()
plt.savefig(f"{OUTPUT_DIR}/incremental_gain.png")
plt.close()

print("✅ YouTube compression comparison completed successfully")
print(df)
