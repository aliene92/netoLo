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


