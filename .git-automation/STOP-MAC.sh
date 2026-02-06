#!/bin/bash
# Git Otomatik Senkronizasyon - macOS Durdur

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/process-id.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}Git Otomatik Senkronizasyon Durduruluyor...${NC}"
echo ""

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    
    if ps -p $PID > /dev/null 2>&1; then
        kill $PID
        echo -e "${GREEN}Process durduruldu (PID: $PID)${NC}"
        rm "$PID_FILE"
    else
        echo -e "${YELLOW}Process bulunamadi (zaten durmus olabilir)${NC}"
        rm "$PID_FILE"
    fi
else
    echo -e "${YELLOW}PID dosyasi bulunamadi${NC}"
    echo ""
    echo "Tum git sync processlerini durdurmak ister misiniz? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        pkill -f "auto-sync.sh"
        echo -e "${GREEN}Tum git sync processleri durduruldu${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Tamamlandi!${NC}"
