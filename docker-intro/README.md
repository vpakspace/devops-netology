# Домашнее задание «Введение в Docker» (05-virt-03-docker)

Окружение: Ubuntu 24.04, Docker version 29.1.3.

Структура каталога:

```
docker-intro/
├── README.md            # этот файл (сдача)
├── nginx/               # Задание 1: кастомный образ Nginx
│   ├── Dockerfile
│   └── index.html
├── ansible/             # Задание 4*: образ с Ansible
│   └── Dockerfile
└── img/                 # скриншоты
    └── 01_nginx_page.png
```

---

## Задание 1. Кастомный образ Nginx

Нужно собрать форк официального образа Nginx, который:
- запускает веб-сервер в фоновом режиме;
- отдаёт главную страницу с «Hey, Netology» в шапке и «I'm DevOps Engineer!» как заголовок `h1`;
- публикуется в Docker Hub.

### Dockerfile (`nginx/Dockerfile`)

```dockerfile
FROM nginx:1.27-alpine

LABEL maintainer="vpakspace"
LABEL description="Netology DevOps homework 05-virt-03: custom nginx image"

# Подменяем стандартную домашнюю страницу на свою.
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
```

### Главная страница (`nginx/index.html`)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Hey, Netology</title>
</head>
<body>
    <header>Hey, Netology</header>
    <h1>I'm DevOps Engineer!</h1>
</body>
</html>
```

### Сборка и запуск

```bash
cd nginx
docker build -t vpakspace/netology-nginx:1.0 -t vpakspace/netology-nginx:latest .

# Запуск в фоновом режиме (-d)
docker run -d --name netology-nginx -p 8088:80 vpakspace/netology-nginx:1.0
```

Контейнер запущен в фоне:

```
CONTAINER ID   IMAGE                          COMMAND                  STATUS         PORTS                    NAMES
a2b726f34d7a   vpakspace/netology-nginx:1.0   "/docker-entrypoint.…"   Up 2 seconds   0.0.0.0:8088->80/tcp     netology-nginx
```

Проверка отдачи страницы:

```bash
$ curl -s http://localhost:8088/
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Hey, Netology</title>
</head>
<body>
    <header>Hey, Netology</header>
    <h1>I'm DevOps Engineer!</h1>
</body>
</html>
```

Страница в браузере:

![Nginx page](img/01_nginx_page.png)

### Публикация в Docker Hub

```bash
docker login
docker push vpakspace/netology-nginx:1.0
docker push vpakspace/netology-nginx:latest
```

**Ссылка на Docker Hub:** https://hub.docker.com/r/vpakspace/netology-nginx

> Образ собран и проверен локально. Перед `docker push` нужно выполнить `docker login`
> под своей учётной записью Docker Hub (`vpakspace`).

---

## Задание 2. Docker против виртуальных/физических машин

Для каждого сценария — уместен ли Docker-контейнер или лучше ВМ/физический сервер.

| # | Сценарий | Рекомендация | Обоснование |
|---|----------|--------------|-------------|
| 1 | Высоконагруженное **монолитное Java**-веб-приложение | ВМ / физический сервер | Большой stateful-монолит требует много CPU/RAM и тонкой настройки JVM/GC. Горизонтального масштабирования (главное преимущество контейнеров) у монолита почти нет. Контейнеризация возможна ради унификации деплоя, но выигрыша даёт мало — предсказуемее выделенная ВМ. |
| 2 | Веб-приложение на **Node.js** | **Docker** ✅ | Stateless, лёгкое, быстро стартует, легко масштабируется горизонтально. Идеальный кандидат на контейнеризацию и оркестрацию (Compose/Swarm/K8s). |
| 3 | **Мобильные приложения** (Android/iOS) | Не подходит | Это клиентские приложения для устройств, а Docker — серверная (Linux) технология. Сборку Android можно гонять в контейнере в CI, но запуск приложений — нет; сборка iOS требует macOS (физический Mac), Docker неприменим. |
| 4 | Шина данных **Apache Kafka** | Docker с осторожностью / ВМ для тяжёлого prod | Stateful, чувствительна к диску и сети, нужен persistent storage. Для dev/test — отлично в Docker; для высоконагруженного production надёжнее выделенные ВМ или контейнеры с быстрыми persistent-томами и продуманным размещением брокеров. |
| 5 | Кластер **Elasticsearch + Logstash + Kibana** | Docker с persistent volumes / ВМ для крупного prod | ES хранит данные и прожорлив к RAM/диску, требует системного тюнинга (`vm.max_map_count`). В Docker разворачивается часто (Compose, ECK-оператор в K8s), но обязательны persistent-тома; крупный production-кластер часто выносят на выделенные ВМ. |
| 6 | Мониторинг **Prometheus/Grafana** | **Docker** ✅ | Стандартная практика: разворачивается через docker-compose. Grafana почти stateless, Prometheus хранит TSDB в одном volume. Лёгкая и удобная контейнеризация. |
| 7 | **MongoDB** как основное хранилище | ВМ / выделенный узел (или managed), Docker с volume — допустимо | Основное хранилище критично к надёжности, бэкапам и дисковому I/O. В Docker работает с persistent-томом, но для primary-БД production чаще выбирают ВМ/физику или managed-сервис ради стабильности и производительности. |
| 8 | **GitLab** + CI/CD + приватный Docker Registry | Сервер — ВМ; CI-раннеры и Registry — Docker | GitLab (omnibus) — тяжёлое stateful-приложение (БД, репозитории, артефакты), требует много ресурсов и persistence — удобнее на отдельной ВМ. А вот CI-раннеры и Docker Registry прекрасно работают в контейнерах. |

**Вывод.** Docker уместен для stateless / легко масштабируемых / эфемерных нагрузок
(Node.js, Prometheus/Grafana, CI-раннеры). Для тяжёлых stateful-систем и критичных
хранилищ (монолит, primary-БД, GitLab-сервер) предпочтительнее ВМ/физический сервер
либо контейнеры с обязательными persistent-томами. Мобильные приложения вне области
применения Docker.

---

## Задание 3. Общий volume между двумя контейнерами

Последовательность:
1. запустить контейнер CentOS в фоне с примонтированным каталогом `/data`;
2. запустить контейнер Debian в фоне с тем же `/data`;
3. создать текстовый файл в `/data` изнутри CentOS;
4. добавить ещё один файл в `/data` с хост-машины;
5. зайти в Debian и вывести список и содержимое файлов в `/data`.

Каталог `/data` пробрасывается bind-mount'ом в общий каталог на хосте
(`/tmp/netology-shared-data`), поэтому шаг 4 — это просто запись в этот каталог.

```bash
HOSTDIR=/tmp/netology-shared-data
mkdir -p $HOSTDIR

