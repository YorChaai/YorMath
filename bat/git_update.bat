@echo off
setlocal EnableExtensions
cd /d "%~dp0.."

echo ==========================================
echo       UPDATE / PUSH KE GIT REPOSITORY
echo ==========================================

where git >nul 2>&1
if not errorlevel 1 goto GIT_FOUND
echo [ERROR] Git tidak ditemukan di sistem. Pastikan Git sudah terinstall di PATH.
echo.
pause
exit /b 1

:GIT_FOUND
if exist ".git" goto GIT_READY
echo [PERINGATAN] Proyek ini belum diinisialisasi sebagai repository Git [.git tidak ditemukan].
echo.
set "init_git="
set /p init_git="Apakah Anda ingin menjalankan 'git init' sekarang? (Y/T): "
if /i not "%init_git%"=="y" goto GIT_CANCEL
git init
echo Git repository berhasil diinisialisasi!
goto GIT_READY

:GIT_CANCEL
echo Operasi dibatalkan.
pause
exit /b 0

:GIT_READY
echo.
echo ==========================================
echo STATUS BERKAS [GIT STATUS]:
echo ==========================================
git status -s
echo.
echo ==========================================
echo PERUBAHAN KODE [GIT DIFF]:
echo ==========================================
git diff
echo.
echo ==========================================
set "proceed="
set /p proceed="Apakah Anda ingin melakukan COMMIT dan PUSH perubahan di atas? (Y/T): "
if /i not "%proceed%"=="y" goto END_GIT

git add .
echo.
set "commit_msg="
set /p commit_msg="Masukkan pesan commit (kosongkan untuk default 'Update'): "
if not defined commit_msg set "commit_msg=Update"

git commit -m "%commit_msg%"
echo.
echo Menjalankan git push...
git push
if not errorlevel 1 goto PUSH_SUCCESS
echo.
echo [CATATAN] Jika remote repository belum diset, atur terlebih dahulu dengan:
echo   git remote add origin ^<URL_REPO_ANDA^>
echo   git push -u origin main
goto END_GIT

:PUSH_SUCCESS
echo.
echo PUSH Berhasil!

:END_GIT
echo.
pause