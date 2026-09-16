# Домашнее задание к занятию 15 «Система сбора логов Elastic Stack»

## Описание

В рамках домашнего задания был развёрнут на ВМ в яндекс клауд Elastic Stack в Docker Compose без использования директории `help`.

![scr1](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/vminf.png)


Состав стека:

- Elasticsearch hot node;
- Elasticsearch warm node;
- Logstash;
- Kibana;
- Filebeat.

Filebeat собирает Docker-логи с хоста и отправляет их в Logstash.
Logstash принимает события от Filebeat по Beats input на порту `5044`.
Также Logstash настроен на приём JSON-сообщений по TCP на порту `5000`.

Для удобства проверки используются два индекса:

- `logstash-*` — Docker-логи, собранные Filebeat;
- `tcp-json-*` — ручные JSON-события, отправленные в Logstash по TCP.

## Структура проекта

```text
.
├── docker-compose.yml
├── filebeat
│   └── filebeat.yml
└── logstash
    └── pipeline
        └── logstash.conf
```

![scr2](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/tree.png)
