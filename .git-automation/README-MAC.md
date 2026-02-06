# 🍎 macOS Kullanıcıları İçin - Git Otomatik Senkronizasyon

## 🚀 Hızlı Başlangıç (macOS)

### 1. Projeyi Clone Et veya Pull Yap
```bash
cd ~
git clone https://github.com/gecekodu/OyunEvreni.git
# veya mevcut klasörde:
cd ~/OyunEvreni
git pull origin main
```

### 2. Otomatik Senkronizasyonu Başlat

**Seçenek A: Normal Mod** (Terminal görünür)
```bash
cd ~/OyunEvreni/.git-automation
./START-MAC.sh
```

**Seçenek B: Arka Plan Modu** ⭐ ÖNERİLEN
```bash
cd ~/OyunEvreni/.git-automation
./START-BACKGROUND-MAC.sh
```

### 3. Durdurmak İçin
```bash
cd ~/OyunEvreni/.git-automation
./STOP-MAC.sh
```

## 📋 Ne Yapar?

✅ **Otomatik Commit & Push**
- Her 30 saniyede bir dosya değişikliklerini kontrol eder
- Değişiklik varsa otomatik commit ve push yapar

✅ **Düzenli Git Pull**
- Her 5 dakikada bir `git pull origin main` çalıştırır
- Windows kullanan arkadaşının değişikliklerini otomatik çeker

✅ **Platform Bağımsız**
- macOS ve Linux'ta çalışır
- Windows arkadaşınızla sorunsuz çalışır

## ⚠️ İlk Çalıştırmada

Eğer "permission denied" hatası alırsanız:
```bash
cd ~/OyunEvreni/.git-automation
chmod +x *.sh
./START-BACKGROUND-MAC.sh
```

## 📝 Log Dosyası

Tüm işlemler kaydedilir:
```bash
tail -f ~/OyunEvreni/.git-automation/sync-log.txt
```

## 🔧 Sorun Giderme

### "cd: no such file or directory" hatası
Proje klasörünü kontrol edin:
```bash
# Klasörü bul
find ~ -name "OyunEvreni" -type d 2>/dev/null

# Doğru path'e git
cd ~/OyunEvreni  # veya bulunan path
```

### Script çalışmıyor
```bash
# Çalıştırma izni ver
cd ~/OyunEvreni/.git-automation
chmod +x auto-sync.sh START-MAC.sh START-BACKGROUND-MAC.sh STOP-MAC.sh

# Tekrar dene
./START-BACKGROUND-MAC.sh
```

### Git credentials
İlk push'ta şifre isteyebilir. Kaydetmek için:
```bash
git config --global credential.helper osxkeychain
```

## 🤝 Windows Arkadaşınızla Çalışma

✅ O da aynı sistemi kullanıyor (PowerShell scriptleri)
✅ İkiniz de değişiklikleri otomatik push/pull yapıyor
✅ Farklı işletim sistemleri sorun değil
⚠️ Aynı dosyayı aynı anda düzenlemeyin

## 📚 Komut Özeti

| Komut | Açıklama |
|-------|----------|
| `./START-MAC.sh` | Normal mod başlat |
| `./START-BACKGROUND-MAC.sh` | Arka planda başlat ⭐ |
| `./STOP-MAC.sh` | Durdur |
| `tail -f sync-log.txt` | Log'ları canlı izle |

## 🎉 İyi Çalışmalar!

Sorularınız için README.md dosyasına bakın.
