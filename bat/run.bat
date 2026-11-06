@echo off
setlocal EnableExtensions
cd /d "%~dp0.."
echo ==========================================
echo        MENJALANKAN FLUTTER DESKTOP
echo ==========================================
call flutter run -d windows
echo.
pause
