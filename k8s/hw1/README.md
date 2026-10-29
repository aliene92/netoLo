# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

## Цель работы

Подготовить тестовую среду Kubernetes на базе MicroK8s:

- установить и запустить MicroK8s;
- включить Kubernetes Dashboard;
- добавить внешний IP-адрес в сертификат API-сервера;
- установить локальный клиент `kubectl`;
- настроить подключение `kubectl` к кластеру;
- подключиться к Kubernetes Dashboard через `port-forward`.

> В командах ниже необходимо заменить `<EXTERNAL_IP>` на внешний IP-адрес виртуальной машины с MicroK8s, а `<REMOTE_USER>` — на имя пользователя удалённой системы.

## Используемое окружение

- сервер или виртуальная машина с Ubuntu Linux;
- локальная машина с Linux;
- MicroK8s;
- kubectl;
- Bash.

---

## Задание 1. Установка MicroK8s

### 1.1. Обновление списка пакетов

```bash
sudo apt update
```

### 1.2. Установка snapd

```bash
sudo apt install -y snapd
```

Проверка установленной версии:

```bash
snap version
```

### 1.3. Установка MicroK8s

```bash
sudo snap install microk8s --classic
```

Проверка версии:

```bash
microk8s version
```

### 1.4. Добавление пользователя в группу microk8s

```bash
sudo usermod -aG microk8s "$USER"
```

Создание каталога конфигурации Kubernetes и назначение владельца:

```bash
mkdir -p "$HOME/.kube"
sudo chown -R "$USER":"$USER" "$HOME/.kube"
```

Для применения нового членства в группе необходимо повторно войти в систему либо выполнить:

```bash
newgrp microk8s
```

Проверка групп текущего пользователя:

```bash
groups
```

В списке должна присутствовать группа `microk8s`.

### 1.5. Ожидание готовности MicroK8s

```bash
microk8s status --wait-ready
```

Проверка состояния узла:

```bash
microk8s kubectl get nodes -o wide
```

Проверка системных компонентов:

```bash
microk8s kubectl get pods -A
```

Узел должен находиться в состоянии `Ready`.

---

## 1.6. Включение Kubernetes Dashboard

Включение дополнения:

```bash
microk8s enable dashboard
```

Ожидание запуска компонентов Dashboard:

```bash
microk8s kubectl wait \
  --namespace kube-system \
  --for=condition=Ready pod \
  --selector=k8s-app=kubernetes-dashboard \
  --timeout=300s
```

Проверка Pod и Service:

```bash
microk8s kubectl get pods -n kube-system \
  -l k8s-app=kubernetes-dashboard
```

```bash
microk8s kubectl get service -n kube-system kubernetes-dashboard
```

Просмотр включённых дополнений:

```bash
microk8s status
```

---

## 1.7. Создание пользователя для входа в Dashboard

Создание ServiceAccount с административными правами:

```bash
cat <<'EOF' | microk8s kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: dashboard-admin
    namespace: kube-system
EOF
```

Получение токена:

```bash
microk8s kubectl create token dashboard-admin \
  --namespace kube-system \
  --duration=24h
```

Полученный токен используется для авторизации в веб-интерфейсе Dashboard.

> Роль `cluster-admin` предоставляет полный доступ к кластеру. Такая настройка допустима для учебной тестовой среды, но не рекомендуется для промышленной эксплуатации.

---

## 1.8. Добавление внешнего IP-адреса в сертификат MicroK8s

Определение внешнего IP-адреса сервера:

```bash
curl -4 ifconfig.me
echo
```

Открытие шаблона параметров сертификата:

```bash
sudo nano /var/snap/microk8s/current/certs/csr.conf.template
```

В секцию `[ alt_names ]` необходимо добавить внешний IP-адрес. Номер параметра `IP.N` должен быть уникальным.

Пример:

```ini
[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 10.152.183.1
IP.3 = <EXTERNAL_IP>
```

После сохранения файла необходимо обновить сертификат API-сервера:

```bash
sudo microk8s refresh-certs --cert server.crt
```

Ожидание повторной готовности кластера:

```bash
microk8s status --wait-ready
```

Проверка доступности Kubernetes API на сервере:

```bash
curl -k https://127.0.0.1:16443/version
```

Просмотр Subject Alternative Name нового сертификата:

```bash
sudo openssl x509 \
  -in /var/snap/microk8s/current/certs/server.crt \
  -noout \
  -ext subjectAltName
```

В выводе должен присутствовать `<EXTERNAL_IP>`.

> Для сертификата Kubernetes API обновляется `server.crt`. Сертификат `front-proxy-client.crt` используется другим компонентом и не добавляет внешний IP в сертификат API-сервера.

---

## 1.9. Настройка сетевого доступа к Kubernetes API

MicroK8s API Server по умолчанию использует TCP-порт `16443`.

При использовании UFW можно разрешить подключение только с IP-адреса локальной машины:

```bash
sudo ufw allow from <LOCAL_CLIENT_IP> to any port 16443 proto tcp
```

Проверка правил:

```bash
sudo ufw status numbered
```

Не рекомендуется открывать Kubernetes API для всего интернета правилом `16443/tcp ALLOW Anywhere`.

---

## Задание 2. Установка и настройка локального kubectl

Все команды этого раздела выполняются на локальной машине.

### 2.1. Установка kubectl

Определение архитектуры:

```bash
uname -m
```

Для архитектуры `x86_64`:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

