# Домашнее задание к занятию 14 «Средство визуализации Grafana»
## Описание

В рамках домашнего задания был самостоятельно развёрнут стенд мониторинга на VM в yandex cloud без использования готовой директории `help`.

![scr1](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/vmya1.png)


Используемые компоненты:

- Grafana;
- Prometheus Server;
- Prometheus Node Exporter;
- Docker Compose;
- Ubuntu 24.04.

Prometheus используется как источник данных для Grafana. Node Exporter используется как сборщик системных метрик виртуальной машины.

---
## Параметры стенда

Виртуальная машина:

- Ubuntu 24.04
- IP-адрес: `81.26.176.118`;
- Grafana: `http://81.26.176.118:3000`;
- Prometheus: `http://81.26.176.118:9090`;
- Node Exporter: `http://81.26.176.118:9100/metrics`.

---

## Структура проекта

```text
.
├── dashboard
│   └── node-exporter-dashboard.json
├── docker-compose.yml
├── grafana
│   └── provisioning
│       └── datasources
│           └── prometheus.yml
├── prometheus
│   └── prometheus.yml
├── .gitignore
└── README.md
````
![scr2](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/tree.png)

## Конфигурация Docker Compose

Файл: `docker-compose.yml`

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus-server
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"

  node-exporter:
    image: prom/node-exporter:latest
    container_name: prometheus-node-exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    pid: host
    volumes:
      - /:/host:ro,rslave
    command:
      - "--path.rootfs=/host"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin

      GF_SERVER_ROOT_URL: "http://81.26.176.118:3000/"

      GF_SMTP_ENABLED: "true"
      GF_SMTP_HOST: "smtp.yandex.ru:465"
      GF_SMTP_USER: "${GRAFANA_SMTP_USER}"
      GF_SMTP_PASSWORD: "${GRAFANA_SMTP_PASSWORD}"
      GF_SMTP_FROM_ADDRESS: "${GRAFANA_SMTP_FROM}"
      GF_SMTP_FROM_NAME: "Grafana Alerting"
      GF_SMTP_SKIP_VERIFY: "false"
      GF_SMTP_EHLO_IDENTITY: "grafana-lab"

    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:
```
SMTP-параметры вынесены в файл `.env`, который не добавляется в репозиторий.

Пример `.env`:

```env
GRAFANA_SMTP_USER=aliene-9-2@yandex.ru
GRAFANA_SMTP_PASSWORD=APP_PASSWORD
GRAFANA_SMTP_FROM=aliene-9-2@yandex.ru
```

Файл `.gitignore`:

```gitignore
.env
*.log
```

---

## Конфигурация Prometheus

Файл: `prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets:
          - prometheus:9090

  - job_name: node-exporter
    static_configs:
      - targets:
          - node-exporter:9100
```

---

## Конфигурация Grafana Datasource

Файл: `grafana/provisioning/datasources/prometheus.yml`

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

---

## Запуск стенда

```bash
docker compose up -d
```

Проверка контейнеров:

```bash
docker compose ps
```

Результат:

```text
NAME                       IMAGE                       STATUS          PORTS
grafana                    grafana/grafana:latest      Up              0.0.0.0:3000->3000/tcp
prometheus-node-exporter   prom/node-exporter:latest   Up              0.0.0.0:9100->9100/tcp
prometheus-server          prom/prometheus:latest      Up              0.0.0.0:9090->9090/tcp
```
![scr3](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/dcup.png)

Проверка доступности сервисов:

```bash
curl -s -o /dev/null -w "Grafana: %{http_code}\n" http://127.0.0.1:3000/login
curl -s -o /dev/null -w "Prometheus: %{http_code}\n" http://127.0.0.1:9090/
curl -s -o /dev/null -w "Node Exporter: %{http_code}\n" http://127.0.0.1:9100/metrics
```

Результат:

```text
Grafana: 200
Prometheus: 302
Node Exporter: 200
```
![scr4](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/srvsup.png)

Проверка targets в Prometheus:

```bash
curl -s http://127.0.0.1:9090/api/v1/targets | grep -E '"health"|"job"|"scrapeUrl"'
```
![scr5](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/text.png)

Prometheus успешно обнаружил targets:

* `prometheus`;
* `node-exporter`.

Оба target находятся в состоянии `UP`.

---

# Задание 1

Grafana была развёрнута самостоятельно. В качестве источника данных был подключён Prometheus.

Prometheus подключён через provisioning-файл:

```text
grafana/provisioning/datasources/prometheus.yml
```

![scr6](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/promcon.png)

---

# Задание 2

Был создан Dashboard:

```text
Node Exporter Monitoring
```

Dashboard содержит панели:

* CPU utilization, %;
* Load Average 1/5/15;
* Free RAM, %;
* Free disk space, %.

![scr7](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/dashb.png)

## PromQL-запросы

### CPU utilization, %

```promql
100 * (1 - avg by(instance) (rate(node_cpu_seconds_total{job="node-exporter",mode="idle"}[5m])))
```

### Load Average 1/5/15

```promql
node_load1{job="node-exporter"}
```

```promql
node_load5{job="node-exporter"}
```

```promql
node_load15{job="node-exporter"}
```

### Free RAM, %

```promql
100 * node_memory_MemAvailable_bytes{job="node-exporter"} / node_memory_MemTotal_bytes{job="node-exporter"}
```

### Free disk space, %

```promql
100 * node_filesystem_avail_bytes{job="node-exporter",mountpoint="/",fstype!~"tmpfs|overlay|squashfs|proc|sysfs|devtmpfs"} / node_filesystem_size_bytes{job="node-exporter",mountpoint="/",fstype!~"tmpfs|overlay|squashfs|proc|sysfs|devtmpfs"}
```

---

# Задание 3

Для Dashboard были созданы alert rules:

* High CPU usage;
* High Load Average;
* Low free RAM;
* Low disk space.

Также был создан тестовый alert `Alerts` для проверки доставки уведомлений.

![scr8](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/testalert.png)


## Alert rules

### High CPU usage

```promql
100 * (1 - avg by(instance) (rate(node_cpu_seconds_total{job="node-exporter",mode="idle"}[5m])))
```

Условие:

```text
IS ABOVE 80
```

Описание:

```text
CPU usage is higher than 80%
```

### High Load Average

```promql
node_load1{job="node-exporter"}
```

Условие:

```text
IS ABOVE 2
```

Описание:

```text
Load average is higher than 2
```

### Low free RAM

```promql
100 * node_memory_MemAvailable_bytes{job="node-exporter"} / node_memory_MemTotal_bytes{job="node-exporter"}
```

Условие:

```text
IS BELOW 20
```

Описание:

```text
Free RAM is lower than 20%
```

### Low disk space

```promql
100 * node_filesystem_avail_bytes{job="node-exporter",mountpoint="/",fstype!~"tmpfs|overlay|squashfs|proc|sysfs|devtmpfs"} / node_filesystem_size_bytes{job="node-exporter",mountpoint="/",fstype!~"tmpfs|overlay|squashfs|proc|sysfs|devtmpfs"}
```

Условие:

```text
IS BELOW 20
```

Описание:

```text
Free disk space is lower than 20%
```

## Канал уведомлений
