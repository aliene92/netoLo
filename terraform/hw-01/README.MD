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
По условиям синтаксиса терраформ ресурс должен содержать тип и имя ```resource "<TYPE>" "<LOCAL_NAME>" {```\
было:
```было
resource "docker_image"
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
### Ответ 1.5
Ниже скриншот запуска терраформ, текст файла main.tr и ссылка на него
![run](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/runterra.png)
текст файла
```maintr
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
  required_version = ">=1.12.0" /*Многострочный комментарий.
 Требуемая версия terraform */
}
provider "docker" {}

#однострочный комментарий

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}


resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 9090
  }
}

```
Ссылка на файл [main.tr](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/files/my_main.tf)
Ниже скриншот вывода команды docker ps
![dockerps](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/dockerps.png)
### Ответ 1.6
На скриншоте ниже видно выолнение terraform apply -auto-approve и docker ps. Имя контейнера теперь Hello_world. Для переименования была изменена строчка в файле main.tf\
было
```было
name  = "example_${random_password.random_string.result}"
```
стало
```стало
name  = "Hello_world"
```
![teranddocker](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/tfapplDckrPS.png)

**Опастность выполнения команды ```terraform apply``` с ключем  ```-auto-approve```:**
Главная проблема и опасность выполнения команды ```terraform apply``` с ключем  ```-auto-approve``` заключается в том, что изменения плана выполнеяются без ручной проверки и подтверждения.\ 
Автоматическое изменение плана может привести к:
1) Случайному удалению нужных ресурсов.
2) Случайному незапланированному изменению ресурсов
3) Падению продакшена
4) Простою сервисов
\
**Выполнения команды ```terraform apply``` с ключем  ```-auto-approve``` может быть оправданно в следующих случаях:**
1) Тестовая среда
2) Ситуации, когда скорость и автоматизация приоритетней стабильности и надежности
3) Ci/CD пайплайны
4) автоматическое развертывание временной инфраструктуры
### Ответ 1.7
На скриншоте ниже видно выполнение команты ```terraform destroy``` и ```docker ps```. По ссылке выложен файл [terraform.tfstate](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/files/terraform.tfstate). 
![destAndPS](https://github.com/aliene92/netoLo/blob/main/terraform/hw-01/scr/destrandps.png)
Текст файла terraform.tfstate:
``` {
  "version": 4,
  "terraform_version": "1.15.8",
  "serial": 25,
  "lineage": "0eae3b7b-413c-7165-5dee-955aaba3d344",
  "outputs": {},
  "resources": [],
  "check_results": null
} 
```

### Ответ 1.8

Docker-образ **nginx:latest** не был удален по причине наличия ключа 










