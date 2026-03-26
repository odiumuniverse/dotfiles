---
name: embedlog
description: "TRIGGER when: code imports embedlog, user asks about structured logging with slog, Prometheus log metrics, or dual-level logging (stdout/stderr split). Use for adding logging to Go services."
---

# embedlog — Embeddable Structured Logger for Go

`github.com/vmkteam/embedlog` — a logging wrapper around Go's `log/slog` with Prometheus metrics, dual-level output (stdout for info, stderr for errors), and a colored dev mode.

## Installation

```bash
go get github.com/vmkteam/embedlog
```

## Creating Loggers

### Production Logger

```go
// verbose=true sets LevelInfo, false sets LevelError only
// isJSON=true uses slog.JSONHandler, false uses slog.TextHandler
logger := embedlog.NewLogger(verbose, isJSON)
```

- JSON format recommended for production services
- Text format with verbose for CLI tools
- Dual-level: info -> stdout, error -> stderr

### Development Logger

```go
logger := embedlog.NewDevLogger()
```

- Colored output via tint
- Shows source file:line
- Debug level enabled
- All output to stdout

## API

### Logging Methods

```go
// Info level (no context)
logger.Printf("started on %s", addr)

// Info level with context and structured args
logger.Print(ctx, "request processed", "duration", dur, "status", 200)

// Error level (no context)
logger.Errorf("failed to connect: %v", err)

// Error level with context and structured args
logger.Error(ctx, "query failed", "query", q, "err", err)

// Conditional: logs Error if err != nil, otherwise Info
logger.PrintOrErr(ctx, "operation complete", err, "key", "value")
```

### Enriching Loggers

```go
// Add persistent attributes
svcLogger := logger.With("service", "api", "version", "2.0")

// Add group prefix to all keys
dbLogger := logger.WithGroup("db")
```

### Access Underlying slog.Logger

```go
slogger := logger.Log() // returns *slog.Logger
```

## Embedding in Structs

The primary pattern — embed Logger in your service/manager struct:

```go
type UserManager struct {
    embedlog.Logger
    db *pg.DB
}

func NewUserManager(db *pg.DB, logger embedlog.Logger) *UserManager {
    return &UserManager{
        Logger: logger.With("manager", "user"),
        db:     db,
    }
}

func (m *UserManager) Create(ctx context.Context, u *User) error {
    _, err := m.db.Model(u).Insert()
    m.PrintOrErr(ctx, "user created", err, "id", u.ID)
    return err
}
```

## Prometheus Metrics

Automatically registered on import:

```
app_log_events_total{type="INFO"}   — info event counter
app_log_events_total{type="ERROR"}  — error event counter
```

Every call to Print/Printf increments info counter, every Error/Errorf increments error counter. Use error rate for alerting.

## Best Practices

| Context | Format | Verbose |
|---------|--------|---------|
| Production service | JSON (`true`) | `true` |
| CLI tool | Text (`false`) | flag-based |
| Development | `NewDevLogger()` | always |
| Alerting | any | monitor `app_log_events_total{type="ERROR"}` rate |
