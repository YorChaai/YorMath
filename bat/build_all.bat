@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

echo ==========================================
echo    MEMBANGUN APLIKASI WINDOWS [.exe]
echo ==========================================
call flutter build windows
echo.

echo ==========================================
echo    MEMBANGUN APLIKASI ANDROID [.apk]
echo ==========================================
call flutter build apk --release
echo.

echo ==========================================
echo         PROSES BUILD SELESAI!
echo ==========================================
if not exist "build\windows\x64\runner\Release" goto SKIP_WIN_LOG
echo [OK] File Windows .exe:
echo %CD%\build\windows\x64\runner\Release\

:SKIP_WIN_LOG
echo.
if not exist "build\app\outputs\flutter-apk\app-release.apk" goto SKIP_APK_LOG
echo [OK] File Android .apk:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk

:SKIP_APK_LOG
echo ==========================================
pause