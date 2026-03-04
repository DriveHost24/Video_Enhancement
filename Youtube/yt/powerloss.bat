@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM ============================================================
REM   DRIVEHOST24 4K VERTICAL ENCODER – TMP SEGMENTS ONLY
REM ============================================================

REM ---------------- FOLDERS ----------------
set "INPUT_DIR=tmp_segments"
set "OUT_FOLDER=ETS2_4K_VERTICAL_444_10bit_NVENC_250M"
if not exist "%OUT_FOLDER%" mkdir "%OUT_FOLDER%"

REM ---------------- VIDEO SETTINGS ----------------
set "OUT_W=2160"
set "OUT_H=3840"
set "FPS=60"
set "PIX_FMT=yuv444p10le"
set "PROFILE=rext"
set "PRESET=p7"
set "TARGET_BITRATE=250M"

REM ---------------- VIDEO NAME ----------------
set "CLIP_NAME=Euro Truck Simulator 2 Renault T High Sleeper 520 hp 382kW 12 speeds 2026-02-06 17-11-25 DriveHost24 Team 2026 DriveHost24"

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

REM ---------------- PROCESS CLIP_007 → CLIP_013 ----------------
for %%N in (007 008 009 010 011 012 013) do (
    echo ▶️ Processing clip_%%N

    ffmpeg -y -hwaccel cuda -i "%INPUT_DIR%\clip_%%N.mov" ^
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
      "%OUT_FOLDER%\clip_%%N%CLIP_NAME%_4K60_vertical_444_10bit_1G.mov"

    timeout /t 1 >nul
)

echo.
echo ✅ All remaining clips encoded with ORIGINAL filename format.
pause