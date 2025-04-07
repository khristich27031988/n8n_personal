# Интеграция SQLite с контейнером n8n

## Проблема

Исходная проблема заключалась в том, что при использовании контейнера n8n с Docker возникли сложности с подключением и использованием SQLite. Основные проблемы:

1. Отсутствие необходимых библиотек (`sqlite3` или `better-sqlite3`) в базовом образе n8n
2. Отсутствие необходимых системных зависимостей для компиляции нативных модулей
3. Проблемы с правами доступа к директориям для баз данных
4. Необходимость сохранения баз данных при перезапуске контейнера

## Цель

Настроить контейнер n8n таким образом, чтобы:
1. SQLite был доступен из workflows в n8n
2. База данных сохранялась между перезапусками контейнера
3. Решение было стабильным и не требовало ручных действий при перезапуске

## Решение

### 1. Создание пользовательского Dockerfile

Был создан собственный Dockerfile, который расширяет базовый образ n8n:

```dockerfile
FROM n8nio/n8n:latest

# Переключаемся на пользователя root для установки пакетов
USER root

# Устанавливаем системные зависимости
RUN apk add --no-cache \
    python3 make g++ build-base linux-headers sqlite-dev

# Устанавливаем node-gyp для сборки нативных модулей
RUN npm install -g node-gyp

# Создаем директорию для глобальных модулей
RUN mkdir -p /usr/local/lib/node_modules

# Устанавливаем better-sqlite3 глобально
RUN npm install better-sqlite3@8.7.0 --prefix=/usr/local/lib/node_modules --build-from-source

# Также устанавливаем его локально для пользователя node
WORKDIR /home/node
RUN mkdir -p /home/node/node_modules && \
    chown -R node:node /home/node/node_modules && \
    su node -c "npm install better-sqlite3@8.7.0 --build-from-source"

# Настраиваем переменные окружения
ENV NODE_PATH=/usr/local/lib/node_modules:/usr/local/lib/node_modules/node_modules:/home/node/node_modules

# Создаем директорию для SQLite
RUN mkdir -p /home/node/sqlite && chown -R node:node /home/node/sqlite

# Возвращаемся к пользователю node (как в базовом образе)
USER node
```

### 2. Настройка Docker Compose

Для монтирования директорий с данными был настроен файл `docker-compose.yml`:

```yaml
version: '3'

services:
  n8n_personal:
    container_name: n8n_personal
    build: .
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=personalassist.online
      - NODE_ENV=production
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - N8N_SSL_CERT=/home/node/certificate/fullchain.pem
      - N8N_SSL_KEY=/home/node/certificate/privkey.pem
      - WEBHOOK_URL=https://personalassist.online/
      - GENERIC_TIMEZONE=Europe/Moscow
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./sqlite:/home/node/sqlite
      - /etc/letsencrypt/live/personalassist.online:/home/node/certificate:ro
    restart: unless-stopped
```

### 3. Ключевые моменты решения

1. **Системные зависимости**:
   - Установлены необходимые пакеты (`make`, `g++`, `build-base`, `linux-headers`, `sqlite-dev`) для компиляции нативных модулей

2. **Node.js модули**:
   - Установлен `node-gyp` для сборки нативных модулей
   - Установлен `better-sqlite3` как глобально, так и локально для пользователя `node`

3. **Права доступа**:
   - Создана директория `/home/node/sqlite` с правами доступа для пользователя `node`
   - Настроены права доступа для директории `/home/node/node_modules`

4. **Переменные окружения**:
   - Настроен `NODE_PATH` для поиска модулей как в глобальных, так и в локальных директориях

5. **Монтирование томов**:
   - Директория с данными n8n (`./n8n_data:/home/node/.n8n`)
   - Директория для баз данных SQLite (`./sqlite:/home/node/sqlite`)

## Результаты

1. SQLite успешно интегрирован с n8n через модуль `better-sqlite3`
2. Модуль `better-sqlite3` доступен сразу после запуска контейнера
3. Базы данных сохраняются между перезапусками контейнера
4. n8n может создавать, читать и записывать данные в базы данных SQLite

## Проверка работоспособности

Тестирование подтвердило, что:

1. Модуль `better-sqlite3` доступен из Node.js внутри контейнера
2. n8n может создавать новые базы данных в директории `/home/node/sqlite/`
3. Данные в базах сохраняются между перезапусками контейнера
4. Права доступа настроены правильно для всех директорий

## Текущие настройки и пути

- **Путь к n8n данным**: `/home/node/.n8n` (монтируется из хоста: `./n8n_data`)
- **Путь к директории SQLite**: `/home/node/sqlite` (монтируется из хоста: `./sqlite`)
- **Путь к основной базе данных n8n**: `/home/node/.n8n/database.sqlite`
- **Путь к установленному модулю better-sqlite3**: `/home/node/node_modules/better-sqlite3`

## Заключение

Разработанное решение обеспечивает стабильную работу SQLite внутри контейнера n8n. При создании n8n workflows можно использовать модуль `better-sqlite3` для работы с базами данных SQLite, хранящимися в монтированной директории `/home/node/sqlite/`. Данные в этой директории сохраняются между перезапусками контейнера, обеспечивая долговременное хранение данных. 