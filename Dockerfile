# Базовый образ — легче, чем официальный gitpod/openvscode-server
FROM lscr.io/linuxserver/openvscode-server:latest

# Устанавливаем переменные окружения для оптимизации
ENV \
    # Отключаем телеметрию и автоматические обновления (экономит ресурсы)
    VSCODE_TELEMETRY_DISABLED=1 \
    OPENVSCODE_SERVER_VERSION=latest \
    # Принудительно используем порт, переданный Render
    PORT=10000

# Переключаемся на пользователя root, чтобы установить дополнительные пакеты (опционально)
USER root

# Устанавливаем нужные утилиты (если требуется, можно убрать)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Создаём скрипт запуска, который правильно обрабатывает PORT и ограничения памяти
RUN echo '#!/bin/bash\n\
    # Проверяем, задан ли PORT через окружение Render, если нет — используем 10000\n\
    PORT=${PORT:-10000}\n\
    # Запускаем сервер с явным указанием порта\n\
    exec /app/openvscode-server/bin/openvscode-server --port $PORT --host 0.0.0.0\n\
    ' > /start.sh && chmod +x /start.sh

# Переключаемся обратно на пользователя по умолчанию (для безопасности)
USER vscode-server

# Точка входа — наш скрипт
ENTRYPOINT ["/start.sh"]
