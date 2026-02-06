# Git Otomatik Senkronizasyon Scripti
# Dosya degisikliklerini izler ve otomatik commit/push yapar
# Ayrica duzenli araliklarla git pull calistirir

param(
    [int]$WatchIntervalSeconds = 30,
    [int]$PullIntervalMinutes = 5
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
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

# Git pull fonksiyonu
function Invoke-GitPull {
    Write-Log "Git pull yapiliyor..."
    try {
        Set-Location $projectPath
        $pullOutput = git pull origin main 2>&1 | Out-String
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Pull basarili: $($pullOutput.Trim())"
            return $true
        } else {
            Write-Log "Pull hatasi: $pullOutput"
            return $false
        }
    } catch {
        Write-Log "Pull exception: $_"
        return $false
    }
}

# Git commit ve push fonksiyonu
function Invoke-GitCommitPush {
    param([string]$changesSummary)
    
    Write-Log "Degisiklikler commit ediliyor..."
    try {
        Set-Location $projectPath
        
        # Staged dosyalar var mi kontrol et
        $status = git status --porcelain 2>&1
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Log "Commit edilecek degisiklik yok"
            return $false
        }
        
        # Add all changes
        git add -A 2>&1 | Out-Null
        
        # Commit message olustur
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $commitMsg = "Auto-sync: $changesSummary - $timestamp"
        
        git commit -m $commitMsg 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Commit basarili: $commitMsg"
            
            # Push
            Write-Log "Push yapiliyor..."
            $pushOutput = git push origin main 2>&1 | Out-String
            
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Push basarili"
                return $true
            } else {
                Write-Log "Push hatasi: $pushOutput"
                if ($pushOutput -like "*rejected*" -or $pushOutput -like "*conflict*") {
                    Write-Log "Conflict algilandi, pull deneniyor..."
                    Invoke-GitPull
                }
                return $false
            }
        } else {
            Write-Log "Commit hatasi"
            return $false
        }
    } catch {
        Write-Log "Commit/Push exception: $_"
        return $false
    }
}

# Dosya degisikliklerini kontrol et
function Check-FileChanges {
    Set-Location $projectPath
    
    # Git status kontrol
    $status = git status --porcelain 2>&1
    
    if ([string]::IsNullOrWhiteSpace($status)) {
        return $null
    }
    
    # Degisen dosyalari say
    $statusLines = $status -split "`n" | Where-Object { $_ -match '\S' }
    $changeCount = $statusLines.Count
    
    # Degisiklik turlerini analiz et
    $modified = ($statusLines | Where-Object { $_ -match '^\s*M' }).Count
    $added = ($statusLines | Where-Object { $_ -match '^\s*A|\?\?' }).Count
    $deleted = ($statusLines | Where-Object { $_ -match '^\s*D' }).Count
    
    $summary = @()
    if ($modified -gt 0) { $summary += "$modified degistirildi" }
    if ($added -gt 0) { $summary += "$added eklendi" }
    if ($deleted -gt 0) { $summary += "$deleted silindi" }
    
    return ($summary -join ", ")
}

# Ana dongu
Write-Log "Git otomatik senkronizasyon baslatildi"
Write-Log "Proje: $projectPath"
Write-Log "Degisiklik kontrolu: $WatchIntervalSeconds saniye"
Write-Log "Pull araligi: $PullIntervalMinutes dakika"
Write-Log "----------------------------------------"

$iteration = 0
while ($true) {
    try {
        $iteration++
        
        # Duzenli pull kontrolu
        $timeSinceLastPull = (Get-Date) - $lastPullTime
        if ($timeSinceLastPull.TotalMinutes -ge $PullIntervalMinutes) {
            Invoke-GitPull
            $lastPullTime = Get-Date
        }
        
        # Dosya degisikliklerini kontrol et
        $changes = Check-FileChanges
        
        if ($null -ne $changes) {
            Write-Log "Degisiklikler tespit edildi: $changes"
            Invoke-GitCommitPush -changesSummary $changes
        } else {
            if ($iteration % 10 -eq 0) {
                Write-Log "Izleniyor... (Degisiklik yok)"
            }
        }
        
        Start-Sleep -Seconds $WatchIntervalSeconds
        
    } catch {
        Write-Log "Hata olustu: $_"
        Start-Sleep -Seconds 10
    }
}
