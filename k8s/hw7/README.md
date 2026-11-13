# Домашнее задание к занятию «Helm»

Домашняя работа выполнена в Kubernetes-кластере MicroK8s.

## Параметры стенда

```text
Kubernetes:  v1.35.6
Node:        k8s7
Node IP:     51.250.44.217
OS:          Ubuntu 26.04 LTS
Helm:        v3.20.2
```

Для работы использовался встроенный Helm:

```bash
microk8s helm3
```

---

# Задание 1. Подготовить Helm-чарт для приложения

## Структура чарта

Создан Helm chart:

```text
hw7-app/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── _helpers.tpl
    ├── nginx-deployment.yaml
    ├── nginx-service.yaml
    ├── multitool-deployment.yaml
    └── multitool-service.yaml
```

Каждый компонент приложения разворачивается отдельным Deployment:

- `nginx`;
- `wbitt/network-multitool`.

Для каждого Deployment создан отдельный Service.

## Chart.yaml

Основные параметры:

```yaml
apiVersion: v2
name: hw7-app
description: Netology Kubernetes Helm homework 7
type: application
version: 0.1.0
appVersion: "1.0"
```

## Values

Версии контейнеров задаются через `values.yaml`.

Пример:

```yaml
nginx:
  replicaCount: 1
  image:
    repository: nginx
    tag: "1.28.0"
    pullPolicy: IfNotPresent
```

В шаблоне Deployment используется:

```yaml
image: "{{ .Values.nginx.image.repository }}:{{ .Values.nginx.image.tag }}"
```

Таким образом версия приложения меняется не правкой Deployment, а изменением values.

## Уникальные имена ресурсов

Для возможности устанавливать несколько копий одного чарта одновременно имена ресурсов формируются с использованием Helm release name:

```gotemplate
{{- printf "%s-%s" .Release.Name .Chart.Name }}
```

Например:

```text
app-v1-hw7-app-nginx
app-v2-hw7-app-nginx
app-v3-hw7-app-nginx
```

Также label:

```text
app.kubernetes.io/instance
```

содержит имя конкретного Helm release.

Это позволяет нескольким установкам одного чарта существовать без конфликтов.

## Проверка чарта

Выполнена проверка:

```bash
microk8s helm3 lint ./hw7-app
```

Результат:

```text
1 chart(s) linted, 0 chart(s) failed
```

Также проверен рендеринг:

```bash
microk8s helm3 template \
  demo \
  ./hw7-app \
  --namespace demo \
  -f values-app1-v1.yaml
```

Рендерятся четыре Kubernetes-ресурса:

```text
Service     multitool
Service     nginx
Deployment  multitool
Deployment  nginx
```

Для nginx подставляется версия из values:

```text
nginx:1.28.0
```

## Упаковка чарта

Чарт успешно упакован:

```bash
microk8s helm3 package ./hw7-app
```

Создан файл:

```text
hw7-app-0.1.0.tgz
```

### Скриншот

![Helm chart validation](images/task1-helm-chart.png)

---

# Задание 2. Запустить две версии в разных namespace
