#!/bin/bash
# Git Otomatik Senkronizasyon - macOS/Linux

# Renkli output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Proje path'ini otomatik bul
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$SCRIPT_DIR/sync-log.txt"
WATCH_INTERVAL=30
PULL_INTERVAL=300  # 5 dakika = 300 saniye

# Log fonksiyonu
log_message() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${CYAN}[$timestamp] $1${NC}"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Git pull
do_git_pull() {
    log_message "Git pull yapiliyor..."
    cd "$PROJECT_PATH"
    
    pull_output=$(git pull origin main 2>&1)
    
    if [ $? -eq 0 ]; then
        log_message "Pull basarili: $pull_output"
        return 0
    else
        log_message "Pull hatasi: $pull_output"
        return 1
    fi
}

# Git commit ve push
do_git_commit_push() {
    changes_summary="$1"
    log_message "Degisiklikler commit ediliyor..."
    
    cd "$PROJECT_PATH"
    
    # Degisiklik var mi kontrol et
    if [ -z "$(git status --porcelain)" ]; then
        log_message "Commit edilecek degisiklik yok"
        return 1
    fi
    
    # Add all
    git add -A
    
    # Commit
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    commit_msg="Auto-sync: $changes_summary - $timestamp"
    
    git commit -m "$commit_msg" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        log_message "Commit basarili: $commit_msg"
        
        # Push
        log_message "Push yapiliyor..."
        push_output=$(git push origin main 2>&1)
        
        if [ $? -eq 0 ]; then
            log_message "Push basarili"
            return 0
        else
            log_message "Push hatasi: $push_output"
            
            # Conflict varsa pull dene
            if [[ "$push_output" == *"rejected"* ]] || [[ "$push_output" == *"conflict"* ]]; then
                log_message "Conflict algilandi, pull deneniyor..."
                do_git_pull
            fi
            return 1
        fi
    else
        log_message "Commit hatasi"
        return 1
    fi
}

# Dosya degisikliklerini kontrol et
check_file_changes() {
    cd "$PROJECT_PATH"
    
    status=$(git status --porcelain)
    
    if [ -z "$status" ]; then
        echo ""
        return
    fi
    
    # Degisiklikleri say
    modified=$(echo "$status" | grep -c "^ M")
    added=$(echo "$status" | grep -c "^??")
    deleted=$(echo "$status" | grep -c "^ D")
    
    summary=""
    [ $modified -gt 0 ] && summary+="$modified degistirildi "
    [ $added -gt 0 ] && summary+="$added eklendi "
    [ $deleted -gt 0 ] && summary+="$deleted silindi"
    
    echo "$summary"
}

# Ana dongu
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Git Otomatik Senkronizasyon Baslatildi${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Proje: ${YELLOW}$PROJECT_PATH${NC}"
echo -e "Degisiklik kontrolu: ${YELLOW}$WATCH_INTERVAL saniye${NC}"
echo -e "Pull araligi: ${YELLOW}$((PULL_INTERVAL / 60)) dakika${NC}"
echo -e "${GREEN}----------------------------------------${NC}"
echo ""

log_message "Git otomatik senkronizasyon baslatildi"
log_message "Proje: $PROJECT_PATH"

last_pull_time=$(date +%s)
iteration=0

while true; do
    iteration=$((iteration + 1))
    
    # Duzenli pull
    current_time=$(date +%s)
    time_diff=$((current_time - last_pull_time))
    
    if [ $time_diff -ge $PULL_INTERVAL ]; then
        do_git_pull
        last_pull_time=$(date +%s)
    fi
    
    # Dosya degisikliklerini kontrol et
    changes=$(check_file_changes)
    
    if [ -n "$changes" ]; then
        log_message "Degisiklikler tespit edildi: $changes"
        do_git_commit_push "$changes"
    else
        # Her 10 iterasyonda bir log
        if [ $((iteration % 10)) -eq 0 ]; then
            log_message "Izleniyor... (Degisiklik yok)"
        fi
    fi
    
    sleep $WATCH_INTERVAL
done