Для архитектуры `aarch64` или `arm64`:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
```

Установка бинарного файла:

```bash
chmod +x kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl
```

Проверка клиента:

```bash
kubectl version --client
```

---

## 2.2. Настройка автодополнения kubectl

Установка `bash-completion`:

```bash
sudo apt update
sudo apt install -y bash-completion
```

Включение автодополнения в текущем сеансе:

```bash
source <(kubectl completion bash)
```

Добавление автодополнения в `~/.bashrc`:

```bash
echo 'source <(kubectl completion bash)' >> "$HOME/.bashrc"
```

Дополнительно можно создать короткий псевдоним `k`:

```bash
echo 'alias k=kubectl' >> "$HOME/.bashrc"
echo 'complete -o default -F __start_kubectl k' >> "$HOME/.bashrc"
```

Применение настроек:

```bash
source "$HOME/.bashrc"
```

---

## 2.3. Получение конфигурации MicroK8s

На сервере с MicroK8s конфигурация выводится командой:

```bash
microk8s config
```

На локальной машине создаётся каталог конфигурации:

```bash
mkdir -p "$HOME/.kube"
chmod 700 "$HOME/.kube"
```

Конфигурацию можно сразу получить по SSH:

```bash
ssh <REMOTE_USER>@<EXTERNAL_IP> 'microk8s config' \
  > "$HOME/.kube/config"
```

Назначение безопасных прав:

```bash
chmod 600 "$HOME/.kube/config"
```

Конфигурация MicroK8s обычно содержит адрес API `https://127.0.0.1:16443`. Для прямого внешнего подключения его необходимо заменить на внешний IP сервера:

```bash
sed -i "s#https://127.0.0.1:16443#https://<EXTERNAL_IP>:16443#" \
  "$HOME/.kube/config"
```

Проверка адреса API:

```bash
kubectl config view --minify
```

Проверка текущего контекста:

```bash
kubectl config current-context
```

---

## 2.4. Проверка подключения локального kubectl

Проверка информации о кластере:

```bash
kubectl cluster-info
```

Получение списка узлов:

```bash
kubectl get nodes -o wide
```

Получение списка всех Pod:

```bash
kubectl get pods -A
```

Получение списка пространств имён:

```bash
kubectl get namespaces
```

При корректной настройке команда `kubectl get nodes -o wide` должна показать узел MicroK8s в состоянии `Ready`.

---

## 2.5. Подключение к Dashboard через port-forward

На локальной машине запускается проброс порта:

```bash
kubectl port-forward \
  --namespace kube-system \
  service/kubernetes-dashboard \
  10443:443
```

Команда остаётся запущенной в текущем терминале. После запуска Dashboard доступен по адресу:

```text
https://127.0.0.1:10443/
```

Браузер может вывести предупреждение о недоверенном сертификате, поскольку Dashboard использует внутренний сертификат кластера.

Для входа необходимо:

1. выбрать способ авторизации `Token`;
2. получить токен на сервере MicroK8s:

   ```bash
   microk8s kubectl create token dashboard-admin \
     --namespace kube-system \
     --duration=24h
   ```

3. вставить токен в форму авторизации;
4. нажать кнопку входа.

Остановка `port-forward` выполняется сочетанием клавиш:

```text
Ctrl+C
```

---

## Альтернативный безопасный доступ через SSH-туннель

Если порт `16443` не требуется публиковать во внешнюю сеть, можно оставить в kubeconfig адрес `127.0.0.1` и создать SSH-туннель:

```bash
ssh -L 16443:127.0.0.1:16443 <REMOTE_USER>@<EXTERNAL_IP>
```

Пока туннель активен, локальный `kubectl` сможет обращаться к API по адресу:

```text
https://127.0.0.1:16443
```

Этот вариант безопаснее прямого открытия Kubernetes API в интернет.

---

## Итоговая проверка

Статус MicroK8s:

```bash
microk8s status --wait-ready
```

Состояние узла через встроенный клиент:

```bash
microk8s kubectl get nodes -o wide
```

Состояние узла через локальный `kubectl`:

```bash
kubectl get nodes -o wide
```

Состояние Dashboard:

```bash
kubectl get pods -n kube-system \
  -l k8s-app=kubernetes-dashboard
```

Проверка сервиса Dashboard:

```bash
kubectl get service -n kube-system kubernetes-dashboard
```

Проверка адреса Kubernetes API в kubeconfig:

```bash
kubectl config view --minify \
  --output jsonpath='{.clusters[0].cluster.server}{"\n"}'
```

---

## Результат

В ходе выполнения домашнего задания:

- установлен MicroK8s;
- проверена готовность Kubernetes-узла;
- включён Kubernetes Dashboard;
- создан ServiceAccount для входа в Dashboard;
- внешний IP-адрес добавлен в SAN сертификата API-сервера;
- установлен локальный клиент `kubectl`;
- настроено Bash-автодополнение;
- сформирован и установлен kubeconfig;
- проверено подключение локального `kubectl` к MicroK8s;
- выполнен доступ к Dashboard через `kubectl port-forward`.

## Полезные команды

```bash
# Статус MicroK8s
microk8s status

# Ожидание готовности
microk8s status --wait-ready

# Список узлов
microk8s kubectl get nodes -o wide

# Все Pod
microk8s kubectl get pods -A

# Включение дополнения
microk8s enable <ADDON_NAME>

# Отключение дополнения
microk8s disable <ADDON_NAME>

# Вывод kubeconfig
microk8s config

# Информация о кластере
kubectl cluster-info

# Текущий контекст
kubectl config current-context

# Список ресурсов во всех пространствах имён
kubectl get all -A
```

## Ссылки

- [Документация MicroK8s](https://microk8s.io/docs)
- [Установка kubectl в Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Документация kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Автодополнение kubectl](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_completion/)
- [Использование port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)
- [Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
