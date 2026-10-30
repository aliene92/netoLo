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
task1-app-fb85f46b5-xj8r8   2/2     Running   0
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
task1-app-fb85f46b5-xj8r8 -
10.1.114.21 -
HTTP: 8080, HTTPS: 8443
```

Скриншот успешного запуска Pod после исправления конфликта портов:

![Исправление конфликта портов](./screenshots/scr2.png)

## Масштабирование Deployment

До масштабирования Deployment содержал одну реплику:

```text
NAME        READY   UP-TO-DATE   AVAILABLE
task1-app   1/1     1            1
```

Количество реплик было увеличено командой:

```bash
kubectl scale deployment task1-app --replicas=2
```

После масштабирования Deployment содержит две доступные реплики:

```text
NAME        READY   UP-TO-DATE   AVAILABLE
task1-app   2/2     2            2
```

Запущенные Pod:

```text
NAME                        READY   STATUS    RESTARTS   IP
task1-app-fb85f46b5-ngtfb   2/2     Running   0          10.1.114.24
task1-app-fb85f46b5-xj8r8   2/2     Running   0          10.1.114.23
```

Скриншот состояния до и после масштабирования:

![Масштабирование Deployment](./screenshots/scr3.png)

## Создание Service

Для доступа к репликам Deployment был создан Service типа `ClusterIP`.

Манифест:

[task1-service.yaml](./manifests/task1-service.yaml)

Service предоставляет два порта:

| Имя порта | Порт Service | TargetPort | Назначение |
|---|---:|---|---|
| nginx-http | 80 | nginx-http | nginx |
| multitool-http | 8080 | multitool-http | multitool |

Состояние Service:

```text
NAME            TYPE        CLUSTER-IP      PORT(S)
task1-service   ClusterIP   10.152.183.47   80/TCP,8080/TCP
```

EndpointSlice содержит IP-адреса обеих реплик:

```text
NAME                  ADDRESSES
task1-service-ls6t4   [10.1.114.23],[10.1.114.24]
```

## Создание отдельного Pod с multitool

Для проверки сетевого доступа был создан отдельный Pod `task1-client`.

Манифест:

[task1-multitool-pod.yaml](./manifests/task1-multitool-pod.yaml)

Состояние Pod:

```text
NAME           READY   STATUS    RESTARTS   IP
task1-client   1/1     Running   0          10.1.77.6
```

Внутреннее DNS-имя Service успешно разрешается:

```text
Name:    task1-service.default.svc.cluster.local
Address: 10.152.183.76
```

Проверка nginx из отдельного Pod:

```bash
kubectl exec task1-client -- curl -I http://task1-service:80/
```

Результат:

```text
HTTP/1.1 200 OK
Server: nginx/1.31.3
```

Проверка multitool из отдельного Pod:

```bash
kubectl exec task1-client -- curl http://task1-service:8080/
```

Результат:

```text
WBITT Network MultiTool (with NGINX) -
task1-app-d9b67697c-lxhz2 -
10.1.77.4 -
HTTP: 8080, HTTPS: 8443
```

При выполнении нескольких запросов Service распределил подключения между двумя репликами:

```text
task1-app-d9b67697c-9w8gg
task1-app-d9b67697c-lxhz2
```

Скриншот Service, EndpointSlice, отдельного Pod и результатов запросов:

![Доступ к приложениям через Service](./screenshots/scr4.png)

# Задание 2. Запуск nginx после появления Service
