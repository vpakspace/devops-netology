# Образ с предустановленным Ansible (бонусное задание 4*).
FROM python:3.12-slim

LABEL maintainer="vpakspace"
LABEL description="Netology DevOps homework 05-virt-03: image with Ansible"

# Ansible требует ssh-клиент для подключения к управляемым хостам.
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-client sshpass \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir ansible

# Проверяем, что ansible доступен на этапе сборки.
RUN ansible --version

ENTRYPOINT ["ansible"]
CMD ["--version"]
