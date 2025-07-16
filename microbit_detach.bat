@echo off
setlocal

REM CMSIS-DAP v1
set "VIDPID=0d28:0204"

for /f "tokens=1,2 delims= " %%a in ('usbipd list ^| findstr %VIDPID%') do (
    echo [INFO] Detaching BUSID: %%a
    usbipd detach --busid %%a
    pause
    goto :eof
)

echo [ERROR] No device found with VID:PID %VIDPID%
pause
