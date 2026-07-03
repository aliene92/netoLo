# Домашнее задание к занятию 5. «Практическое применение Docker»

## Задача 0
### Ответ:
![Docer-compose не установлен. Docker compose установлен](https://github.com/aliene92/netoLo/blob/main/05-virt-docker-practic/screenShots/MarkovAM-t0.png)

## Задача 1
### Ответ:

[ссылка на мой реполиторий с форком](https://github.com/aliene92/shvirtd-example-python/tree/main) - https://github.com/aliene92/shvirtd-example-python/tree/main

---
текст файла 'Docerfile.python':
```dockerfile
FROM python:3.12-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

FROM python:3.12-slim AS runtime

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

COPY --from=builder /opt/venv /opt/venv
COPY . .

EXPOSE 5000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
```
---
скриеншот гитхаба:
![скриеншот гитхаба:](https://github.com/aliene92/netoLo/blob/main/05-virt-docker-practic/screenShots/MarkovAM-github-screen.png)

---
## Задача 3
### Ответ:
---
текст файла 'compose.yaml':
```compose.yaml
include:
  - proxy.yaml

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.python
    container_name: web
    restart: always
    depends_on:
      db:
        condition: service_healthy
    environment:
      DB_HOST: db
      DB_USER: ${MYSQL_USER}
      DB_PASSWORD: ${MYSQL_PASSWORD}
      DB_NAME: ${MYSQL_DATABASE}
    networks:
      backend:
        ipv4_address: 172.20.0.5

  db:
    image: mysql:8
    container_name: db
    restart: always
    env_file:
      - .env
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -uroot -p$${MYSQL_ROOT_PASSWORD} --silent"]
      interval: 10s
      timeout: 5s
      retries: 20
      start_period: 20s
    networks:
      backend:
        ipv4_address: 172.20.0.10
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```
---

Проект собирается командой и успешно выполняется. На скриншотах ниже виден процесс и вывод запроса к sql базе:
![сборка](https://github.com/aliene92/netoLo/blob/main/05-virt-docker-practic/screenShots/composeStart.png)
![вывод select](https://github.com/aliene92/netoLo/blob/main/05-virt-docker-practic/screenShots/sqlSelectResalt.png)

---

## Задача 4
### Ответ:
