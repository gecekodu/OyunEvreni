# 🔄 Git Otomatik Senkronizasyon

Bu klasör, projenizi GitHub ile otomatik senkronize eden scriptleri içerir.

## 🚀 Hızlı Başlangıç

### Windows (PowerShell)

```powershell
cd "c:\Oyun Evreni\.git-automation"
.\START.ps1
```

## 📋 Ne Yapar?

✅ **Otomatik Commit & Push**
- Her 30 saniyede bir dosya değişikliklerini kontrol eder
- Değişiklik varsa otomatik commit ve push yapar
- Değişiklikleri timestamp ile kaydeder

✅ **Düzenli Git Pull**
- Her 5 dakikada bir `git pull origin main` çalıştırır
- Arkadaşınızın yaptığı değişiklikleri otomatik çeker

✅ **Akıllı Conflict Yönetimi**
- Push rejected olursa otomatik pull dener
- Conflict durumunda sizi uyarır

## ⚙️ Özelleştirme

`START.ps1` dosyasını düzenleyerek ayarları değiştirebilirsiniz:

```powershell
& $scriptPath -WatchIntervalSeconds 60 -PullIntervalMinutes 10
```

- **WatchIntervalSeconds**: Değişiklik kontrol aralığı (saniye)
- **PullIntervalMinutes**: Git pull aralığı (dakika)

## 📝 Log Dosyası

Tüm işlemler log kaydedilir:
```
c:\Oyun Evreni\.git-automation\sync-log.txt
```

## 🛑 Durdurma

Script çalışırken:
- `Ctrl + C` tuşuna basın
- veya terminal penceresini kapatın

## ⚠️ Önemli Notlar

1. **İlk Kurulum**: Git credentials'ınızın kaydedildiğinden emin olun
   ```powershell
   git config credential.helper store
   ```

2. **Arka Plan Çalıştırma**: Script'i arka planda çalıştırmak için:
   ```powershell
   Start-Process powershell -WindowStyle Hidden -ArgumentList "-File `"$PWD\START.ps1`""
   ```

3. **Otomatik Başlatma**: Windows başlangıcında otomatik çalışsın istiyorsanız:
   - `START.ps1`'e sağ tık → "Kısayol Oluştur"
   - Kısayolu `C:\Users\[KULLANICI]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup` klasörüne taşıyın

## 🐛 Sorun Giderme

### Script çalışmıyor
```powershell
# PowerShell execution policy'yi kontrol edin
Get-ExecutionPolicy

# Gerekirse bypass edin (güvenli değil, dikkatli kullanın)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Push başarısız oluyor
```powershell
# Git credentials'ınızı kontrol edin
git config --global user.name
git config --global user.email

# Remote URL'i kontrol edin
git remote -v
```

### Conflict çözümü
Script conflict algılarsa manuel müdahale gerekir:
```powershell
cd "c:\Oyun Evreni"
git status
# Conflictleri çözün
git add .
git commit -m "Conflict çözüldü"
git push origin main
```

## 📚 Komutlar

| Komut | Açıklama |
|-------|----------|
| `.\START.ps1` | Script'i başlat |
| `Ctrl + C` | Script'i durdur |
| `Get-Content sync-log.txt -Tail 20` | Son 20 log satırını göster |

## 🤝 İşbirliği İpuçları

- Script çalışırken arkadaşınızla aynı dosya üzerinde çalışmayın
- Büyük değişiklikler öncesi script'i durdurun
- Düzenli olarak log dosyasını kontrol edin
- Önemli değişikliklerden önce manual commit yapın (daha anlamlı mesajlar için)
