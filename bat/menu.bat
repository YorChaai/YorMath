@echo off
setlocal EnableDelayedExpansion
title Project Control Center
color 0A

:: ========================================================
:: KONFIGURASI PATH AITOOL
:: ========================================================
set "AITOOL_DIR=D:\Aplikasi\aitool"

:: Deteksi otomatis root project (apakah file ini ada di subfolder 'bat' atau langsung di root)
if exist "%~dp0..\.git" (
    set "CURRENT_PROJ=%~dp0.."
) else if exist "%~dp0..\pubspec.yaml" (
    set "CURRENT_PROJ=%~dp0.."
) else if exist "%~dp0..\backend" (
    set "CURRENT_PROJ=%~dp0.."
) else (
    set "CURRENT_PROJ=%~dp0"
)

:: Dapatkan absolute path project
pushd "!CURRENT_PROJ!"
set "CURRENT_PROJ=%CD%"
popd

:: Periksa ketersediaan file project_menu.py di AI Tool
if not exist "!AITOOL_DIR!\project_menu.py" (
    echo ========================================================
    echo  [ERROR] project_menu.py tidak ditemukan di: !AITOOL_DIR!
    echo ========================================================
    echo  Pastikan folder D:\Aplikasi\aitool ada dan berisi project_menu.py.
    echo.
    pause
    exit /b 1
)

:: Otomatis sinkronkan project aktif ke config.json milik D:\Aplikasi\aitool
python -c "import json, os; cfg=os.path.join(r'!AITOOL_DIR!', 'config.json'); data={'last_project_path': r'!CURRENT_PROJ!'}; json.dump(data, open(cfg, 'w', encoding='utf-8'), indent=2)" 2>nul

cls
echo ========================================================
echo   MEMBUKA PROJECT CONTROL CENTER
echo ========================================================
echo   Lokasi AI Tool : !AITOOL_DIR!
echo   Project Aktif  : !CURRENT_PROJ!
echo ========================================================
echo.

cd /d "!AITOOL_DIR!"
python project_menu.py "!CURRENT_PROJ!"

pause
