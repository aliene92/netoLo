# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»

## Задача 1
### Ответ:

 - [Ссылка](https://hub.docker.com/repository/docker/aliene92/custom-nginx/general) на докер хаб: https://hub.docker.com/repository/docker/aliene92/custom-nginx/general

## Задача 2
### Ответ:

 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t2/MarkovAM-t2.png) на скриншот: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t2/MarkovAM-t2.png

## Задача 3
### Ответ:
#### t3.3
Для подключения к стандартному потоку ввода/вывода/ошибок контейнера используется команда docker attach. Docker attach присоединяется к уже запущенному ключевому процессу контейнера. Если отправить ключевому процессу контейнера Ctrl-C, он воспримет это как SIGKILL, что приведет к немедленной остановки контейнера.
#### t3.10
Суть возникшей проблемы в том, что мы перенастроили порт на котором крутится веб сервер с 80 на 81 в самом веб сервере, nginx, тогда как в нашем контейнере настроен мэппинг внутреннего порта 80 на внешний порт хостовой машины. наш контейнер и хостовая система не знают о том, что настройки веб сервера поменялись, поэтому мы не получаем никакой информации от файла index.html
#### Скриншоты
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/01_MarkovAM-t3.png) на скриншот 1: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/01_MarkovAM-t3.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/02_MarkovAM-t3.png) на скриншот 2: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/02_MarkovAM-t3.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/03_MarkovAM-t3.png) на скриншот 3: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/03_MarkovAM-t3.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/04_nginxConfig-MarkovAM-t3.png) на скриншот 4: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/04_nginxConfig-MarkovAM-t3.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/05_MarkovAM-t3.png) на скриншот 5: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/05_MarkovAM-t3.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/config_v2.png) на скриншот 6: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/config_v2.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/hostconfig.png) на скриншот 7: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t3/hostconfig.png

## Задача 4

 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t4/MarkovAM-t4.png) на скриншот: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t4/MarkovAM-t4.png

## Задача 5

#### t5.1
Будет запущен файл compose.yaml, в случае если в рабочей директории представлены файлы и compose.yaml и docker-compose.yaml без дополнительных указаний докер предпочтет запустить compose.yaml так устроен докер.
#### t5.7
Суть предупреждения в следующем, докер нашел контейнер не описанный в файлах копоуза, и предлагает выполнить команду с ключом --remove-orphans, что бы удалить его.

#### Скриншоты
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/01_MarkovAM-t5.png) на скриншот 1: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/01_MarkovAM-t5.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/02_MarkovAM-t5.png) на скриншот 2: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/02_MarkovAM-t5.png
 - [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/03_MarkovAM-t5-portainer.png) на скриншот portainer: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/03_MarkovAM-t5-portainer.png
- [Ссылка](https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/MarkovAM-compose.yaml) на compose.yaml: https://github.com/aliene92/netoLo/blob/01-ModulVirt-Docer-Compose/05-virt-docker/t5/MarkovAM-compose.yaml
