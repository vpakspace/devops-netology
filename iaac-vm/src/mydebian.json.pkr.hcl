# Домашнее задание «Применение принципов IaaC в работе с виртуальными машинами»
# Задача 3: сборка собственного образа Debian в Yandex Cloud через Packer.
#
# В образ устанавливаются: Docker (по официальной инструкции для Debian),
# а также htop и tmux.
#
# ВНИМАНИЕ! OAuth-токен НИКОГДА не коммитится в git.
# Перед загрузкой в ЛК значение токена заменено на "ххххх".

packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

# --- Переменные -------------------------------------------------------------

variable "token" {
  type        = string
  description = "OAuth-токен Yandex Cloud (НЕ хранить в git!)"
  default     = "ххххх"
  sensitive   = true
}

variable "folder_id" {
  type        = string
  description = "ID каталога (folder) в Yandex Cloud"
  default     = "ххххх"
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

# --- Источник (builder) -----------------------------------------------------

source "yandex" "mydebian" {
  token        = var.token
  folder_id    = var.folder_id
  zone         = var.zone

  # Базовый образ — семейство Debian 12 из публичного каталога standard-images.
  source_image_family = "debian-12"

  # Параметры временной ВМ-сборщика (минимальные).
  use_ipv4_nat       = true
  platform_id        = "standard-v3"
  instance_cores     = 2
  instance_mem_gb    = 2
  disk_type          = "network-ssd"
  disk_size_gb       = 15

  # Параметры результирующего образа.
  image_name        = "mydebian-docker-{{timestamp}}"
  image_description = "Debian 12 + Docker + htop + tmux (Packer, IaaC HW)"
  image_family      = "mydebian-docker"

  ssh_username = "ubuntu"
}

# --- Сборка (build) ---------------------------------------------------------

build {
  sources = ["source.yandex.mydebian"]

  # Установка Docker по официальной инструкции для Debian:
  # https://docs.docker.com/engine/install/debian/
  # Дополнительно: htop и tmux.
  # Ключ -y (DEBIAN_FRONTEND=noninteractive) — автоматическое подтверждение apt.
  provisioner "shell" {
    execute_command = "sudo -S env {{ .Vars }} bash '{{ .Path }}'"
    inline = [
      "set -eux",
      "export DEBIAN_FRONTEND=noninteractive",

      # Зависимости.
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl gnupg htop tmux",

      # GPG-ключ Docker.
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",

      # apt-репозиторий Docker.
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Установка Docker Engine + плагинов.
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      # Проверка.
      "sudo docker version",
      "sudo docker compose version",
      "htop --version",
      "tmux -V",
    ]
  }
}
