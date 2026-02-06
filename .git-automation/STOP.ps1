# ⛔ Git Otomatik Senkronizasyon - Durdurma Scripti

Write-Host "⛔ Git Otomatik Senkronizasyon Durduruluyor..." -ForegroundColor Red
Write-Host ""

$processIdFile = Join-Path $PSScriptRoot "process-id.txt"

if (Test-Path $processIdFile) {
    $processId = Get-Content $processIdFile -Raw
    $processId = $processId.Trim()
    
    try {
        $process = Get-Process -Id $processId -ErrorAction Stop
        Stop-Process -Id $processId -Force
        Write-Host "✅ Process durduruldu (ID: $processId)" -ForegroundColor Green
        Remove-Item $processIdFile
    } catch {
        Write-Host "⚠️ Process bulunamadı (zaten durmuş olabilir)" -ForegroundColor Yellow
        Remove-Item $processIdFile -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "ℹ️ Kayıtlı process ID bulunamadı" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tüm powershell git sync processlerini durdurmak ister misiniz? (E/H)" -ForegroundColor Yellow
    $confirm = Read-Host
    
    if ($confirm -eq "E" -or $confirm -eq "e") {
        Get-Process powershell | Where-Object { 
            $_.CommandLine -like "*auto-sync.ps1*" 
        } | Stop-Process -Force
        Write-Host "✅ Tüm git sync processleri durduruldu" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ Tamamlandı!" -ForegroundColor Green
Start-Sleep -Seconds 2
