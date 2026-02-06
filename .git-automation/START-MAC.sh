#!/bin/bash
# Git Otomatik Senkronizasyon - macOS Baslat

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Renkler
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Oyun Evreni - Git Auto Sync (macOS)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Ayarlar:${NC}"
echo "  - Degisiklik kontrolu: Her 30 saniye"
echo "  - Git pull: Her 5 dakika"
echo ""
echo -e "${CYAN}Script calistiriliyor...${NC}"
echo -e "${YELLOW}Durdurmak icin: Ctrl+C${NC}"
echo ""

# Script'i calistirilabilir yap
chmod +x "$SCRIPT_DIR/auto-sync.sh"

# Calistir
"$SCRIPT_DIR/auto-sync.sh"
