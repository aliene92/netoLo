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
server: nginx/1.31.3
```

Traefik реально отдаёт сертификат `CN/SAN=hw6.example.com`, а приложение возвращает страницу из ConfigMap.

![scr2](scrs/scr2.png)

> В учебном задании TLS Secret хранится в YAML по требованию работы. В реальной инфраструктуре приватные ключи не следует хранить в Git в открытом виде.

---

# Задание 3. RBAC


