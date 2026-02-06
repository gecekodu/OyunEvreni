@echo off
REM Git Otomatik Senkronizasyon - Windows Batch Başlatıcı
REM Bu dosyaya çift tıklayarak script'i başlatabilirsiniz

echo.
echo ========================================
echo    Oyun Evreni - Git Auto Sync
echo ========================================
echo.
echo Script baslatiliyor...
echo.

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "START.ps1"

pause
