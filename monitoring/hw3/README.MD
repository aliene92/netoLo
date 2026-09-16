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

Контейнеры:

- `elasticsearch-hot`;
- `elasticsearch-warm`;
- `logstash`;
- `kibana`;
- `filebeat`.

## Проверка Elasticsearch

Проверка состояния кластера:

```bash
curl -s http://127.0.0.1:9200/_cluster/health?pretty
```

![scr3](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/ElasticsearchHealth.png)


Результат:

```json
{
  "cluster_name" : "netology-elk",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 2,
  "number_of_data_nodes" : 2,
  "active_primary_shards" : 9,
  "active_shards" : 9,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 1,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 90.0
}

```

Статус `yellow` связан с тем, что для пользовательских индексов настроена одна реплика, которая не размещается в текущей учебной hot/warm-схеме. На работу стека это не влияет: индексы создаются, документы записываются и доступны для поиска.

Проверка нод:

```bash
curl -s http://127.0.0.1:9200/_cat/nodes?v
```

![scr4](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/Elasticsearchnode.png)


Результат:

```text
ip         heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
172.18.0.3           20          97  11    0.05    0.33     0.92 hims      *      elasticsearch-hot
172.18.0.2           52          97  11    0.05    0.33     0.92 imw       -      elasticsearch-warm
```

Проверка индексов:

```bash
curl -s http://127.0.0.1:9200/_cat/indices?v
```

![scr5](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/indices.png)


Результат:

```text
health status index                            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases                 xI1EcoKvT-GTH4E307_P5w   1   0         43            0     39.7mb         39.7mb
green  open   .kibana_task_manager_7.17.28_001 GrFwdIwtQDa_k5nBTV-SdA   1   0         17         2328      297kb          297kb
green  open   .kibana_7.17.28_001              ltSckXc7StWBALAwVO5XKg   1   0         15            0      2.3mb          2.3mb
green  open   .apm-custom-link                 FU14xy-BS1KHJQ4D6A98Rg   1   0          0            0       227b           227b
green  open   .apm-agent-configuration         f4cenytkSP-M2mZhYK-FQw   1   0          0            0       227b           227b
yellow open   tcp-json-2026.09.16              cDQNsHZpQgGxa9bVBJcLCg   1   1          1            0      8.8kb          8.8kb
yellow open   logstash-2026.09.16              nm3P4E_4QLKxyF1-MfJU0A   1   1        553            0    903.5kb        903.5kb

```

В результате были созданы пользовательские индексы:

- `logstash-2026.09.16`;
- `tcp-json-2026.09.16`.

## Проверка TCP JSON input в Logstash

Logstash настроен на приём JSON-сообщений по TCP на порту `5000`.

Тестовое сообщение:

```bash
TEST_ID="tcp-json-test-$(date +%s)"

printf '{"message":"%s","level":"info","service":"tcp-test","homework":"netology-elk","source":"manual-tcp"}' "$TEST_ID" | nc -w 5 127.0.0.1 5000
```

Проверка поиска события в Elasticsearch:

```bash
curl -s "http://127.0.0.1:9200/tcp-json-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 5,
    "_source": [
      "@timestamp",
      "message",
      "level",
      "service",
      "homework",
      "source",
      "tags"
    ],
    "query": {
      "match_phrase": {
        "homework": "netology-elk"
      }
    }
  }'
```

Результат:

```json
{
  "took" : 30,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 0.5753642,
    "hits" : [
      {
        "_index" : "tcp-json-2026.09.16",
        "_type" : "_doc",
        "_id" : "rQPSqqAB7IaXZauSghIR",
        "_score" : 0.5753642,
        "_source" : {
          "@timestamp" : "2026-09-16T15:25:17.293Z",
          "homework" : "netology-elk",
          "level" : "info",
          "service" : "tcp-test",
          "source" : "manual-tcp",
          "message" : "tcp-json-test-1789572234",
          "tags" : [
            "tcp-json"
          ]
        }
      }
    ]
  }
}
```
![scr6](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/search.png)

## Проверка Filebeat

Filebeat собирает Docker-логи с хоста из каталога:

```text
/var/lib/docker/containers/*/*.log
```

и отправляет их в Logstash на порт `5044`.

После запуска Filebeat в Elasticsearch появился индекс:

```text
logstash-2026.09.16
```

Проверка:

```bash
curl -s http://127.0.0.1:9200/_cat/indices?v
```

Фрагмент результата:

```text
yellow open   logstash-2026.09.16              nm3P4E_4QLKxyF1-MfJU0A   1   1        604            0      1.2mb          1.2mb
```

## Kibana

Kibana доступна по адресу:

```text
http://158.160.201.22:5601
```

![scr8](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/indexpatern.png)


В Kibana были созданы два index pattern / data view:

```text
logstash-*
tcp-json-*
```

Для обоих index pattern выбрано поле времени:

```text
@timestamp
```
![scr9](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/logstash.png)
![scr10](https://github.com/aliene92/netoLo/blob/main/monitoring/hw3/scr/tcpJson.png)


В разделе Discover проверен просмотр логов:

- `logstash-*` — Docker-логи, собранные Filebeat;
- `tcp-json-*` — JSON-события, отправленные в Logstash по TCP.

## Конфигурация Logstash
