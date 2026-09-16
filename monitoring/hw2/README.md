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
![scr1](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/tree.png)

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
