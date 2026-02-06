# 🔄 Git Otomatik Senkronizasyon Scripti
# Dosya değişikliklerini izler ve otomatik commit/push yapar
# Ayrıca düzenli aralıklarla git pull çalıştırır

param(
    [int]$WatchIntervalSeconds = 30,  # Dosya değişiklik kontrolü (30 saniye)
    [int]$PullIntervalMinutes = 5     # Git pull aralığı (5 dakika)
)

$projectPath = "c:\Oyun Evreni"
$lastPullTime = Get-Date
$logFile = Join-Path $projectPath ".git-automation\sync-log.txt"

# Log fonksiyonu
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage -ForegroundColor Cyan
    Add-Content -Path $logFile -Value $logMessage
}

# Git pull fonksiyonu
function Invoke-GitPull {
    Write-Log "🔽 Git pull yapılıyor..."
    try {
        Set-Location $projectPath
        $pullOutput = git pull origin main 2>&1 | Out-String
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Pull başarılı: $($pullOutput.Trim())"
            return $true
        } else {
            Write-Log "⚠️ Pull hatası: $pullOutput"
            return $false
        }
    } catch {
        Write-Log "❌ Pull exception: $_"
        return $false
    }
}

# Git commit ve push fonksiyonu
function Invoke-GitCommitPush {
    param([string]$changesSummary)
    
    Write-Log "📤 Değişiklikler commit ediliyor..."
    try {
        Set-Location $projectPath
        
        # Staged dosyalar var mı kontrol et
        $status = git status --porcelain 2>&1
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Log "ℹ️ Commit edilecek değişiklik yok"
            return $false
        }
        
        # Add all changes
        git add -A 2>&1 | Out-Null
        
        # Commit message oluştur
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $commitMsg = "Auto-sync: $changesSummary - $timestamp"
        
        git commit -m $commitMsg 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Commit başarılı: $commitMsg"
            
            # Push
            Write-Log "📤 Push yapılıyor..."
            $pushOutput = git push origin main 2>&1 | Out-String
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✅ Push başarılı"
                return $true
            } else {
                Write-Log "⚠️ Push hatası: $pushOutput"
                # Conflict varsa pull dene
                if ($pushOutput -like "*rejected*" -or $pushOutput -like "*conflict*") {
                    Write-Log "🔄 Conflict algılandı, pull deneniyor..."
                    Invoke-GitPull
                }
                return $false
            }
        } else {
            Write-Log "⚠️ Commit hatası"
            return $false
        }
    } catch {
        Write-Log "❌ Commit/Push exception: $_"
        return $false
    }
}

# Dosya değişikliklerini kontrol et
function Check-FileChanges {
    Set-Location $projectPath
    
    # Git status kontrol
    $status = git status --porcelain 2>&1
    
    if ([string]::IsNullOrWhiteSpace($status)) {
        return $null  # Değişiklik yok
    }
    
    # Değişen dosyaları say
    $statusLines = $status -split "`n" | Where-Object { $_ -match '\S' }
    $changeCount = $statusLines.Count
    
    # Değişiklik türlerini analiz et
    $modified = ($statusLines | Where-Object { $_ -match '^\s*M' }).Count
    $added = ($statusLines | Where-Object { $_ -match '^\s*A|\?\?' }).Count
    $deleted = ($statusLines | Where-Object { $_ -match '^\s*D' }).Count
    
    $summary = @()
    if ($modified -gt 0) { $summary += "$modified değiştirildi" }
    if ($added -gt 0) { $summary += "$added eklendi" }
    if ($deleted -gt 0) { $summary += "$deleted silindi" }
    
    return ($summary -join ", ")
}

# Ana döngü
Write-Log "🚀 Git otomatik senkronizasyon başlatıldı"
Write-Log "📁 Proje: $projectPath"
Write-Log "⏱️ Değişiklik kontrolü: $WatchIntervalSeconds saniye"
Write-Log "🔽 Pull aralığı: $PullIntervalMinutes dakika"
Write-Log "----------------------------------------"

$iteration = 0
while ($true) {
    try {
        $iteration++
        
        # Düzenli pull kontrolü
        $timeSinceLastPull = (Get-Date) - $lastPullTime
        if ($timeSinceLastPull.TotalMinutes -ge $PullIntervalMinutes) {
            Invoke-GitPull
            $lastPullTime = Get-Date
        }
        
        # Dosya değişikliklerini kontrol et
        $changes = Check-FileChanges
        
        if ($null -ne $changes) {
            Write-Log "📝 Değişiklikler tespit edildi: $changes"
            Invoke-GitCommitPush -changesSummary $changes
        } else {
            # Her 10 iterasyonda bir sessiz log
            if ($iteration % 10 -eq 0) {
                Write-Log "✓ İzleniyor... (Değişiklik yok)"
            }
        }
        
        Start-Sleep -Seconds $WatchIntervalSeconds
        
    } catch {
        Write-Log "❌ Hata oluştu: $_"
        Start-Sleep -Seconds 10
    }
}
