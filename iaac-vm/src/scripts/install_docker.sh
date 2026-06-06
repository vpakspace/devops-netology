#!/usr/bin/env bash
#
# Установка Docker Engine + docker compose plugin по официальной инструкции
# Docker для Debian/Ubuntu: https://docs.docker.com/engine/install/ubuntu/
# Используется в Vagrant provisioner (Задача 2).
#
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# 1. Зависимости для работы с HTTPS-репозиторием.
apt-get update
apt-get install -y ca-certificates curl gnupg

# 2. Официальный GPG-ключ Docker.
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Подключение apt-репозитория Docker.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

# 4. Установка Docker Engine, CLI, containerd и плагинов (buildx, compose).
apt-get update
apt-get install -y \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Добавляем пользователя vagrant в группу docker (запуск без sudo).
usermod -aG docker vagrant

# 6. Включаем и запускаем сервис.
systemctl enable --now docker

echo "=== Docker установлен ==="
docker version || true
docker compose version || true
