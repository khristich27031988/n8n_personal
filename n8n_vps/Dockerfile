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