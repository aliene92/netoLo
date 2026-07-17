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
Все хардкодные значения ресурсов yandex_compute_image и yandex_compute_instance были заменены на переменные с именами vm_web_*. Ниже скриншот файла `main.tf` после замены
![vars_in_main](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/mnWththc.png)
#### Задание 2.2
##### Ответ
В файле `variables.tf` объявлены новые переменные, прописан их тип и значение по умолчанию. Ниже скриншот файла `variables.tf` с новыми переменными. значение части переменных вынесены в файл `personal.auto.tfvars`
![new_vars_in_variable](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/newVars.png)
К этому моменту я исчерпал лимит на создание новых внешних ИП адресов в яндекс клауде, поэтому пришлось выставить значение переменной `vm_web_nat = false`
#### Задание 2.2
##### Ответ
Ниже скриншот выполнение команды `terraform plan`. Изменений не произошло.
![trPlan](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/trPln.png)
## Задание 3
#### Задание 3.1
##### Ответ
Был создан файл 'vms_platform.tf'. В него перенесены переменные относящиея к первой ВМ. В файле `variables.tf` эти переменные были закоменчены.
#### Задание 3.2
##### Ответ
В файле были объявлены новые переменные для ВМ с именем netology-develop-platform-db. Значения по умолчанию установлены согласно заданию.
#### Задание 3.3
##### Ответ
Изменения были применены командой terraform apply.
По ссылкам находятся файлы [main.tf](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/files/main.tf), [vms_platform.tf](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/files/vms_platform.tf) и [variables.tf](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/files/variables.tf), **актуальные на момент выполнения задания №3**.
## Задание 4
#### Задание 4.1
##### Ответ
В файле `outputs.tf` объявлен один output, содержащий: instance_name, external_ip, fqdn для каждой из ВМ. Ниже текст outputа.
```output
output "vms_net_info" {
  value = {

    web = {
      instance_name = yandex_compute_instance.platform.name
      external_ip   = yandex_compute_instance.platform.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.platform.fqdn
    }
    db = {
      instance_name = yandex_compute_instance.platform-db.name
      external_ip   = yandex_compute_instance.platform-db.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.platform-db.fqdn
    }
  }
}
```
#### Задание 4.2
##### Ответ
Изменения применены. Ниже скриншот вывода `terraform output`
![output](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/output.png)
## Задание 5
#### Задание 5.1
##### Ответ
В файле `locals.tf` были объявлены локальные переменные `vm_web_local_name` и `vm_db_local_name`. Для сохранения имен ВМ в изначальном виде и выполнения условия задания были объявлены переменные `vm_web_name_pref`, `vm_web_name_suf`, `vm_db_name_pref` и `vm_db_name_suf`. Для новых переменных прописан тип и значение по умолчанию. Текс файла `locals.tf` на скриншоте ниже
![localsVars](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/localVars.png)
#### Задание 5.2
##### Ответ
Были заменены переменные внутри ресурсов ВМ в файле `main.tf`. Скриншот ниже
![localsVarsInRess](https://github.com/aliene92/netoLo/blob/main/terraform/hw-02/scr/lcVarInRes.png)
#### Задание 5.3
##### Ответ
Изменения успешно применены. 
## Задание 6
#### Задание 6.1
##### Ответ

