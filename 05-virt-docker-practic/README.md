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
