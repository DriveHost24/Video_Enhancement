@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM ============================================================
REM   DRIVEHOST24 4K VERTICAL HDR10 ENCODER (NVENC FAST)
REM ============================================================

REM ---------------- CONFIG ----------------
set "SRC=input.mov"
set "OUT_FOLDER=ETS2_4K_VERTICAL_444_10bit_HDR10_NVENC_1G"
if not exist "%OUT_FOLDER%" mkdir "%OUT_FOLDER%"

set "OUT_W=2160"
set "OUT_H=3840"
set "FPS=60"
set "PIX_FMT=yuv444p10le"
set "PROFILE=rext"
set "PRESET=p7"

REM ★★★ NEW — FIXED NVENC MODE (NO DEPRECATION ERROR)
set "RATECONTROL=constqp"
set "CQ=1"       REM lower = higher quality (Q=1 ≈ visually lossless)

REM ★★★ NEW — TRUE CBR LOOK, BUT VALID FOR 2025 NVENC
set "BITRATE=1000M"

REM ---------------- VIDEO NAME ----------------
set "CLIP_NAME=Euro Truck Simulator 2 Volvo FH6 Aero Globetrotter XL 780hp 574kW 12 speeds 2025-11-15 18-28-54 DriveHost24 Team 2025 DriveHost24 HDR10 Vertical 4K60 DriveHost24"

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
set "META_COPYRIGHT=© 2025 DriveHost24"
set "META_COMMENT=YouTube.com/@DriveHost24"

REM ---------------- TEMPORARY FOLDER ----------------
if not exist "tmp_segments" mkdir "tmp_segments"

REM ---------------- STEP 1: SPLIT INTO 30s SEGMENTS ----------------
echo Splitting input into 30s segments...
ffmpeg -y -i "%SRC%" -c copy -map 0 ^
  -f segment -segment_time 30 -reset_timestamps 1 tmp_segments\clip_%%03d.mov

REM ---------------- STEP 2: ENCODE EACH SEGMENT ----------------
for %%F in (tmp_segments\clip_*.mov) do (
    set "BASE=%%~nF"
    echo → Encoding !BASE!

    ffmpeg -y -hwaccel cuda -i "%%F" ^
      -vf "scale=%OUT_W%:%OUT_H%:flags=lanczos,fps=%FPS%,format=%PIX_FMT%" ^
      -c:v hevc_nvenc ^
      -preset %PRESET% ^
      -profile:v %PROFILE% ^
      -pix_fmt %PIX_FMT% ^
      -rc %RATECONTROL% ^
      -qp %CQ% ^
      -tune hq ^
      -b:v %BITRATE% -maxrate %BITRATE% -bufsize 2000M ^
      -color_primaries bt2020 -color_trc smpte2084 -colorspace bt2020nc ^
      -metadata:s:v:0 master-display="G(13250,34500)B(7500,3000)R(34000,16000)WP(15635,16450)L(10000000,1)" ^
      -metadata:s:v:0 max-cll="1000,400" ^
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
      "%OUT_FOLDER%\!BASE!_%CLIP_NAME%_HDR10_4K60_444_10bit_1G.mp4"

    timeout /t 1 >nul
)

echo Done.
pause
