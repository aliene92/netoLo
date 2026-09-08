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
В яндекс клауд были созданы 3 виртуальные машины с заданными параметрами и названиями tc-server (158.160.149.186), tc-agent (158.160.169.6), nexus (158.160.142.210).
![scr1](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/yaClVMs1.png)

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
![scr2](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/tcSrv.png)
---

## 4. Установка Nexus Repository
На сервере `nexus` был подготовлен каталог для данных Nexus:

```bash
mkdir -p /opt/nexus-data
chown -R 200:200 /opt/nexus-data
```

Nexus был запущен в Docker:

```bash
docker run -d \
  --name nexus \
  --restart unless-stopped \
  -p 8081:8081 \
  -v /opt/nexus-data:/nexus-data \
  sonatype/nexus3:latest
```

Проверка контейнера:

```bash
docker ps
docker logs --tail=100 nexus
```

Nexus стал доступен по адресу:

```text
http://158.160.142.210:8081
```

Первичная авторизация выполнялась под пользователем `admin`. Начальный пароль был получен из файла внутри контейнера/volume Nexus:

```bash
cat /opt/nexus-data/admin.password
```

В Nexus использовались стандартные Maven-репозитории:

```text
maven-releases
maven-snapshots
maven-public
```
![scr25](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/nexus1.png)
Для публикации snapshot-артефактов использовался репозиторий:

```text
http://158.160.142.210:8081/repository/maven-snapshots/
```

Для TeamCity был создан пользователь Nexus, предназначенный для публикации Maven-артефактов. Данные этого пользователя были добавлены в Maven `settings.xml`, который затем был загружен в TeamCity.
 
---
## 5. Установка TeamCity Agent

На сервере `tc-agent` был подготовлен каталог для агента:

```bash
mkdir -p /opt/teamcity-agent/conf
mkdir -p /opt/teamcity-agent/work
mkdir -p /opt/teamcity-agent/temp
mkdir -p /opt/teamcity-agent/system

chown -R 1000:1000 /opt/teamcity-agent
chmod -R u+rwX,g+rwX /opt/teamcity-agent
```

Так как в стандартном образе TeamCity Agent отсутствовал Maven, был подготовлен собственный Docker-образ агента с Maven и JDK.

Каталог для Dockerfile:

```bash
mkdir -p /opt/teamcity-agent-image
cd /opt/teamcity-agent-image
```

Dockerfile:

```Dockerfile
FROM jetbrains/teamcity-agent:latest

USER root

RUN apt-get update && \
    apt-get install -y maven openjdk-17-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER buildagent
```

Сборка образа:

```bash
docker build -t local/teamcity-agent-maven:latest .
```

Запуск агента:

```bash
docker run -d \
  --name teamcity-agent \
  --restart unless-stopped \
  -e SERVER_URL="http://158.160.149.186:8111" \
  -v /opt/teamcity-agent/conf:/data/teamcity_agent/conf \
  -v /opt/teamcity-agent/work:/opt/buildagent/work \
  -v /opt/teamcity-agent/temp:/opt/buildagent/temp \
  -v /opt/teamcity-agent/system:/opt/buildagent/system \
  local/teamcity-agent-maven:latest
```

Проверка установленного ПО внутри контейнера агента:

```bash
docker exec -it teamcity-agent bash -lc '
java -version
git --version
mvn -version
'
```

На агенте были доступны:

```text
Java
Git
Maven
```

После запуска агент появился в TeamCity в разделе:

```text
Agents → Unauthorized
```
![scr3](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/agent.png)
Агент был авторизован через web-интерфейс TeamCity:

```text
Agents → Unauthorized → tc-agent → Authorize
```

После авторизации агент появился в пуле `Default` со статусом `Idle`.
![scr4](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/agentAuthed.png)
## 6. GitHub-репозиторий

Был создан fork исходного репозитория:

```text
https://github.com/aragastmatb/example-teamcity
```

Fork-репозиторий:

```text
https://github.com/aliene92/example-teamcity
```

В дальнейшем TeamCity был настроен на работу именно с fork-репозиторием:

```text
https://github.com/aliene92/example-teamcity.git
```

---
## 7. Настройка `pom.xml`

В `pom.xml` были настроены параметры Maven-проекта и публикация артефактов в Nexus.
