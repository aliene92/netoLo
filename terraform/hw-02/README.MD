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
