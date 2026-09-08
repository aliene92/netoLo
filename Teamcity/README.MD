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
## 3. Установка TeamCity Server

На сервере `tc-server` был подготовлен каталог для данных TeamCity:

```bash
mkdir -p /opt/teamcity/data
mkdir -p /opt/teamcity/logs

chown -R 1000:1000 /opt/teamcity
chmod -R u+rwX,g+rwX /opt/teamcity
```

TeamCity Server был запущен в Docker:

```bash
docker run -d \
  --name teamcity-server \
  --restart unless-stopped \
  -p 8111:8111 \
  -v /opt/teamcity/data:/data/teamcity_server/datadir \
  -v /opt/teamcity/logs:/opt/teamcity/logs \
  jetbrains/teamcity-server:latest
```

Проверка контейнера:

```bash
docker ps
docker logs --tail=150 teamcity-server
curl -I http://127.0.0.1:8111
```

TeamCity Server стал доступен по адресу:

```text
http://158.160.149.186:8111
```

В web-интерфейсе TeamCity была выполнена первоначальная настройка:

1. Принята лицензия.
2. Создан пользователь администратора.
3. Выполнен вход в web-интерфейс.
4. В настройках сервера указан корректный Server URL:

```text
http://158.160.149.186:8111
```

---

## 4. Разворачивание Nexus Repository
