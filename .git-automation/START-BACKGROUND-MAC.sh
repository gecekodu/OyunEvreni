#!/bin/bash
# Git Otomatik Senkronizasyon - macOS Arka Plan

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Git Auto Sync - Arka Plan (macOS)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Script'i calistirilabilir yap
chmod +x "$SCRIPT_DIR/auto-sync.sh"

# Arka planda calistir
nohup "$SCRIPT_DIR/auto-sync.sh" > /dev/null 2>&1 &
PID=$!

# PID'yi kaydet
echo $PID > "$SCRIPT_DIR/process-id.txt"

echo -e "${GREEN}Script arka planda baslatildi!${NC}"
echo -e "Process ID: ${CYAN}$PID${NC}"
echo ""
echo -e "${YELLOW}Durdurmak icin:${NC}"
echo "  kill $PID"
echo "  veya:"
echo "  $SCRIPT_DIR/STOP-MAC.sh"
echo ""
echo -e "${YELLOW}Log dosyasi:${NC}"
echo "  $SCRIPT_DIR/sync-log.txt"
echo ""
echo -e "${GREEN}Tamamlandi!${NC}"
