# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»
## Задание 0
### Ответ
Я ознакомился с документацией к группам безопасности в яндекс облаке по [ссылке](https://yandex.cloud/ru/docs/vpc/concepts/security-groups?from=int-console-help-center-or-nav&utm_referrer=https%3A%2F%2Fgithub.com%2Fnetology-code%2Fter-homeworks%2Fblob%2Fmain%2F02%2Fhw-02.md)
## Задание 1
#### Задание 1.0
##### Ответ
Установлена старая версия терраформа, это видно на скриншоте ниже.
![terVer](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/terraformVer.png)
#### Задание 1.1 - 1.4
##### Ответ
Проект изучен.\
В YC создан сервисный аккаунт, для него получен файл с ключём.\
Сгенерирована пара SSH ключей.\
Была объявлена переменная для хранения пути к файлу с ключем с именем `vms_ssh_root_key` в файле `variables.tf`.\
В файл `personal.auto.tfvars` добавлены значения для переменных `cloud_id`, `folder_id`, `vms_ssh_root_key`, `service_account_key_file`.\
В файле `providers.tf` добавлено указание версии для провайдера от яндекса и поправлена переменная `service_account_key_file`.\
Было исправлено значение `platform_id` с `standart-v4`, такой не существует, на `standard-v1`.\
Было изменено кол-во ядер вм с 1 на 2. Сейчас в YC невозможно создать ВМ менее чем с 2-мя ядрами.
#### Задание 1.5
##### Ответ
На скриншоте ниже видно ЛК яндекс клауда и консоль терминала с выводом `curl ifconfig.me`.
![2ip](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/yaCl_ip.png)
#### Задание 1.6
##### Ответ
Параметр preemptible = true говорит нам о том, что будет создана прерываемая машина, параметр core_fraction=5 говорит о том, что нам будет доступно лишь 5% от процессорных мощностей арендуемых ядер. Оба этих параметра помогает в течении учебного процесса экономить средства. Так как ВМ с такими настройками стоят дешевле.
## Задание 2
#### Задание 2.1
##### Ответ
Все хардкодные значения ресурсов yandex_compute_image и yandex_compute_instance были заменены на переменные с именами vm_web_*. Ниже скриншот файла `variables.tf`
