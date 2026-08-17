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

## Основной playbook

Файл `site.yml`:

```yaml
---
- name: Install ClickHouse, Vector and LightHouse
  hosts: all
  become: true

  roles:
    - role: clickhouse
    - role: vector-role
    - role: lighthouse-role
```

## Роль vector-role

Роль `vector-role` выполняет:

- установку зависимостей;
- скачивание deb-пакета Vector;
- установку Vector;
- создание каталога конфигурации;
- генерацию файла `/etc/vector/vector.yaml` из шаблона;
- запуск и включение сервиса Vector.

Основные переменные роли:

| Переменная | Значение по умолчанию | Описание |
|---|---|---|
| `vector_version` | `0.38.0` | Версия Vector |
| `vector_arch` | `amd64` | Архитектура пакета |
| `vector_config_dir` | `/etc/vector` | Каталог конфигурации |
| `vector_config_file` | `/etc/vector/vector.yaml` | Основной конфигурационный файл |
| `vector_service_name` | `vector` | Имя systemd-сервиса |
| `vector_clickhouse_endpoint` | `http://localhost:8123` | HTTP endpoint ClickHouse |
| `vector_clickhouse_database` | `logs` | База данных ClickHouse |
| `vector_clickhouse_table` | `vector_logs` | Таблица ClickHouse |

## Роль lighthouse-role

Роль `lighthouse-role` выполняет:

- установку зависимостей;
- установку nginx;
- клонирование репозитория LightHouse;
- генерацию nginx-конфигурации из шаблона;
- включение сайта LightHouse;
- отключение стандартного сайта nginx;
- запуск и включение сервиса nginx.

Основные переменные роли:

| Переменная | Значение по умолчанию | Описание |
|---|---|---|
| `lighthouse_repo` | `https://github.com/VKCOM/lighthouse.git` | Репозиторий LightHouse |
| `lighthouse_version` | `master` | Ветка или тег LightHouse |
| `lighthouse_dest` | `/var/www/lighthouse` | Каталог установки LightHouse |
| `lighthouse_nginx_conf` | `/etc/nginx/sites-available/lighthouse.conf` | Путь к nginx-конфигурации |
| `lighthouse_nginx_enabled_conf` | `/etc/nginx/sites-enabled/lighthouse.conf` | Путь к активной nginx-конфигурации |
| `lighthouse_listen_port` | `80` | Порт nginx |
| `lighthouse_server_name` | `_` | Имя сервера nginx |

## Запуск playbook

Playbook запускается командой:

```bash
ansible-playbook -i inventory/prod.yml site.yml
```

Результат выполнения:
![scr2](https://github.com/aliene92/netoLo/blob/main/ansible/roles/scrs/tree.png)

## Проверка сервисов

После выполнения playbook были проверены сервисы ClickHouse, Vector и nginx.

```bash
ansible -i inventory/prod.yml all -m command -a "systemctl is-active clickhouse-server" -b
ansible -i inventory/prod.yml all -m command -a "systemctl is-active vector" -b
ansible -i inventory/prod.yml all -m command -a "systemctl is-active nginx" -b
```

Результат:

```text
target-server | CHANGED | rc=0 >>
active

target-server | CHANGED | rc=0 >>
active

target-server | CHANGED | rc=0 >>
active
```

## Проверка портов

Была выполнена проверка открытых портов:

```bash
ansible -i inventory/prod.yml all -m shell -a "ss -tulpn | grep -E '8123|9000|80'" -b
```

Результат:

```text
tcp   LISTEN 0      4096            127.0.0.1:9000      0.0.0.0:*    users:(("clickhouse-serv",pid=19057,fd=160))
tcp   LISTEN 0      511               0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=21263,fd=6),("nginx",pid=21262,fd=6),("nginx",pid=21261,fd=6),("nginx",pid=21260,fd=6),("nginx",pid=20955,fd=6))
tcp   LISTEN 0      4096            127.0.0.1:8123      0.0.0.0:*    users:(("clickhouse-serv",pid=19057,fd=159))
tcp   LISTEN 0      4096                [::1]:8123         [::]:*    users:(("clickhouse-serv",pid=19057,fd=71))
tcp   LISTEN 0      4096                [::1]:9000         [::]:*    users:(("clickhouse-serv",pid=19057,fd=73))
```

## Проверка ClickHouse

Проверка доступности ClickHouse:

```bash
ansible -i inventory/prod.yml all -m command -a "clickhouse-client -q 'SHOW DATABASES'" -b
```

Результат:

```text
target-server | CHANGED | rc=0 >>
INFORMATION_SCHEMA
default
information_schema
system
```

## Проверка LightHouse

Проверка доступности LightHouse через nginx:

