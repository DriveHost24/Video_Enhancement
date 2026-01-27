@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM ============================================================
REM   DRIVEHOST24 4K VERTICAL ENCODER (NVENC + METADATA)
REM ============================================================

REM ---------------- CONFIG ----------------
set "SRC=input.mov"
set "OUT_FOLDER=ETS2_4K_VERTICAL_444_10bit_NVENC_500M"
if not exist "%OUT_FOLDER%" mkdir "%OUT_FOLDER%"

set "OUT_W=2160"
set "OUT_H=3840"
set "FPS=60"
set "PIX_FMT=yuv444p10le"
set "PROFILE=rext"
set "PRESET=p7"
set "TARGET_BITRATE=500M"

REM ---------------- VIDEO NAME ----------------
set "CLIP_NAME=Euro Truck Simulator 2 Mercedes New Actros GigaSpace 510 hp (375kW) 12 speeds 2026-01-26 14-48-51 DriveHost24 Team 2026 DriveHost24"

REM ---------------- METADATA ----------------
set "META_TITLE=%CLIP_NAME%"
set "META_ARTIST=DriveHost24 Gamer (Driver, Host)"
set "META_DIRECTOR=DriveHost24 Gamer"
set "META_PRODUCERS=DriveHost24 Media Team"
set "META_WRITERS=DriveHost24 Gamer Gameplay Edit"
set "META_YEAR=2025"
set "META_GENRE=Simulation, Driving, Realism, Trucking Gameplay"
set "META_PUBLISHER=DriveHost24 Studios"
set "META_CONTENT_PROVIDER=DriveHost24 – The Ultimate Truck Simulation Channel"
set "META_ENCODED_BY=DriveHost24 Video Production (FFMPEG / DaVinci Resolve / Shotcut / HandBrake)"
set "META_AUTHOR=DriveHost24 / BlueHost Gamer"
set "META_COPYRIGHT=© 2026 DriveHost24. All rights reserved. Reproduction, redistribution, or modification of this video without permission is strictly prohibited."
set "META_COMMENT=For more information, visit: https://www.youtube.com/@DriveHost24"

REM ---------------- TEMPORARY FOLDER ----------------
if not exist "tmp_segments" mkdir "tmp_segments"

REM ---------------- STEP 1: SPLIT INPUT INTO 30s SEGMENTS ----------------
echo 🔹 Splitting input into 30s segments...
ffmpeg -y -i "%SRC%" -c copy -map 0 -f segment -segment_time 30 -reset_timestamps 1 tmp_segments\clip_%%03d.mov

REM ---------------- STEP 2: ENCODE EACH SEGMENT ----------------
for %%F in (tmp_segments\clip_*.mov) do (
    set "BASE=%%~nF"
    echo → Processing clip: !BASE!

    ffmpeg -y -hwaccel cuda -i "%%F" ^
      -vf "scale=%OUT_W%:%OUT_H%:flags=lanczos,fps=%FPS%,format=%PIX_FMT%" ^
      -c:v hevc_nvenc ^
        -pix_fmt %PIX_FMT% ^
        -profile:v %PROFILE% ^
        -preset %PRESET% ^
        -tune hq ^
        -rc cbr_hq ^
        -b:v %TARGET_BITRATE% ^
        -maxrate %TARGET_BITRATE% ^
        -bufsize 2000M ^
        -b_ref_mode middle ^
        -spatial-aq 1 -temporal-aq 1 -aq-strength 15 ^
      -c:a copy ^
      -metadata title="%META_TITLE%" ^
      -metadata artist="%META_ARTIST%" ^
      -metadata director="%META_DIRECTOR%" ^
      -metadata producer="%META_PRODUCERS%" ^
      -metadata writer="%META_WRITERS%" ^
      -metadata year="%META_YEAR%" ^
      -metadata genre="%META_GENRE%" ^
      -metadata publisher="%META_PUBLISHER%" ^
      -metadata "content_provider=%META_CONTENT_PROVIDER%" ^
      -metadata "encoded_by=%META_ENCODED_BY%" ^
      -metadata author="%META_AUTHOR%" ^
      -metadata copyright="%META_COPYRIGHT%" ^
      -metadata comment="%META_COMMENT%" ^
      "%OUT_FOLDER%\!BASE!%CLIP_NAME%_4K60_vertical_444_10bit_1G.mov"

    REM Pause 1s to free GPU memory
    timeout /t 1 >nul
)

echo ✅ Done. All 4K60 vertical clips with metadata saved in: %OUT_FOLDER%
pause