# 1) CentOS с /data (фоновый режим)
docker run -d --name centos-box -v $HOSTDIR:/data centos:7 sleep infinity

# 2) Debian с тем же /data (фоновый режим)
docker run -d --name debian-box -v $HOSTDIR:/data debian:12 sleep infinity

# 3) файл изнутри CentOS
docker exec centos-box bash -c 'echo "Этот файл создан ВНУТРИ контейнера CentOS" > /data/from_centos.txt'

# 4) файл с хост-машины
echo "Этот файл создан на ХОСТ-машине" > $HOSTDIR/from_host.txt

# 5) читаем изнутри Debian
docker exec debian-box bash -c 'ls -l /data; for f in /data/*.txt; do echo ">>> $f"; cat "$f"; done'
```

Результат шага 5 (вывод из контейнера Debian):

```
--- ls -l /data ---
total 8
-rw-r--r-- 1 root root 72 Jun 11 07:21 from_centos.txt
-rw-rw-r-- 1 1000 1000 58 Jun 11 07:21 from_host.txt
--- содержимое файлов ---
>>> /data/from_centos.txt
Этот файл создан ВНУТРИ контейнера CentOS
>>> /data/from_host.txt
Этот файл создан на ХОСТ-машине
```

Debian-контейнер видит оба файла: и созданный внутри CentOS-контейнера, и добавленный
на хост-машине, — том общий для обоих контейнеров и хоста.

Очистка:

```bash
docker rm -f centos-box debian-box
```

---

## Задание 4*. Образ с Ansible

Dockerfile (`ansible/Dockerfile`):

```dockerfile
FROM python:3.12-slim

LABEL maintainer="vpakspace"
LABEL description="Netology DevOps homework 05-virt-03: image with Ansible"

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-client sshpass \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir ansible

RUN ansible --version

ENTRYPOINT ["ansible"]
CMD ["--version"]
```

Сборка и проверка:

```bash
cd ansible
docker build -t vpakspace/netology-ansible:1.0 -t vpakspace/netology-ansible:latest .
docker run --rm vpakspace/netology-ansible:1.0
```

Вывод:

```
ansible [core 2.21.0]
  config file = None
  ansible python module location = /usr/local/lib/python3.12/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.12.13 [GCC 14.2.0]
  jinja version = 3.1.6
```

Публикация в Docker Hub:

```bash
docker login
docker push vpakspace/netology-ansible:1.0
docker push vpakspace/netology-ansible:latest
```

**Ссылка на Docker Hub:** https://hub.docker.com/r/vpakspace/netology-ansible
