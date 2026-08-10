#!/bin/bash

# Переходим в корень репозитория
cd "$(git rev-parse --show-toplevel)"

# Снимаем выделение со всех файлов, чтобы они стали незакоммиченными (красными)
git reset

# Базовая дата (2026-07-19 — 22 дня назад от 2026-08-10)
BASE_TIMESTAMP=$(date -d "2026-07-19 12:00:00" +%s)

for i in $(seq -w 1 22); do
    DAY_PATH="Days/Day${i} - completed"
    
    DAY_INDEX=$((10#$i - 1))
    OFFSET=$((DAY_INDEX * 86400))
    CURRENT_TIMESTAMP=$((BASE_TIMESTAMP + OFFSET))
    
    COMMIT_DATE=$(date -d "@$CURRENT_TIMESTAMP" +"%Y-%m-%dT%H:%M:%S")
    
    # Индексируем ТОЛЬКО текущий день
    git add "$DAY_PATH"
    
    # Создаем коммит
    GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" git commit -m "Completed Day $i"
    
    echo "Day $i committed with date: $COMMIT_DATE"
done