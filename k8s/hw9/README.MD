# Домашнее задание к занятию «Установка Kubernetes»

## Цель

Установить Kubernetes-кластер из пяти нод:

- 1 master/control-plane;
- 4 worker-ноды;
- CRI — `containerd`;
- `etcd` — на master;
- способ установки — `kubeadm`.

Дополнительное HA-задание со звёздочкой не выполнялось.

---

# 1. Итоговая схема кластера

Использованы пять виртуальных машин:

| Роль | Hostname | IP |
|---|---|---|
| Control Plane | `k8s-master` | `153.51.115.75` |
| Worker 1 | `k8s-worker-1` | `153.51.113.7` |
| Worker 2 | `k8s-worker-2` | `93.77.165.207` |
| Worker 3 | `k8s-worker-3` | `153.51.116.241` |
| Worker 4 | `k8s-worker-4` | `153.51.115.163` |

Фактически использованная ОС:

```text
Ubuntu 26.04.5 LTS
```

> В чеклисте задания указана Ubuntu 20.04 LTS. На стенде использована Ubuntu 26.04 LTS. Установка и работа Kubernetes-кластера на ней успешно проверены.

Версии основных компонентов:

```text
Kubernetes: v1.35.10
containerd: 2.2.1
CNI: Flannel v0.28.8
```

---

# 2. Подготовка виртуальных машин

Перед установкой Kubernetes на всех пяти VM выполнена базовая подготовка:

- расширение LVM;
- настройка hostname;
- заполнение `/etc/hosts`;
- отключение swap;
- загрузка `overlay` и `br_netfilter`;
- настройка `sysctl`;
- установка и настройка `containerd`.

---

# 3. Kernel modules и sysctl

На всех нодах загружены:

```text
overlay
br_netfilter
```

Настроены параметры:

```text
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
```

Swap отключён:

```bash
swapoff -a
```

---

# 4. Container Runtime

На всех пяти нодах установлен:

```text
containerd 2.4.2
```

В `/etc/containerd/config.toml` включено:

```text
SystemdCgroup = true
```

Проверка:

```bash
systemctl is-active containerd
```

возвращает:

```text
active
```

---

# 5. kubeadm, kubelet и kubectl

На всех нодах подключён репозиторий Kubernetes ветки `v1.35` и установлены:

```text
kubeadm
kubelet
kubectl
kubernetes-cni
```

Версия:

```text
v1.35.10
```

Пакеты зафиксированы:

```bash
apt-mark hold kubelet kubeadm kubectl
```

---

# 6. Инициализация control plane

На `k8s-master` выполнено:

```bash
kubeadm init \
  --kubernetes-version=v1.35.10 \
  --apiserver-advertise-address=19168.1.80 \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --node-name=k8s-master
```

Результат:

```text
Your Kubernetes control-plane has initialized successfully!
```

API Server:

```text
19168.1.80:6443
```

---

# 7. etcd на master

`kubeadm` создал локальный `etcd` как static Pod:

```text
/etc/kubernetes/manifests/etcd.yaml
```

Проверка:

```bash
kubectl get pod \
  -n kube-system \
  -l component=etcd \
  -o wide
```

Результат:

```text
etcd-k8s-master   1/1   Running   ...   19168.1.80   k8s-master
```

Таким образом требование задания о размещении `etcd` на master выполнено.

---

# 8. CNI — Flannel

Для Pod network установлен:

```text
Flannel v0.28.8
```

Использован Pod CIDR:

```text
10.244.0.0/16
```

После установки Flannel master перешёл в `Ready`.

---

# 9. Подключение worker-нод

Каждая worker-нода присоединена командой вида:

```bash
kubeadm join 19168.1.80:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --cri-socket unix:///run/containerd/containerd.sock
```

После TLS Bootstrap kubelet на worker-нодах работает как systemd service.

---

# 10. Итоговое состояние нод

Проверка:

```bash
kubectl get nodes -o wide
```

Результат:

```text
k8s-master     Ready   control-plane   19168.1.80
k8s-worker-1   Ready   <none>          19168.1.68
k8s-worker-2   Ready   <none>          19168.1.69
k8s-worker-3   Ready   <none>          19168.1.90
k8s-worker-4   Ready   <none>          19168.1.84
```

Все пять нод используют:

```text
Kubernetes v1.35.10
containerd://2.4.2
```

### Скриншот

![Kubernetes cluster nodes](images/task1-cluster-nodes.png)

---

# 11. Проверка работы worker-нод

Для дополнительной проверки создан манифест:

[`hw9-test.yaml`](hw9-test.yaml)

Он создаёт:

```text
Namespace:  hw9-test
Deployment: nginx-test
Replicas:   4
Service:    nginx-test
```

В Deployment применён `topologySpreadConstraints`, поэтому четыре Pod распределены по четырём worker-нодам.

Фактическое распределение:

```text
10.244.1.2   k8s-worker-1
10.244.2.2   k8s-worker-2
10.244.4.2   k8s-worker-3
10.244.5.2   k8s-worker-4
```

Это подтверждает, что все четыре worker-ноды реально участвуют в scheduling.

---

# 12. Проверка Service и DNS

Создан Service:

```text
nginx-test
```

Тип:

```text
ClusterIP
```

ClusterIP:

```text
10.102.108.101
```

Из временного Pod `hw9-client` выполнен:

```bash
nslookup nginx-test.hw9-test.svc.cluster.local
```

DNS успешно разрешил Service:

```text
nginx-test.hw9-test.svc.cluster.local
Address: 10.102.108.101
```

Затем выполнен:

```bash
wget -qO- http://nginx-test/
```

Получена стандартная nginx-страница:

```text
Welcome to nginx!
```

Это подтверждает:

- работу CoreDNS;
- работу Flannel;
- работу ClusterIP Service;
- межнодовую Pod-сеть.

### Скриншот

![Kubernetes network test](images/task1-network-test.png)

---

# 13. Проверка манифеста

Манифест:

[`hw9-test.yaml`](hw9-test.yaml)

Проверка:

```bash
kubectl apply \
  --dry-run=server \
  -f hw9-test.yaml
```

Результат:

```text
namespace/hw9-test unchanged (server dry run)
deployment.apps/nginx-test unchanged (server dry run)
service/nginx-test unchanged (server dry run)
```

---

# 14. Структура репозитория

```text
.
├── README.md
└── hw9-test.yaml
```

---

# 15. Итог

Обязательная часть домашнего задания выполнена.

Создан Kubernetes-кластер:

```text
1 master/control-plane
4 worker
```

Использовано:

```text
CRI:        containerd 2.2.1
Kubernetes: v1.35.10
CNI:        Flannel v0.28.8
Pod CIDR:   10.244.0.0/16
```

Подтверждено:

- все 5 нод имеют статус `Ready`;
- `etcd` работает на master;
- `containerd` используется на всех нодах;
- Flannel работает на всех нодах;
- четыре nginx Pod распределены по четырём worker-нодам;
- CoreDNS разрешает Kubernetes Service;
- ClusterIP Service доступен из Pod;
- HTTP-запрос возвращает страницу nginx.
