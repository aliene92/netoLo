# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»
## Задание 1
### Задание 1.1
#### Ответ
Проект изучен.
### Задание 1.2
#### Ответ
Перед инициализацией проекта в файл `personal.auto.tfvars` были добавлены значения для переменных `cloud_id`, `folder_id`, `token`. Токен с прошлого раза устарел, поэтому пришлось выпустить новый, командой `yc iam create-token`.\
Ниже приложен скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud.
![secYc](https://github.com/aliene92/netoLo/blob/main/terraform/hw-03/scr/srr.png)
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
      image_id = yandex_compute_image.ubuntu.image_id
      size     = var.vm_web_resources.disk_volume
      type     = var.vm_web_resources.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
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
### Задание 2.2
#### Ответ
Был создан файл `for_each-vm.tf` в котором описывается создание двух ВМ с именами main и replica, для этих машин используются разные настройки по кол-ву ресурсов, а именно ядер, памяти, гарантированной доступности процессора(core fraction) и величине диска. В файл `variable.tf` была добавлена переменная `each_vm`. Ниже текст файла `for_each-vm.tf`
```for_each-vm.tf
resource "yandex_compute_instance" "db" {
  for_each = {
    for vm in var.each_vm : vm.vm_name => vm
  }

  name        = each.value.vm_name
  hostname    = each.value.vm_name
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
      type     = each.value.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.metadata

  scheduling_policy {
    preemptible = true
  }
}
```
и текст созданной переменной `each_vm`
```each_vm
variable "each_vm" {
  type = list(object({
    vm_name       = string
    cpu           = number
    ram           = number
    core_fraction = number
    disk_volume   = number
    disk_type     = string
  }))

  default = [
    {
      vm_name       = "main"
      cpu           = 2
      ram           = 1
      disk_volume   = 5
      core_fraction = 5
      disk_type     = "network-hdd"
    },
    {
      vm_name       = "replica"
      cpu           = 4
      ram           = 2
      disk_volume   = 10
      core_fraction = 20
      disk_type     = "network-hdd"
    }
  ]
}
```
### Задание 2.3
#### Ответ
Для того, что бы ВМ, описанные в файле `count-vm.tf`, создавались после ВМ, описанных в файле `for_each-vm.tf` в файл `count-vm.tf` добавлена конструкция `depends_on`:
```depends_on
depends_on = [
    yandex_compute_instance.db
  ]
```
### Задание 2.4
#### Ответ
В задании однозначно задано имя ssh ключа, поэтому был сгенерирован новый ключ с именем `id_rsa`.В файл `locals.tf` был добавлен код, использующий функцию file. Код ниже
```fileFunction
ssh_public_key = file(pathexpand("~/.ssh/id_rsa.pub"))

    metadata = {
    ssh-keys = "${var.vm_user}:${local.ssh_public_key}"
  }
```
переменная `vm_user` была прописана в файл `variables.tf`.\
Блок metadata прописан в файл `personal.auto.tfvars`
### Задание 2.5
#### Ответ
Были выполнены команды `terraform fmt`, `terraform plan` и `terraform apply`. После выполнения apply были созданы 4 ВМ по заданным параметрам. Вывод после apply:
```terraform apply
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```
Ниже скриншот yandex cloude console.\
![vminya](https://github.com/aliene92/netoLo/blob/main/terraform/hw-03/scr/ycc3ip.png)

**Объяснение 3х внешних ИП адресов, а не 4х**\
Сначала создавались ВМ с параметром NAT=false, после успешного создания всех ресурсов, переменная была изменена на true, и выполнен еще один terraform apply.\
Я слишком часто и много делал terraform apply и terraform destroy, попутно создавая и удаляя публичные ип адреса. Я был очень усерден и достиг предела.\
Как я выяснил у поддержки яндекса, в YC есть лимит под названием vpc.externalAddressesCreation.rate, по [ссылке](https://github.com/aliene92/netoLo/blob/main/terraform/hw-03/scr/3ip.png) скрин ошибки в консоле. Этот лимит никак не отображается в ЛК в лимитах. Дополнительно коллеги из поддержки пояснили, что со своей стороны так же не видят этот лимит, не могу посмотреть его значения и не знаю какой у него таймаут. Прикладываю [ссылку](https://github.com/aliene92/netoLo/blob/main/terraform/hw-03/scr/spansw.png) на скриншот ответа саппорта яндекса.
## Задание 3
### Задание 3.1
#### Ответ
Был создан файл с именем `disk_vm.tf`. В файле прописано создание 3х одинаковых виртуальных диска размером 1 ГБ с помощью ресурса yandex_compute_disk и мета-аргумента count.\
текст файла `disk_vm.tf` ниже
```disk_vm.tf
resource "yandex_compute_disk" "storage" {
  count = var.storage_disk_count

  name = "${var.storage_vm_name}-disk-${count.index + 1}"
  type = var.storage_disk_type
  zone = var.default_zone
  size = var.storage_disk_size
}
```
### Задание 3.2
#### Ответ
В файл было прописано создание ВМ storage

```storage
resource "yandex_compute_instance" "storage" {
  name        = var.storage_vm_name
  hostname    = var.storage_vm_name
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.storage_vm_resources.cpu
    memory        = var.storage_vm_resources.ram
    core_fraction = var.storage_vm_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.storage_vm_resources.disk_volume
      type     = var.storage_vm_resources.disk_type
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage

    content {
      disk_id     = secondary_disk.value.id
      auto_delete = true
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.metadata

  scheduling_policy {
    preemptible = true
  }
}
```
