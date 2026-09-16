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

## Запуск стека

```bash
docker compose pull
docker compose up -d
```

## Проверка контейнеров

Через несколько минут после старта были запущены 5 контейнеров:

```bash
docker ps
```

Результат:

```text
NAME                 IMAGE                                                   COMMAND                  SERVICE              CREATED          STATUS          PORTS
elasticsearch-hot    docker.elastic.co/elasticsearch/elasticsearch:7.17.28   "/bin/tini -- /usr/l…"   elasticsearch-hot    14 seconds ago   Up 12 seconds   0.0.0.0:9200->9200/tcp, [::]:9200->9200/tcp, 9300/tcp
elasticsearch-warm   docker.elastic.co/elasticsearch/elasticsearch:7.17.28   "/bin/tini -- /usr/l…"   elasticsearch-warm   14 seconds ago   Up 13 seconds   9200/tcp, 9300/tcp
filebeat             docker.elastic.co/beats/filebeat:7.17.28                "/usr/bin/tini -- /u…"   filebeat             14 seconds ago   Up 11 seconds   
kibana               docker.elastic.co/kibana/kibana:7.17.28                 "/bin/tini -- /usr/l…"   kibana               14 seconds ago   Up 11 seconds   0.0.0.0:5601->5601/tcp, [::]:5601->5601/tcp
logstash             docker.elastic.co/logstash/logstash:7.17.28             "/usr/local/bin/dock…"   logstash             14 seconds ago   Up 12 seconds   0.0.0.0:5000->5000/tcp, [::]:5000->5000/tcp, 0.0.0.0:5044->5044/tcp, [::]:5044->5044/tcp, 9600/tcp
```
![scr3](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/dockerup.png)
