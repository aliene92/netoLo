# Домашнее задание к занятию 4 «Работа с roles»
Для выполнения задания были созданы 3 публичных репозитория.

## Репозитории

| Назначение | Репозиторий |
|---|---|
| Vector role | <https://github.com/aliene92/vector-role> |
| LightHouse role | <https://github.com/aliene92/lighthouse-role> |
| Основной playbook | <https://github.com/aliene92/08-ansible-04-role-mrk> |

## Инфраструкура

Для выполнения задания в яндекс клауде был создан целевой сервер для установки ClickHouse, Vector и LightHouse. В качестве управляющего сервера была выбрана локальная система Ubuntu.

## Проверка ansible
На скриншоте ниже видно, что целевая машина доступна по ssh. Команды выполняются от root'a.
![scr1](https://github.com/aliene92/netoLo/blob/main/ansible/roles/scrs/avalroot.png)

## Структура основного репозитория

Репозиторий с playbook содержит playbook, inventory, переменные и файл зависимостей roles:

```text
08-ansible-04-role/
├── group_vars
│   └── all.yml
├── inventory
│   └── prod.yml
├── README.md
├── requirements.yml
└── site.yml
```
![scr2](https://github.com/aliene92/netoLo/blob/main/ansible/roles/scrs/tree.png)\
Каталог `roles/` не хранится в основном репозитории и добавлен в `.gitignore`, так как роли устанавливаются через `ansible-galaxy` из `requirements.yml`.

## Файл inventory

Файл `inventory/prod.yml`:

```yaml
---
all:
  hosts:
    target-server:
      ansible_host: 192.168.1.84
      ansible_user: it
      ansible_become: true
```

## Файл переменных

Файл `group_vars/all.yml`:

```yaml
---
clickhouse_version: "22.3.3.44"
clickhouse_packages:
  - clickhouse-client
  - clickhouse-server
  - clickhouse-common-static

vector_clickhouse_endpoint: "http://localhost:8123"
vector_clickhouse_database: "logs"
vector_clickhouse_table: "vector_logs"

lighthouse_listen_port: 80
lighthouse_server_name: "_"
```

## Файл requirements.yml

В файл `requirements.yml` добавлены роли ClickHouse, Vector и LightHouse.

```yaml
---
- src: https://github.com/AlexeySetevoi/ansible-clickhouse.git
  scm: git
  version: "1.13"
  name: clickhouse

- src: https://github.com/victoryurochkin/vector-role.git
  scm: git
  name: vector-role

- src: https://github.com/victoryurochkin/lighthouse-role.git
  scm: git
  name: lighthouse-role
```

Роли Vector и LightHouse опубликованы в отдельных публичных репозиториях

## Установка roles

Роли устанавливаются командой:

```bash
ansible-galaxy install -r requirements.yml -p roles
```

Результат установки:
![scr3](https://github.com/aliene92/netoLo/blob/main/ansible/roles/scrs/instrol.png)

После установки роли располагаются в каталоге `roles/`:

```text
roles
├── clickhouse
├── lighthouse-role
└── vector-role
```
