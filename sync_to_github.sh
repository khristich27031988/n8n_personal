#!/bin/bash

# Скрипт для синхронизации папок с GitHub репозиторием
# Запускается cron ежедневно

# Настройки
REPO_DIR="/root/temp_sync_project"
N8N_SOURCE="/opt/n8n_vps"
PROJECTS_SOURCE="/root/projects"
N8N_DEST="${REPO_DIR}/n8n_vps"
PROJECTS_DEST="${REPO_DIR}/projects"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Переходим в директорию репозитория
cd $REPO_DIR || exit 1

# Получаем изменения с GitHub (если репозиторий уже создан)
if git remote | grep -q origin; then
    git pull origin master
fi

# Синхронизация папок (используем rsync для эффективной синхронизации)
echo "Синхронизация /opt/n8n_vps..."
rsync -av --delete $N8N_SOURCE/ $N8N_DEST/

echo "Синхронизация /root/projects..."
rsync -av --delete $PROJECTS_SOURCE/ $PROJECTS_DEST/

# Добавляем изменения в Git
git add .

# Если есть изменения, создаем коммит и отправляем на GitHub
if git status | grep -q "Changes to be committed"; then
    git commit -m "Автоматическая синхронизация: $TIMESTAMP"
    
    # Пуш в репозиторий (если origin уже настроен)
    if git remote | grep -q origin; then
        git push origin master
    else
        echo "ВНИМАНИЕ: Удаленный репозиторий не настроен. Изменения только локально."
    fi
else
    echo "Изменений нет. Синхронизация не требуется."
fi

echo "Синхронизация завершена: $TIMESTAMP" 