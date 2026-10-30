# Домашнее задание к занятию «Запуск приложений в K8S»
Домашнее задание выполнено в тестовой среде на базе MicroK8s.

## Используемое окружение

- ОС: Ubuntu 24.04 LTS
- Kubernetes: MicroK8s 1.35.6
- Container Runtime: containerd 2.1.6
- Управление кластером: kubectl 1.35.6
- Сетевой плагин: Calico
- DNS: CoreDNS
- Узел Kubernetes: `k8s`
- IP-адрес узла: `153.51.115.124`

## Структура репозитория

```text
.
├── README.md
└── manifests
    ├── task1-deployment.yaml
    ├── task1-multitool-pod.yaml
    ├── task1-service.yaml
    ├── task2-deployment.yaml
    └── task2-service.yaml
 ```

# Задание 1. Deployment, состоящий из nginx и multitool

## Создание Deployment

Был создан Deployment с двумя контейнерами:

- `nginx`;
- `wbitt/network-multitool`.

Манифест:

[task1-deployment.yaml](./manifests/task1-deployment.yaml)

Изначально оба контейнера использовали TCP-порт `80`.

Контейнеры внутри одного Pod используют общее сетевое пространство имён и общий IP-адрес. Поэтому два приложения внутри одного Pod не могут одновременно прослушивать один и тот же TCP-порт.

После запуска Deployment контейнер nginx успешно занял порт `80`, а контейнер multitool завершился с ошибкой:

```text
bind() to 0.0.0.0:80 failed (98: Address in use)
nginx: [emerg] still could not bind()
```

Pod находился в состоянии:

```text
NAME                         READY   STATUS   RESTARTS
task1-app-5575dc5d9-l5fqh   1/2     Error    3
```

Скриншот ошибки:

![Конфликт портов nginx и multitool](./screenshots/scr1.png)

## Исправление конфликта портов

Для контейнера multitool были заданы переменные окружения:

```yaml
env:
  - name: HTTP_PORT
    value: "8080"
  - name: HTTPS_PORT
    value: "8443"
```

После изменения портов приложения внутри Pod используют:

- nginx — TCP-порт `80`;
- multitool HTTP — TCP-порт `8080`;
- multitool HTTPS — TCP-порт `8443`.

После применения исправленного манифеста Pod успешно запустился:

```text
NAME                        READY   STATUS    RESTARTS
task1-app-5575dc5d9-l5fqh   2/2     Running   0
```

Список прослушиваемых портов внутри Pod:

```text
LISTEN 0 511 0.0.0.0:8080
LISTEN 0 511 0.0.0.0:8443
LISTEN 0 511 0.0.0.0:80
```

Проверка nginx:

```text
HTTP/1.1 200 OK
Server: nginx/1.31.3
```

Проверка multitool:

```text
WBITT Network MultiTool (with NGINX) -
task1-app-5575dc5d9-l5fqh -
10.1.114.21 -
HTTP: 8080, HTTPS: 8443
```

Скриншот успешного запуска Pod после исправления конфликта портов:

![Исправление конфликта портов](./screenshots/scr2.png)

## Масштабирование Deployment
