# Домашнее задание к занятию «Настройка приложений и управление доступом в Kubernetes»

Домашняя работа выполнена в одновузловом кластере MicroK8s.

## Параметры стенда

```text
Kubernetes:  v1.35.6
Node:        k8s7
Node IP:     51.250.44.217
OS:          Ubuntu 26.04 LTS
Namespace:   hw6
Ingress:     Traefik
RBAC:        enabled
```

Все namespace-scoped ресурсы этого задания размещены в отдельном namespace `hw6`.

---

# Задание 1. ConfigMap

Создано приложение из двух контейнеров:

- `nginx` на порту `80`;
- `wbitt/network-multitool` на порту `8080`.

Манифесты:

- [`deployment.yaml`](deployment.yaml)
- [`configmap-web.yaml`](configmap-web.yaml)

ConfigMap `hw6-web-content` содержит `index.html` и монтируется в nginx в `/usr/share/nginx/html`.

```yaml
volumes:
  - name: web-content
    configMap:
      name: hw6-web-content
```

Для `multitool` задан отдельный HTTP-порт:

```yaml
env:
  - name: HTTP_PORT
    value: "8080"
```

После запуска Deployment имеет состояние `1/1`, а Pod — `2/2 Running`.

Создан Service `hw6-web-service`, направляющий TCP/80 на nginx.

Проверка страницы через Service возвращает содержимое ConfigMap:

```text
Привет от Kubernetes!
Эта страница загружена из ConfigMap.
Домашнее задание 6 — ConfigMap, Secret и RBAC.
```
![scr1](scrs/scr1.png)

---
# Задание 2. HTTPS с Secret

Манифесты:

- [`secret-tls.yaml`](secret-tls.yaml)
- [`ingress-tls.yaml`](ingress-tls.yaml)

Для учебного имени `hw6.example.com` создан самоподписанный сертификат:

```bash
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=hw6.example.com" \
  -addext "subjectAltName=DNS:hw6.example.com"
```

Сертификат содержит:

```text
CN=hw6.example.com
SAN=DNS:hw6.example.com
```

Создан TLS Secret:

```text
Name: hw6-tls
Type: kubernetes.io/tls
Keys: tls.crt, tls.key
```

Ingress `hw6-ingress-tls` использует Traefik и Secret `hw6-tls`:

```yaml
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - hw6.example.com
      secretName: hw6-tls
```

Проверка HTTPS выполнена без настройки публичного DNS:

```bash
curl -k \
  --resolve hw6.example.com:443:192.168.1.56 \
  -i \
  https://hw6.example.com/
```

Результат:

```text
HTTP/2 200
server: nginx/1.31.8
```

Traefik реально отдаёт сертификат `CN/SAN=hw6.example.com`, а приложение возвращает страницу из ConfigMap.

![scr2](scrs/scr2.png)

> В учебном задании TLS Secret хранится в YAML по требованию работы. В реальной инфраструктуре приватные ключи не следует хранить в Git в открытом виде.

---

# Задание 3. RBAC

RBAC включён командой:

```bash
microk8s enable rbac
```

До включения API Server использовал:

```text
--authorization-mode=AlwaysAllow
```

После включения:

```text
--authorization-mode=RBAC,Node
```

## Пользователь developer

Для пользователя создан отдельный X.509-сертификат.

```bash
openssl genrsa -out developer.key 2048
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"
```

CSR подписан CA MicroK8s. Сертификат проверен:

```text
subject=CN=developer
TLS Web Client Authentication
developer.crt: OK
```

## Role

Манифест: [`role-pod-reader.yaml`](role-pod-reader.yaml)

Role `hw6-pod-reader` разрешает:

```text
pods:      get, list, watch
pods/log:  get
```

Отдельного RBAC verb `describe` в Kubernetes нет: `kubectl describe pod` использует операции чтения API.

## RoleBinding

Манифест: [`rolebinding-developer.yaml`](rolebinding-developer.yaml)

RoleBinding `hw6-developer-pod-reader` связывает пользователя `developer` с Role `hw6-pod-reader` в namespace `hw6`.

## Проверка прав

Разрешено:

```text
list pods:      yes
get pod:        yes
get pod logs:   yes
```

Запрещено:

```text
create pod:       no
delete pod:       no
get secrets:      no
list deployments: no
```

Команда из задания работает:

```bash
microk8s kubectl get pods -n hw6 --as=developer
```

![scr3](scrs/scr3.png)

---

# Итог

| Задание | Механизм | Результат |
|---|---|---|
| 1 | ConfigMap | HTML-страница подключена в nginx как файл |
| 2 | Secret + TLS + Ingress | HTTPS работает через Traefik с самоподписанным сертификатом |
| 3 | RBAC + X.509 | `developer` имеет только read-only доступ к Pod и логам |

Ключевые результаты:

- ConfigMap успешно используется nginx;
- HTTPS отвечает `HTTP/2 200`;
- TLS Secret имеет тип `kubernetes.io/tls`;
- RBAC включён в MicroK8s;
- `developer` аутентифицируется X.509-сертификатом;
- пользователь может читать Pod, выполнять `describe` и читать логи;
- пользователь не может читать Secrets или удалять Pod.

---

# Структура репозитория

```text
.
├── README.md
├── deployment.yaml
├── configmap-web.yaml
├── secret-tls.yaml
├── ingress-tls.yaml
├── role-pod-reader.yaml
└── rolebinding-developer.yaml

```

Все задания выполнены и подтверждены скриншотами.


