# devops-netology

Репозиторий для домашних заданий и проектов курса DevOps от Netology.

Здесь сохраняются скрипты и конфигурации для различных систем,
изучаемых на протяжении курса.

## Игнорируемые файлы (.gitignore)

В каталоге `terraform/` находится файл `.gitignore`, благодаря которому
Git **не будет** отслеживать и сохранять в репозитории служебные и
секретные файлы Terraform:

- `**/.terraform/*` — локальные рабочие каталоги Terraform (кэш плагинов и модулей);
- `*.tfstate`, `*.tfstate.*` — файлы состояния инфраструктуры (могут содержать секреты);
- `crash.log`, `crash.*.log` — журналы аварийных завершений Terraform;
- `*.tfvars`, `*.tfvars.json` — файлы с переменными, часто хранящие пароли,
  приватные ключи и другие чувствительные данные;
- `override.tf`, `override.tf.json`, `*_override.tf`, `*_override.tf.json` —
  файлы локальных переопределений ресурсов;
- `.terraform.tfstate.lock.info` — временный файл блокировки при `terraform apply`;
- `.terraformrc`, `terraform.rc` — пользовательские конфигурационные файлы CLI.

Корневой файл `.gitignore` зарезервирован для общих правил репозитория.

## Удалённые репозитории

Проект синхронизируется с двумя удалёнными репозиториями:

- **GitHub** (`origin`): https://github.com/vpakspace/devops-netology
- **GitLab** (`gitlab`): https://gitlab.com/vpakspace/devops-netology
