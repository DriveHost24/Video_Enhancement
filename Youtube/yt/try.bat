@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM ============================================================
REM   DRIVEHOST24 FFV1 MASTER (4:4:4 10-BIT LOSSLESS)
REM ============================================================

set "OUT_W=2160"
set "OUT_H=3840"
set "FPS=60"
set "PIX_FMT=yuv444p10le"

set "CLIP_NAME=DriveHost24_FFV1_MASTER"

if not exist "tmp_segments" mkdir "tmp_segments"

for %%F in (tmp_segments\clip_*.mov) do (
    set "BASE=%%~nF"

    ffmpeg -y -i input.mov ^
-r 60 ^
-vsync 1 ^
-s 2160x3840 ^
-aspect 9:16 ^
-c:v hevc_nvenc ^
-pix_fmt yuv420p10le ^
-profile:v main10 ^
-preset p7 ^
-rc cbr ^
-b:v 300M ^
-color_range pc ^
-color_primaries bt2020 ^
-color_trc smpte2084 ^
-colorspace bt2020nc ^
-c:a copy ^
output_4K60_NVENC_CBR300M_BT2020_PC.mov


)

echo DONE – FFV1 MASTER CREATED
pause
