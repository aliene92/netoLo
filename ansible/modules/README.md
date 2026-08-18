# Домашнее задание к занятию 6 «Создание собственных модулей»

## Подготовка окружения
Настройка тестового окружения показана на скриншоте ниже.
![scr1](https://github.com/aliene92/netoLo/blob/main/ansible/modules/scrs/testenv.png)
Проверка версий:

```bash
ansible --version
ansible-galaxy --version
python3 --version
pip3 --version
git --version
```

Используемые версии:

```text
ansible-core 2.22.0
Python 3.14.4
pip 25.1.1
git 2.53.0
```
![scr2](https://github.com/aliene92/netoLo/blob/main/ansible/modules/scrs/vers.png)

## Инициализация Ansible collection

Collection была создана командой:

```bash
ansible-galaxy collection init my_own_namespace.yandex_cloud_elk
```

После этого collection была размещена в стандартной структуре Ansible collections:

```text
ansible/my_own_namespace/yandex_cloud_elk
```

Итоговый путь collection:

```text
/home/mrk/ansible/4p/ansible/my_own_namespace/yandex_cloud_elk
```

---
## Создание собственного Ansible module

Модуль был создан в каталоге:

```text
ansible/my_own_namespace/yandex_cloud_elk/plugins/modules/my_own_module.py
```

Модуль принимает два обязательных параметра:

| Параметр | Тип | Обязательный | Описание |
|---|---|---|---|
| `path` | string | да | Путь к создаваемому или обновляемому файлу |
| `content` | string | да | Содержимое файла |

Логика работы модуля:

1. Получает параметры `path` и `content`.
2. Проверяет, существует ли файл по указанному пути.
3. Если файл существует и его содержимое уже совпадает с нужным, возвращает `changed: false`.
4. Если файла нет или его содержимое отличается, создаёт или обновляет файл.
5. Возвращает `changed: true`, если файл был создан или изменён.
6. Поддерживает `check_mode`.

---

## Содержимое custom module

Файл:

```text
ansible/my_own_namespace/yandex_cloud_elk/plugins/modules/my_own_module.py
```

Основная логика модуля:

```python
#!/usr/bin/python

from __future__ import absolute_import, division, print_function
__metaclass__ = type

import os
from ansible.module_utils.basic import AnsibleModule


def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True),
    )

    result = dict(
        changed=False,
        path='',
        content='',
        message='',
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True,
    )

    path = module.params['path']
    content = module.params['content']

    result['path'] = path
    result['content'] = content

    current_content = None

    if os.path.exists(path):
        try:
            with open(path, 'r', encoding='utf-8') as file:
                current_content = file.read()
        except Exception as error:
            module.fail_json(
                msg='Failed to read existing file: {0}'.format(error),
                **result
            )

    if current_content == content:
        result['changed'] = False
        result['message'] = 'File already exists with required content'
        module.exit_json(**result)

    result['changed'] = True

    if module.check_mode:
        result['message'] = 'File would be created or updated'
        module.exit_json(**result)

    directory = os.path.dirname(path)

    if directory and not os.path.exists(directory):
        try:
            os.makedirs(directory, exist_ok=True)
        except Exception as error:
            module.fail_json(
                msg='Failed to create directory: {0}'.format(error),
                **result
            )

    try:
        with open(path, 'w', encoding='utf-8') as file:
            file.write(content)
    except Exception as error:
        module.fail_json(
            msg='Failed to write file: {0}'.format(error),
            **result
        )

    result['message'] = 'File has been created or updated'
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```

---

## Локальная проверка module

Проверка выполнялась прямым запуском Python-файла модуля.

Команда:

```bash
python3 plugins/modules/my_own_module.py <<'EOF'
{"ANSIBLE_MODULE_ARGS": {"path": "/tmp/my_own_module_local_test.txt", "content": "Hello from local module test"}}
EOF
```
