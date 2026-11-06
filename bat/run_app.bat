@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

:CHOOSE
cls
echo ==========================================
echo       PILIH PLATFORM UNTUK DIJALANKAN
echo ==========================================
echo 1. Windows Desktop
echo 2. Web (Google Chrome)
echo 3. Android (Device / Emulator)
echo 0. Kembali / Batal
echo ==========================================
set "platform="
set /p platform="Masukkan pilihan Anda [1/2/3/0]: "

if "%platform%"=="1" goto RUN_WINDOWS
if "%platform%"=="2" goto RUN_CHROME
if "%platform%"=="3" goto RUN_ANDROID
if "%platform%"=="0" exit /b 0

echo.
echo Pilihan tidak valid! Silakan masukkan 1, 2, atau 3.
timeout /t 2 >nul 2>&1
goto CHOOSE

:RUN_WINDOWS
echo.
echo Menjalankan di Windows Desktop...
call flutter run -d windows
goto DONE

:RUN_CHROME
echo.
echo Menjalankan di Google Chrome...
call flutter run -d chrome
goto DONE

:RUN_ANDROID
echo.
echo Menjalankan di Android...
call flutter run -d android
goto DONE

:DONE
echo.
pause