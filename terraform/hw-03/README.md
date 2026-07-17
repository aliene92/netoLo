# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»
## Задание 1
### Задание 1.1
#### Ответ
Проект изучен.
### Задание 1.2
#### Ответ
Перед инициализацией проекта в файл `personal.auto.tfvars` были добавлены значения для переменных `cloud_id`, `folder_id`, `token`. Токен с прошлого раза устарел, поэтому пришлось выпустить новый, командой `yc iam create-token`.\
Ниже приложен скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud.
![secYc](https://github.com/aliene92/netoLo/blob/main/terraform/hw-03/scr/secureYC.png)
## Задание 2
### Задание 2.1
#### Ответ
Для выполнения условия задания был создан файл `locals.tf` c текстом 
```text
web_vm_names = [
    for index in range(var.web_vm_count) : "${var.web_vm_name_prefix}-${index + 1}"
  ]
}

```
