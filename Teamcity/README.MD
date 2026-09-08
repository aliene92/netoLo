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

Основные параметры проекта:

```xml
<groupId>org.netology</groupId>
<artifactId>plaindoll</artifactId>
<packaging>jar</packaging>
<version>0.0.2-SNAPSHOT</version>
```

Для публикации snapshot-артефактов был настроен Nexus:

```xml
<distributionManagement>
    <snapshotRepository>
        <id>nexus-snapshots</id>
        <url>http://158.160.142.210:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

Также в проекте используется `maven-shade-plugin`, поэтому в результате сборки формируются два `.jar`-файла:

```text
original-plaindoll-0.0.2-SNAPSHOT.jar
plaindoll-0.0.2-SNAPSHOT.jar
```

---

## 8. Настройка Maven `settings.xml` в TeamCity

Для выполнения команды:

```bash
mvn clean deploy
```

TeamCity должен иметь доступ к Nexus.

Для этого был подготовлен Maven `settings.xml` с данными подключения к Nexus.

Пример структуры файла:

```xml
<settings>
    <servers>
        <server>
            <id>nexus-snapshots</id>
            <username>teamcity</username>
            <password>********</password>
        </server>
    </servers>
</settings>
```

Пароль в репозиторий не добавлялся.

Файл был загружен в TeamCity:

```text
Project Settings → Maven Settings → Upload settings file
```

После загрузки в build steps был выбран:

```text
User settings selection: settings.xml
```

---

## 9. Создание проекта в TeamCity

В TeamCity был создан проект:

```text
example-teamcity
```

Проект был создан на основе GitHub-репозитория:

```text
https://github.com/aliene92/example-teamcity.git
```

Параметры VCS Root:

```text
Type of VCS: Git
Fetch URL: https://github.com/aliene92/example-teamcity.git
Default branch: refs/heads/master
Branch specification: +:refs/heads/*
Authentication method: Password / personal access token
Username: aliene92
```

Для доступа к GitHub использовался Personal Access Token. Сам токен в репозиторий не сохранялся.

---

## 10. Autodetect Maven build step

После подключения репозитория TeamCity автоматически определил Maven-проект и предложил Maven build step.

Autodetect обнаружил:

```text
Path to POM: pom.xml
Goals: clean test
```

Первоначальный Maven step был сохранён и затем изменён в соответствии с условиями задания.

---
## 11. Настройка условий сборки

По заданию требовалось:

```text
master → mvn clean deploy
остальные ветки → mvn clean test
```

Для этого в build configuration были настроены два Maven build step.

### Step 1 — Maven clean test

```text
Step name: Maven clean test
Runner: Maven
Goals: clean test
Path to POM file: pom.xml
User settings selection: settings.xml
```

Условие выполнения:

```text
teamcity.build.branch.is_default equals false
```

Это означает, что шаг выполняется только в ветках, отличных от default branch.

Например:

```text
feature/add_reply → mvn clean test
```

### Step 2 — Maven clean deploy

```text
Step name: Maven clean deploy
Runner: Maven
Goals: clean deploy
Path to POM file: pom.xml
User settings selection: settings.xml
```

Условие выполнения:

```text
teamcity.build.branch.is_default equals true
```

Это означает, что шаг выполняется только в default branch, то есть в `master`.

Например:

```text
master → mvn clean deploy
```

Итоговая логика:

| Ветка               | Выполняемый шаг    |
| ------------------- | ------------------ |
| `master`            | `mvn clean deploy` |
| `feature/add_reply` | `mvn clean test`   |

![scr6](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/mavenset.png)
---
## 12. Проверка сборки master и публикации в Nexus

После настройки build steps была запущена сборка ветки `master`.

Для `master` сработала следующая логика:

```text
Maven clean test — skipped
Maven clean deploy — executed
```

Сборка завершилась успешно:

```text
BUILD SUCCESS
```

![scr7](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/cleandeploy.png)
Артефакт был опубликован в Nexus:

```text
maven-snapshots/org/netology/plaindoll/0.0.2-SNAPSHOT/
```

![scr8](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/nexusart.png)

---

## 13. Миграция build configuration в репозиторий

Для выполнения пункта задания:

```text
Мигрируйте build configuration в репозиторий.
```

В TeamCity были включены Versioned Settings.

Раздел:

```text
Project Settings → Versioned Settings
```

Параметры:

```text
Synchronization enabled
Settings format: Kotlin
Settings path in VCS: .teamcity
Allow editing project settings via UI: enabled
Store passwords and API tokens outside of VCS: enabled
When build starts: always use current settings
```

После включения Versioned Settings TeamCity закоммитил конфигурацию в GitHub.

В репозитории появился каталог:

```text
.teamcity/
```
![scr9](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/tctogh1.png)
Таким образом, конфигурация TeamCity была мигрирована в репозиторий в формате Kotlin DSL.

После изменения настроек build configuration, в том числе artifact rules, TeamCity также обновил `.teamcity/` в репозитории.

---

## 14. Создание ветки `feature/add_reply`

В GitHub была создана отдельная ветка:

```text
feature/add_reply
```
![scr10](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/ghfar.png)
Ветка была создана от `master`.

---

## 15. Добавление нового метода в `Welcomer`

В файл:

```text
src/main/java/plaindoll/Welcomer.java
```

был добавлен новый метод:

```java
public String sayReply() {
    return "hunter biden vash prezident.";
}
```

Метод возвращает строку, содержащую слово:

```text
hunter
```

Это соответствует условию задания.

---

## 16. Добавление теста для нового метода

В файл:

```text
src/test/java/plaindoll/WelcomerTest.java
```

был добавлен новый тест:

```java
@Test
public void welcomerSaysReplyWithHunter() {
    assertThat(welcomer.sayReply(), containsString("hunter"));
}
```

После добавления теста общее количество тестов стало:

```text
6
```
![scr11](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/test6.png)
---

## 17. Проверка автоматической сборки feature-ветки

После push изменений в ветку:

```text
feature/add_reply
```

TeamCity автоматически запустил сборку этой ветки.

Ожидаемое поведение для feature-ветки:

```text
Maven clean test — executed
Maven clean deploy — skipped
```

Сборка feature-ветки завершилась успешно:

```text
Tests passed: 6
```
![scr12](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/bldftr.png)
Это подтвердило, что условие для не-default веток работает корректно.

---

## 18. Merge `feature/add_reply` в `master`

После успешной сборки feature-ветки был создан Pull Request:

```text
feature/add_reply → master
```

Pull Request:

```text
Add hunter reply
```

PR был успешно смержен в `master`.

После merge TeamCity автоматически запустил новую сборку ветки `master`.

Сборка `master` после merge прошла успешно:

```text
Tests passed: 6
```
![scr13](https://github.com/aliene92/netoLo/blob/main/Teamcity/scr/master6.png)
Для `master` снова отработала логика:

```text
Maven clean test — skipped
Maven clean deploy — executed
```

---

## 19. Проверка отсутствия `.jar` в TeamCity Artifacts до настройки artifact rules

После сборки `master` была проверена вкладка:

```text
Build → Artifacts
```

На этом этапе `.jar`-файл ещё не публиковался в TeamCity Artifacts, так как artifact rules ещё не были настроены.

Это соответствует пункту задания:

```text
Убедитесь, что нет собранного артефакта в сборке по ветке master.
```

---

## 20. Настройка публикации `.jar` в TeamCity Artifacts

