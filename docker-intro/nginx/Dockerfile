# Кастомный форк официального образа Nginx.
# Nginx по умолчанию запускается в фоне внутри контейнера и отдаёт
# статическую страницу из /usr/share/nginx/html.
FROM nginx:1.27-alpine

LABEL maintainer="vpakspace"
LABEL description="Netology DevOps homework 05-virt-03: custom nginx image"

# Подменяем стандартную домашнюю страницу на свою.
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
