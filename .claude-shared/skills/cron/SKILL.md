---
name: vmk-cron
description: "TRIGGER when: code imports vmkteam/cron, user asks about cron job management, scheduled tasks, maintenance jobs, cron middleware, or cron web UI. Use for creating and managing scheduled jobs in Go services."
---

# cron — Cron Job Manager for Go

`github.com/vmkteam/cron` — production-ready cron job manager built on `robfig/cron/v3` with context-aware jobs, middleware, web UI, and Prometheus metrics.

## Installation

```bash
go get github.com/vmkteam/cron
```

## Core Types

```go
type Func           func(ctx context.Context) error
type MiddlewareFunc func(Func) Func
type Schedule       string  // cron expression or empty/"disabled"

type Runner interface {
    Run(context.Context) error
}
```

## Basic Usage

```go
import "github.com/vmkteam/cron"

m := cron.NewManager()

// Add middleware
m.Use(
    cron.WithLogger(log.Printf),
    cron.WithSentry(sentryClient),
    cron.WithRecover(),
    cron.WithSkipActive(),
    cron.WithMetrics(),
)

// Register jobs
m.AddFunc("sync-users", cron.Schedule("*/5 * * * *"), func(ctx context.Context) error {
    return syncUsers(ctx)
})

// Register maintenance job (gets exclusive lock)
m.AddMaintenanceFunc("cleanup", cron.Schedule("0 3 * * *"), func(ctx context.Context) error {
    return cleanup(ctx)
})

// Or use Runner interface
m.Add("import", cron.Schedule("0 */2 * * *"), &ImportJob{})

// Start
if err := m.Run(ctx); err != nil {
    log.Fatal(err)
}
defer m.Stop()
```

## Schedule

```go
cron.Schedule("*/5 * * * *")  // every 5 minutes (standard cron format)
cron.Schedule("@hourly")       // robfig/cron shortcuts
cron.Schedule("")               // disabled
```

`Schedule.IsActive()` returns false for empty or "disabled" schedules.

## Middleware

| Middleware | Description |
|-----------|-------------|
| `WithLogger(printf)` | Printf-style logging with job name, duration, status |
| `WithSLog(logger)` | Structured logging via slog interface |
| `WithSentry(client)` | Sentry error reporting with panic recovery, tags job name |
| `WithRecover()` | Panic recovery with stack trace in error |
| `WithSkipActive()` | Prevents concurrent execution of same job (returns `ErrSkipped`) |
| `WithMaintenance()` | Exclusive lock for maintenance jobs, read lock for regular |
| `WithMetrics()` | Prometheus metrics (see below) |
| `WithDevel()` | Marks environment as development |

Middleware is applied in reverse order (last added runs first around the function).

## Prometheus Metrics (WithMetrics)

```
app_cron_evaluated_total{name="...", state="..."}     — job execution counter
app_cron_active{name="..."}                            — currently running jobs gauge
app_cron_evaluated_duration_seconds{name="..."}        — execution duration summary
```

## Web UI / HTTP Handler

```go
http.HandleFunc("/debug/cron", m.Handler)
```

Supports content negotiation:
- `text/html` — full HTML page with table, auto-refresh every 10s
- `application/json` — JSON array of job states
- `text/plain` — tab-formatted text output

### Manual Job Execution

```
GET /debug/cron?start=sync-users
```

Or programmatically:
```go
err := m.ManualRun(ctx, "sync-users")
```

### Print Schedule to Writer

```go
m.TextSchedule(os.Stdout)
```

## Job State

```go
type State struct {
    ID, Name, Schedule string
    IsMaintenance      bool
    LastState          string    // "idle", "running", "disabled", "skipped"
    LastErr            error
    LastDuration       time.Duration
    LastUpdatedAt      time.Time
    LastRun, NextRun   time.Time
}

states := m.State() // returns []State
```

## Context Helpers

```go
cron.NameFromContext(ctx)         // get current job name
cron.MaintenanceFromContext(ctx)  // is maintenance job?
```

## Error Sentinel Values

```go
cron.ErrSkipped   // job was skipped (by WithSkipActive)
cron.ErrNotFound  // job not found (ManualRun)
cron.ErrDuplicate // duplicate job name
```

## Maintenance vs Regular Jobs

- **Regular jobs**: `AddFunc` / `Add` — run concurrently, use read lock with WithMaintenance
- **Maintenance jobs**: `AddMaintenanceFunc` — acquire exclusive lock, block all other jobs during execution
