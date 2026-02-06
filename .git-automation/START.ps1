# 🎯 Git Otomatik Senkronizasyon - Hızlı Başlatıcı

Write-Host "🎮 Oyun Evreni - Git Otomatik Senkronizasyon" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

$scriptPath = Join-Path $PSScriptRoot "auto-sync.ps1"

# Parametreler
Write-Host "⚙️ Ayarlar:" -ForegroundColor Yellow
Write-Host "  - Değişiklik kontrolü: Her 30 saniye" -ForegroundColor White
Write-Host "  - Git pull: Her 5 dakika" -ForegroundColor White
Write-Host "  - Otomatik commit & push: Aktif" -ForegroundColor White
Write-Host ""

# Uyarı
Write-Host "⚠️ UYARI:" -ForegroundColor Red
Write-Host "  Bu script arka planda sürekli çalışacak!" -ForegroundColor White
Write-Host "  Durdurmak için Ctrl+C kullanın veya terminali kapatın." -ForegroundColor White
Write-Host ""

# Onay
$confirm = Read-Host "Başlatmak istiyor musunuz? (E/H)"
if ($confirm -ne "E" -and $confirm -ne "e") {
    Write-Host "❌ İptal edildi" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "🚀 Script başlatılıyor..." -ForegroundColor Green
Write-Host ""

# Script'i çalıştır
& $scriptPath -WatchIntervalSeconds 30 -PullIntervalMinutes 5
