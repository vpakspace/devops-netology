# Домашние задания по модулю «Виртуализация и контейнеризация»

Индекс домашних заданий модуля со ссылками для сдачи в личном кабинете Netology.

| # | Тема | Решение | Ссылка для сдачи |
|---|------|---------|------------------|
| 1 | Введение в виртуализацию | `virtualization-intro/` | <https://github.com/vpakspace/devops-netology/tree/main/virtualization-intro> |
| 2 | Применение принципов IaaC в работе с виртуальными машинами | `iaac-vm/` | <https://github.com/vpakspace/devops-netology/tree/main/iaac-vm> |
| 3 | Введение в Docker | `docker-intro/` | <https://github.com/vpakspace/devops-netology/tree/main/docker-intro> |
| 4 | Оркестрация группой Docker контейнеров (Docker Compose) | форк `shvirtd-example-python` | <https://github.com/vpakspace/shvirtd-example-python/blob/main/SOLUTION.md> |
| 5 | Оркестрация кластером Docker контейнеров (Docker Swarm) | `docker-swarm/` | <https://github.com/vpakspace/devops-netology/tree/main/docker-swarm> |

## Краткое содержание

- **ДЗ 1 — Введение в виртуализацию.** Эконом-ВМ в Yandex Cloud (прерываемая), SSH + Docker, теория виртуализации.
- **ДЗ 2 — IaaC + ВМ.** Vagrant (`bento/ubuntu-24.04` + Docker) и Packer-образ в Yandex Cloud (Debian 12 + docker/htop/tmux).
- **ДЗ 3 — Введение в Docker.** Кастомный nginx-образ → Docker Hub (`vpakspace/netology-nginx`), теория Docker vs VM (8 сценариев), общий volume между CentOS и Debian, бонус — образ с Ansible (`vpakspace/netology-ansible`).
- **ДЗ 4 — Практическое применение Docker (Compose).** Multistage `Dockerfile.python`, `compose.yaml` с `include` прокси-стека (Nginx → HAProxy → FastAPI → MySQL), деплой на облачную ВМ через bash-скрипт, проверка через check-host.net, извлечение бинаря из образа через `dive`/`docker save` и `docker cp`. Решение — в [форке](https://github.com/vpakspace/shvirtd-example-python).
- **ДЗ 5 — Docker Swarm.** Кластер из 3 ВМ в Yandex Cloud: 1 manager (Leader) + 2 worker, `docker node ls`. *(Самостоятельная отработка, без обратной связи преподавателя.)*

> Облачные ресурсы Yandex Cloud по всем ДЗ удалены после демонстрации — согласно инструкции по экономии облачных средств.
