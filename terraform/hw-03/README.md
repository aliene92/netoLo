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
Для выполнения задания был создан файл `locals.tf`. В коде используется конструкция index + 1 позволяет получить имена web-1 и web-2, а не web-0 и web-1. Так же в код файла была добавлена функция file для считывания ключа ~/.ssh/id_rsa.pub.
конструкция 
```text
web_vm_names = [
    for index in range(var.web_vm_count) : "${var.web_vm_name_prefix}-${index + 1}"
  ]
}

ssh_public_key = file(pathexpand("~/.ssh/id_rsa.pub"))

  vm_metadata = {
    ssh-keys = "${var.vm_ssh_user}:${local.ssh_public_key}"
  }

```
Так как в задании явно указано имя файла ssh ключа был создан новый ключ с требуемым именем.

