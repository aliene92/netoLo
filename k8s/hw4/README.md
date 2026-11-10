# Домашнее задание к занятию «Сетевое взаимодействие в Kubernetes»

Домашнее задание выполнено в одноузловом кластере MicroK8s.

## Параметры стенда

```text
Kubernetes:         v1.35.6
Node:               k8s
Node IP:            153.51.117.14
ОС:                 Ubuntu 24.04 LTS
CNI:                Calico
Ingress Controller: Traefik
```

---

# Задание 1

Необходимо создать Deployment с тремя репликами, в каждом Pod которого работают два контейнера:

- `nginx` на порту `80`;
- `wbitt/network-multitool` на порту `8080`.

Также необходимо предоставить доступ к приложениям через `ClusterIP` и `NodePort`.

## Deployment

Манифест:

[`deployment-multi-container.yaml`](deployment-multi-container.yaml)

Создан Deployment:

```text
hw14-multi-container
```

Количество реплик:

```text
3
```

В каждом Pod находятся два контейнера:

```text
nginx                       TCP/80
wbitt/network-multitool     TCP/8080
```

Для `network-multitool` используется переменная окружения:

```yaml
env:
  - name: HTTP_PORT
    value: "8080"
```

После запуска Deployment состояние было следующим:

```text
NAME                   READY   UP-TO-DATE   AVAILABLE
hw14-multi-container   3/3     3            3
```

Все три Pod успешно запущены:

```text
READY   STATUS
2/2     Running
2/2     Running
2/2     Running
```

---

## ClusterIP Service

Манифест:

[`service-clusterip.yaml`](service-clusterip.yaml)

Создан Service:

```text
hw14-clusterip
```

Используется следующая схема портов:

```text
hw14-clusterip:9001 -> nginx:80
hw14-clusterip:9002 -> multitool:8080
```

Фактическое состояние Service:

```text
NAME             TYPE        CLUSTER-IP      PORT(S)
hw14-clusterip   ClusterIP   10.152.183.70   9001/TCP,9002/TCP
```

EndpointSlice содержал адреса трёх Pod:

```text
10.1.77.8
10.1.77.9
10.1.77.10
```

### Проверка nginx

Запрос выполнялся из временного Pod внутри Kubernetes:

```bash
microk8s kubectl run hw14-test-nginx \
  --image=wbitt/network-multitool \
  --restart=Never \
  --rm -i \
  --command -- \
  curl -sS -i http://hw14-clusterip:9001/
```

Результат:

```text
HTTP/1.1 200 OK
Server: nginx/1.31.3

Welcome to nginx!
```

### Проверка Network MultiTool

```bash
microk8s kubectl run hw14-test-multitool \
  --image=wbitt/network-multitool \
  --restart=Never \
  --rm -i \
  --command -- \
  curl -sS -i http://hw14-clusterip:9002/
```

Результат:

```text
HTTP/1.1 200 OK

WBITT Network MultiTool (with NGINX)
HTTP: 8080
```

### Скриншот

![Проверка ClusterIP](images/task1-clusterip.png)

---

## NodePort Service

Манифест:

[`service-nodeport.yaml`](service-nodeport.yaml)

Создан Service типа `NodePort`:

```text
NAME            TYPE       CLUSTER-IP       PORT(S)
hw14-nodeport   NodePort   10.152.183.189   80:30080/TCP
```

Используемый NodePort:

```text
30080/TCP
```

Проверка:

```bash
curl -i http://192.168.1.56:30080/
```

Результат:

```text
HTTP/1.1 200 OK
Server: nginx/1.31.3

Welcome to nginx!
```

Таким образом nginx доступен снаружи Kubernetes через IP узла и NodePort.

### Скриншот

![Проверка NodePort](images/task1-nodeport.png)

---
