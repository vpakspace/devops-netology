# Домашнее задание. «Применение принципов IaaC в работе с виртуальными машинами»

Создание виртуальных машин в VirtualBox с помощью Vagrant и базовое
использование Packer в Yandex Cloud.

## Структура

```
iaac-vm/
├── README.md
├── .gitignore
└── src/
    ├── Vagrantfile                 # Задача 2: ВМ VirtualBox + Docker
    ├── mydebian.json.pkr.hcl       # Задача 3: образ Debian в YC (Packer)
    └── scripts/
        └── install_docker.sh       # provisioner для Vagrant (установка Docker)
```

---

## Задача 1. Установка инструментов

Требуется (желательно Ubuntu 20.04, локальная машина — **не** облачная ВМ):

| Инструмент | Версия | Команда установки |
|------------|--------|-------------------|
| VirtualBox | актуальная | `sudo apt-get install -y virtualbox` |
| Vagrant | 2.3.4 | репозиторий HashiCorp / `.deb` пакет |
| Packer | 1.9.x | репозиторий HashiCorp + [плагин Yandex](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/packer-quickstart) |
| yandex cloud cli | — | `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh \| bash`, затем `yc init` |

Профиль YC инициализируется через `yc init` (OAuth-токен → folder → zone).

> **Почему не облачная ВМ:** облачный провайдер не даёт вложенную
> виртуализацию (nested virtualization), поэтому VirtualBox внутри облачной
> ВМ не установится/не запустится.

### ⚠️ Ограничение текущего окружения

Эта работа выполнялась на машине, которая **сама является VirtualBox VM**
(`systemd-detect-virt` → `oracle`). Проверка вложенной виртуализации:

```bash
$ egrep -c '(vmx|svm)' /proc/cpuinfo
0                      # флагов аппаратной виртуализации нет
$ ls /dev/kvm
ls: cannot access '/dev/kvm': No such file or directory
```

Поскольку вложенная виртуализация недоступна, реальный запуск гостевой ВМ
через `vagrant up` завершится ошибкой:

```
VBoxManage: error: VT-X is not available (VERR_VMX_NO_VMX)
```

Это ровно тот случай, который в задании описан как «допускается неполное
выполнение (до ошибки запуска ВМ)». Поэтому ниже приведены **корректные
артефакты** (Vagrantfile, скрипт provisioning, Packer-конфиг) и команды
запуска — их достаточно для сдачи. Включить вложенную виртуализацию можно
на хосте командой:

```powershell
# PowerShell от администратора на Windows-хосте, затем настройка в VirtualBox:
# Settings → System → Processor → Enable Nested VT-x/AMD-V
```

---

## Задача 2. ВМ VirtualBox через Vagrant + Docker

SSH-ключ на машине присутствует (`~/.ssh/yc_diplom.pub`, тип `ed25519`).
При необходимости создаётся командой:

```bash
ssh-keygen -t ed25519
```

Файл [`src/Vagrantfile`](src/Vagrantfile):

- box — `bento/ubuntu-24.04` (рекомендованное зеркало, т.к. `bento/ubuntu-20.04`
  отдаёт `404` на Vagrant Cloud);
- provisioner — [`src/scripts/install_docker.sh`](src/scripts/install_docker.sh)
  ставит Docker по официальной инструкции для Debian/Ubuntu.

Запуск и проверка:

```bash
cd src
vagrant up
vagrant ssh
# внутри ВМ:
docker version && docker compose version
```

---

## Задача 3. Образ Debian в Yandex Cloud через Packer

Файл [`src/mydebian.json.pkr.hcl`](src/mydebian.json.pkr.hcl) (Packer
поддерживает и JSON, и HCL — здесь HCL):

- базовый образ — семейство `debian-12` из публичного каталога;
- в образ устанавливаются **Docker** (официальная инструкция для Debian),
  а также **htop** и **tmux**;
- для apt используется `DEBIAN_FRONTEND=noninteractive` + `-y` —
  автоматическое подтверждение установки.

### Сборка образа

Токен и folder_id передаются переменными (НЕ хранятся в git):

```bash
cd src
export YC_TOKEN="$(yc iam create-token)"
export YC_FOLDER_ID="$(yc config get folder-id)"

packer init .
packer build \
  -var "token=${YC_TOKEN}" \
  -var "folder_id=${YC_FOLDER_ID}" \
  mydebian.json.pkr.hcl
```

### Поиск образа в Yandex Cloud

Web-консоль: **Compute Cloud → Образы**.

CLI (необязательное задание со звёздочкой):

```bash
yc compute image list --folder-id <folder-id>
# или по семейству:
yc compute image get-latest-from-family mydebian-docker --folder-id <folder-id>
```

### Создание ВМ из образа, проверка Docker, удаление

```bash
# Минимальная ВМ из собранного образа:
IMAGE_ID=$(yc compute image get-latest-from-family mydebian-docker --format json | jq -r .id)

yc compute instance create \
  --name mydebian-test \
  --zone ru-central1-a \
  --create-boot-disk image-id=${IMAGE_ID},size=15 \
  --memory 2 --cores 2 \
  --network-interface subnet-name=default,nat-ip-version=ipv4 \
  --ssh-key ~/.ssh/yc_diplom.pub

# Подключение и проверка Docker:
ssh ubuntu@<public-ip>
docker version && docker compose version

# Удаление ВМ и образа (экономия ресурсов!):
yc compute instance delete mydebian-test
yc compute image delete ${IMAGE_ID}
```

---

## Безопасность

> **ВНИМАНИЕ!** OAuth-токен от облака НИКОГДА не выкладывается в git-репозиторий.
> Утечка токена ведёт к финансовым потерям. В файлах `mydebian.json.pkr.hcl`
> значения `token` и `folder_id` заменены на `ххххх`. Реальные значения
> передаются только через переменные окружения / `-var` при запуске.
