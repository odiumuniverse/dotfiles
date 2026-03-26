---
name: orbstack
description: "TRIGGER when: user asks to manage Docker containers/images/volumes/networks, run docker-compose, work with Linux VMs (OrbStack machines), or manage Kubernetes resources via OrbStack. Use MCP tools instead of shell docker/kubectl commands."
---

# OrbStack — Docker & Linux Machines on macOS

OrbStack — быстрая замена Docker Desktop для macOS. Предоставляет MCP-инструменты для управления контейнерами, образами, сетями, томами, docker-compose, Linux-машинами (VM) и Kubernetes.

**Важно:** всегда используй MCP-инструменты `mcp__orbstack__*` вместо выполнения `docker` или `kubectl` через Bash.

---

## Docker — контейнеры

| Инструмент | Описание | Обязательные параметры |
|---|---|---|
| `mcp__orbstack__docker_list_containers` | Список контейнеров | — (`all=true` — включая остановленные) |
| `mcp__orbstack__docker_run` | Создать и запустить контейнер | `image` |
| `mcp__orbstack__docker_start` | Запустить остановленный контейнер | `containers: []` |
| `mcp__orbstack__docker_stop` | Остановить контейнер | `containers: []` |
| `mcp__orbstack__docker_restart` | Перезапустить контейнер | `containers: []` |
| `mcp__orbstack__docker_rm` | Удалить контейнер | `containers: []` (`force`, `volumes`) |
| `mcp__orbstack__docker_logs` | Логи контейнера | `container` (`tail=100`) |
| `mcp__orbstack__docker_exec` | Выполнить команду в контейнере | `container`, `command` |
| `mcp__orbstack__docker_inspect` | Подробная JSON-информация | `container` |
| `mcp__orbstack__docker_stats` | Статистика ресурсов | — (или `containers: []`) |

### docker_run — параметры

```
image        string    — образ (напр. "nginx:latest")
name         string?   — имя контейнера
ports        ["8080:80", "443:443"]
env          ["KEY=value"]
volumes      ["/host:/container"]
detach       bool      — фон (default: true)
extra_args   string?   — доп. флаги docker run
```

---

## Docker — образы

| Инструмент | Описание | Параметры |
|---|---|---|
| `mcp__orbstack__docker_images` | Список всех образов | — |
| `mcp__orbstack__docker_pull` | Скачать образ | `image` |
| `mcp__orbstack__docker_rmi` | Удалить образ | `images: []` (`force`) |

---

## Docker — сети и тома

| Инструмент | Описание | Параметры |
|---|---|---|
| `mcp__orbstack__docker_network_ls` | Список сетей | — |
| `mcp__orbstack__docker_network_create` | Создать сеть | `name` (`driver`) |
| `mcp__orbstack__docker_volume_ls` | Список томов | — |
| `mcp__orbstack__docker_volume_create` | Создать том | `name` |

---

## Docker — система

| Инструмент | Описание | Параметры |
|---|---|---|
| `mcp__orbstack__docker_system_df` | Использование диска | — |
| `mcp__orbstack__docker_system_prune` | Очистить неиспользуемые данные | `all` (все образы), `volumes` |

---

## Docker Compose

| Инструмент | Описание | Параметры |
|---|---|---|
| `mcp__orbstack__docker_compose_up` | Запустить сервисы | `project_dir` (`detach=true`, `services: []`) |
| `mcp__orbstack__docker_compose_down` | Остановить и удалить | `project_dir` (`volumes`) |
| `mcp__orbstack__docker_compose_ps` | Список контейнеров проекта | `project_dir` |

`project_dir` — абсолютный путь к директории с `docker-compose.yml`.

---

## OrbStack Linux Machines (VM)

| Инструмент | Описание | Параметры |
|---|---|---|
| `mcp__orbstack__orb_list` | Список машин | — |
| `mcp__orbstack__orb_info` | Статус и системная информация | — |
| `mcp__orbstack__orb_create` | Создать машину | `distro` (`name`) |
| `mcp__orbstack__orb_start` | Запустить машину | `machine` |
| `mcp__orbstack__orb_stop` | Остановить машину | `machine` |
| `mcp__orbstack__orb_run` | Выполнить команду в машине | `machine`, `command` |
| `mcp__orbstack__orb_delete` | Удалить машину | `machine` |

Поддерживаемые дистрибутивы для `orb_create`: `ubuntu`, `debian`, `fedora`, `arch`, и другие.

---

## Kubernetes (OrbStack k8s)

| Инструмент | Описание | Параметры |
|---|---|---|
| `mcp__orbstack__kubectl_get` | Получить ресурсы | `resource` (`namespace`, `all_namespaces`) |
| `mcp__orbstack__kubectl_describe` | Подробное описание ресурса | `resource`, `name` (`namespace`) |
| `mcp__orbstack__kubectl_logs` | Логи пода | `pod` (`namespace`, `container`, `tail`) |
| `mcp__orbstack__kubectl_apply` | Применить манифест из файла | `file` (`namespace`) |

Типы ресурсов для `kubectl_get`/`kubectl_describe`: `pods`, `services`, `deployments`, `nodes`, `namespaces`, `configmaps`, `secrets`, и т.д.

---

## Типовые сценарии

### Посмотреть все запущенные контейнеры
```
mcp__orbstack__docker_list_containers()
```

### Запустить PostgreSQL локально
```
mcp__orbstack__docker_run(
  image="postgres:16",
  name="pg-dev",
  ports=["5432:5432"],
  env=["POSTGRES_PASSWORD=postgres", "POSTGRES_DB=mydb"],
  volumes=["/Users/user/pgdata:/var/lib/postgresql/data"]
)
```

### Запустить docker-compose проект
```
mcp__orbstack__docker_compose_up(project_dir="/Users/universe/myproject")
```

### Выполнить миграцию в контейнере
```
mcp__orbstack__docker_exec(container="myapp", command="./myapp migrate")
```

### Проверить логи и ресурсы
```
mcp__orbstack__docker_logs(container="myapp", tail=200)
mcp__orbstack__docker_stats()
```

### Очистить диск
```
mcp__orbstack__docker_system_df()
mcp__orbstack__docker_system_prune(all=true)
```

### Создать Linux VM и выполнить команду
```
mcp__orbstack__orb_create(distro="ubuntu", name="dev-vm")
mcp__orbstack__orb_run(machine="dev-vm", command="apt-get update && apt-get install -y curl")
```
