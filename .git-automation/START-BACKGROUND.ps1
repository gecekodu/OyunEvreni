# Git Otomatik Senkronizasyon - Arka Plan Baslat
# Bu script, sync script'ini gizli pencerede arka planda baslatir

$scriptPath = Join-Path $PSScriptRoot "auto-sync.ps1"

Write-Host "Oyun Evreni - Git Otomatik Senkronizasyon (Arka Plan)" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Degisiklik kontrolu: Her 30 saniye" -ForegroundColor White
Write-Host "Git pull: Her 5 dakika" -ForegroundColor White
Write-Host ""
Write-Host "Script arka planda baslatiliyor..." -ForegroundColor Yellow
Write-Host ""

# Arka planda baslat
$process = Start-Process powershell -ArgumentList @(
    "-ExecutionPolicy", "Bypass",
    "-WindowStyle", "Hidden",
    "-File", $scriptPath,
    "-WatchIntervalSeconds", "30",
    "-PullIntervalMinutes", "5"
) -PassThru

Write-Host "Script arka planda baslatildi! (Process ID: $($process.Id))" -ForegroundColor Green
Write-Host ""
Write-Host "Durdurmak icin:" -ForegroundColor Yellow
Write-Host "   Task Manager'dan 'powershell' process'ini durdurun" -ForegroundColor White
Write-Host "   veya bu komutu calistirin:" -ForegroundColor White
Write-Host "   Stop-Process -Id $($process.Id)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Log dosyasi:" -ForegroundColor Yellow
Write-Host "   $PSScriptRoot\sync-log.txt" -ForegroundColor White
Write-Host ""

# Process ID'yi kaydet
$process.Id | Out-File (Join-Path $PSScriptRoot "process-id.txt")

Write-Host "Tamamlandi!" -ForegroundColor Green
Start-Sleep -Seconds 3
