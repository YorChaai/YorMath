@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

echo ==========================================
echo        ANALISIS KODE FLUTTER (DART)
echo ==========================================
call flutter analyze
echo.

echo ==========================================
echo           MENJALANKAN UNIT TEST
echo ==========================================
call flutter test
echo.
pause
