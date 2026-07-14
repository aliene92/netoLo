# Домашнее задание "Введение в Terraform"
## Задание 1
### Ответ 1.1
На скриншоте ниже видно, что установлены докер и терраформ, а так же клонирован репозиторий с проектом
![установлены докер и терраформ,клонировано](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/scr1.png)
### Ответ 1.2
На скриншоте ниже представлен текст файла .gitignore, из текста файла следует, что допустимо сохранить личную, секретную информацию в файле **personal.auto.tfvars**
![гитигноръх](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/gitignr.png)
### Ответ 1.3
На скриншоте ниже видно выполнение кода проекта
![выполнение](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/runPrj.png)
для успешного запуска проекта необходимо было изменить требование к версии Terraform, прописанное в файле main.tf.

было
```было
required_version = "~>1.12.0"
```
стало
```стало
required_version = ">=1.12.0"
```
---

Анализ файла terraform.tfstate позволил определить, что секретный код имеет значение **vkG5GmmLBWm7xY1X** и находится по пути .resources[].instances[0].attributes.result. Скриншот ниже.
![secret](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/secret.png)
### Ответ 1.4
На скриншоте ниже видны ошибки после раскоментирования всего кода в файле main.tf и попытки его выполнения
![ошибки](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/errs.png)
Намеренно допущенные ошибки следующие
#### Ошибка 1
По условиям синтаксиса терраформ ресурс должен содержать тип и имя resource "<TYPE>" "<LOCAL_NAME>" {\
было:
```было
"resource "docker_image"
```
исправлено: 
```исправлено
resource "docker_image" "nginx"
```
#### Ошибка 2
Имя ресурса не может начинаться с числа\
было:
```было
resource "docker_container" "1nginx" {
```
исправлено: 
```исправлено
resource "docker_container" "nginx" {
```
#### Ошибка 3
Неверно указано имя типа и неверно указано имя атрибута, буква в верхнем регистре.\
было:
```было
name  = "example_${random_password.random_string_FAKE.resulT}"
```
исправлено: 
```исправлено
name  = "example_${random_password.random_string.result}"
```
Исправленный файл main.tf выложен по [ссылке](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/files/my_main.tf)



