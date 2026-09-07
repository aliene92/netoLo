# Домашнее задание к занятию 11 «TeamCity»
## Репозиторий

Репозиторий с выполненным заданием:

```text
https://github.com/aliene92/teamcity
```

В репозитории присутствуют:

```text
src/
pom.xml
.teamcity/
```

Каталог `.teamcity/` содержит мигрированную конфигурацию TeamCity в формате Kotlin DSL.
## Подготовка к выполнению
В яндекс клауд были созданы 3 виртуальные машины с заданными параметрами и названиями tc-server (158.160.149.186), tc-agent (158.160.183.70), nexus (158.160.142.210).
![scr1](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/yaClVMs.png)

На всех виртуальных машинах была установлена Ubuntu Server 24.04.

Установлены базовые утилиты:

```bash
apt update
apt install -y curl wget git vim htop net-tools ca-certificates gnupg lsb-release
```

На всех трёх виртуальных машинах был установлен Docker и Docker Compose.

Проверка Docker:

```bash
docker --version
docker compose version
systemctl is-active docker
```

---
