# Домашнее задание к занятию «Хранение в K8s»

Домашняя работа выполнена в одновузловом кластере MicroK8s.

## Параметры стенда

```text
Kubernetes:  v1.36.2
Node:        k8s
Node IP:     51.250.44.217
OS:          Ubuntu 26.04 LTS
Namespace:   hw5
```

Для изоляции от предыдущих домашних работ все namespace-scoped ресурсы этого задания размещены в отдельном namespace `hw5`. Cluster-scoped ресурсы используют префикс `hw5-`.

---

# Задание 1. Volume: обмен данными между контейнерами в Pod

Создан Deployment из двух контейнеров:

- `busybox`;
- `wbitt/network-multitool`.

`busybox` записывает данные каждые 5 секунд в общий файл `/data/shared.log`, а `multitool` читает тот же файл.

Манифест:

[`containers-data-exchange.yaml`](containers-data-exchange.yaml)

Оба контейнера монтируют один `emptyDir`:

```yaml
volumes:
  - name: shared-data
    emptyDir: {}
```

`busybox` выполняет:

```sh
while true; do
  echo "$(date) - data written by busybox" >> /data/shared.log
  sleep 5
done
```

После запуска Pod находится в состоянии `2/2 Running`.

В `kubectl describe pod` видно два контейнера, mount `/data` у каждого и volume:

```text
shared-data:
  Type: EmptyDir
```

![scr1](images/scr1.png)

Проверка чтения из контейнера `multitool`:

```bash
POD="$(microk8s kubectl get pod -n hw21 -l app=data-exchange -o jsonpath='{.items[0].metadata.name}')"

microk8s kubectl exec   -n hw21   "$POD"   -c multitool   -- tail -f /data/shared.log
```

Новые строки появляются примерно каждые 5 секунд.

![scr2](images/scr2.png)

## Пояснение

`emptyDir` создаётся вместе с Pod и доступен всем контейнерам этого Pod. Он подходит для временного обмена файлами между контейнерами. При удалении Pod данные `emptyDir` удаляются вместе с ним.

---

# Задание 2. PersistentVolume и PersistentVolumeClaim

