# Домашнее задание к занятию 14 «Средство визуализации Grafana»
## Описание

В рамках домашнего задания был самостоятельно развёрнут стенд мониторинга на VM в yandex cloud без использования готовой директории `help`.

![scr1](https://github.com/aliene92/netoLo/blob/main/monitoring/hw2/scr/vmya.png)


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
- IP-адрес: `51.250.41.54`;
- Grafana: `http://51.250.41.54:3000`;
- Prometheus: `http://51.250.41.54:9090`;
- Node Exporter: `http://51.250.41.54:9100/metrics`.

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
<img width="1641" height="720" alt="image" src="https://github.com/user-attachments/assets/91ed1e39-098b-460c-9734-ea70cf508b56" />
