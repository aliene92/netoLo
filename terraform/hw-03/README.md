# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»
## Задание 1
### Задание 1.1
#### Ответ
Проект изучен.
### Задание 1.2
#### Ответ
Перед инициализацией проекта в файл `personal.auto.tfvars` были добавлены значения для переменных `cloud_id`, `folder_id`, `token`. Токен с прошлого раза устарел, поэтому пришлось выпустить новый, командой `yc iam create-token`.\
Ниже приложен скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud.
![secYc](https://github.com/aliene92/netoLo/blob/main/terraform/hw-03/scr/secureYCL.png)
## Задание 2
### Задание 2.1
#### Ответ
Созданы файлы `count-vm.tf` и `locals.tf`. В файле `count-vm.tf` описан цикл создания виртуальных машин в заданном кол-ве. В файле `locals.tf` добавлена конструкция `index + 1` для получения имен web-1 и web-2, а не web-0 и web-1. Ниже приведены тексты файлов `count-vm.tf`
```count-vm.tf
resource "yandex_compute_instance" "web" {
  count = var.web_vm_count

  name        = local.vm_web_names[count.index]
  hostname    = local.vm_web_names[count.index]
  platform_id = var.web_vm_platform_id
  zone        = var.vm_zone

  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vm_web_resources.disk_volume
      type     = var.vm_web_resources.disk_type
    }
  }

  network_interface {
    subnet_id          = data.yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.vm_metadata

  scheduling_policy {
    preemptible = true
  }

  depends_on = [
    yandex_compute_instance.db
  ]
}
```
 и `locals.tf`
```locals.tf
locals {

    vm_web_names = [
        for index in range(var.vm_web_count) : "${var.vm_web_name_prefix}-${index + 1}"
    ]

}
```
