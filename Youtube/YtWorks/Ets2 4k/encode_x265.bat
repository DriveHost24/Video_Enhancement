@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM ---------------- CONFIG ----------------
set "SRC=input.mov"
set "OUT_FOLDER=ETS2_4K_VERTICAL_X265_NEARLOSSLESS"
if not exist "%OUT_FOLDER%" mkdir "%OUT_FOLDER%"

set "OUT_W=2160"
set "OUT_H=3840"
set "FPS=60"
set "PIX_FMT=yuv444p10le"

REM ---------------- METADATA ----------------
set "META_TITLE=Euro Truck Simulator 2 Mercedes New Actros GigaSpace 510 hp 375kW 12 speeds 2025-11-09 16-26-58s"
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
set "META_COPYRIGHT=© 2025 DriveHost24. All rights reserved. Reproduction, redistribution, or modification of this video without permission is strictly prohibited."
set "META_COMMENT=For more information, visit: https://www.youtube.com/@DriveHost24"

REM Temporary folder for 30s clips
if not exist "tmp_segments" mkdir "tmp_segments"

REM ---------------- STEP 1: Split into 30s segments ----------------
echo 🔹 Splitting input into 30s segments...
ffmpeg -y -i "%SRC%" -c copy -map 0 -f segment -segment_time 30 -reset_timestamps 1 tmp_segments\clip_%%03d.mov

REM ---------------- STEP 2: Encode each segment ----------------
for %%F in (tmp_segments\clip_*.mov) do (
    set "BASE=%%~nF"
    echo → Processing clip: !BASE!

    ffmpeg -y -i "%%F" ^
      -vf "scale=%OUT_W%:%OUT_H%:flags=lanczos,fps=%FPS%,format=%PIX_FMT%" ^
      -c:v libx265 -preset slow -pix_fmt %PIX_FMT% ^
      -x265-params "crf=10:qcomp=0.75:profile=main10:aq-mode=3:psy-rd=1.5" ^
      -c:a aac -b:a 192k ^
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
      "%OUT_FOLDER%\!BASE!_4K60_vertical_x265_crf10.mkv"

    timeout /t 1 >nul
)

echo ✅ Done. All 4K60 vertical x265 near-lossless clips saved in: %OUT_FOLDER%
pause
