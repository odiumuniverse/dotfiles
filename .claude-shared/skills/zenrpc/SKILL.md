---
name: zenrpc
description: "TRIGGER when: code imports zenrpc, user asks about JSON-RPC 2.0 services, RPC method signatures, SMD/OpenRPC schema, zenrpc middleware, or zenrpc code generation. Use for creating/modifying RPC services, registering methods, handling errors, writing middleware."
---

# zenrpc — JSON-RPC 2.0 Server Library for Go

`github.com/vmkteam/zenrpc/v2` — JSON-RPC 2.0 server with SMD (Service Mapping Description) and OpenRPC support, built on `go generate` instead of reflection.

## Ecosystem

- **SMDBox** — Swagger-like JSON-RPC API browser (github.com/semrush/smdbox)
- **zenrpc-middleware** — middleware collection (github.com/vmkteam/zenrpc-middleware)
- **brokersrv** — NATS transport (github.com/vmkteam/brokersrv)
- **rpcgen** — client code generator for Go/TS/PHP/Swift/Kotlin/Dart (github.com/vmkteam/rpcgen)
- **rpcdiff** — OpenRPC schema diff tool (github.com/vmkteam/rpcdiff)

## Installation

```bash
go install github.com/vmkteam/zenrpc/v2/zenrpc@latest
```

## Creating a Service

A service is a struct with RPC methods representing an RPC namespace.

1. Import `github.com/vmkteam/zenrpc/v2`
2. Add trailing comment `//zenrpc` to struct OR embed `zenrpc.Service`
3. Write methods with accepted signatures
4. Run `go generate` or `zenrpc` for code generation (creates `*_zenrpc.go` files)

### Accepted Method Signatures

```go
func(Service) Method([args]) (<value>, <error>)
func(Service) Method([args]) <value>
func(Service) Method([args]) <error>
func(Service) Method([args])
```

- Value can be a pointer
- Error is `error` or `*zenrpc.Error`
- Methods can accept `context.Context` as first argument

### Example Service

```go
type ArithService struct{ zenrpc.Service }

// Sum sums two digits and returns error with code.
func (as ArithService) Sum(ctx context.Context, a, b int) (bool, *zenrpc.Error) {
    r, _ := zenrpc.RequestFromContext(ctx)
    return true, zenrpc.NewStringError(a+b, r.Host)
}

// Multiply multiplies two digits.
func (as ArithService) Multiply(a, b int) int {
    return a * b
}

// Pow returns x**y. If exp is not set default is 2.
//
//zenrpc:exp=2
func (as ArithService) Pow(base float64, exp float64) float64 {
    return math.Pow(base, exp)
}

//go:generate zenrpc
```

## Server Setup

```go
rpc := zenrpc.NewServer(zenrpc.Options{ExposeSMD: true})
rpc.Register("arith", ArithService{})
rpc.Register("", ArithService{}) // public namespace
rpc.Use(zenrpc.Logger(log.New(os.Stderr, "", log.LstdFlags)))

http.Handle("/", rpc)
log.Fatal(http.ListenAndServe(":9999", nil))
```

### Options

```go
type Options struct {
    BatchMaxLen     int                    // max batch size (default 10)
    ExposeSMD       bool                   // expose SMD schema at /smd endpoint
    AllowCORS       bool                   // enable CORS headers
    HideErrorData   bool                   // hide error.data in responses
    Upgrader        *websocket.Upgrader    // WebSocket support
}
```

## Magic Comments (all optional)

```go
// Method parameter with default value and description:
//zenrpc:paramName=defaultValue description text

// Error code documentation:
//zenrpc:401 Unauthorized

// Return description:
//zenrpc:return Description of return value

// Mark struct as zenrpc service:
type MyService struct {} //zenrpc
```

## Core Types

### Request
```go
type Request struct {
    Version   string           `json:"jsonrpc"`
    ID        *json.RawMessage `json:"id"`
    Method    string           `json:"method"`
    Params    json.RawMessage  `json:"params"`
    Namespace string           `json:"-"`
}
```

### Response
```go
type Response struct {
    Version    string           `json:"jsonrpc"`
    ID         *json.RawMessage `json:"id"`
    Result     *json.RawMessage `json:"result,omitempty"`
    Error      *Error           `json:"error,omitempty"`
    Extensions map[string]any   `json:"extensions,omitempty"`
}
```

### Error
```go
type Error struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    Data    any    `json:"data,omitempty"`
    Err     error  `json:"-"`
}
```

Standard error codes: `ParseError`, `InvalidRequest`, `MethodNotFound`, `InvalidParams`, `InternalError`, `ServerError`.

Helper functions: `NewError(code, err)`, `NewStringError(code, msg)`, `NewResponseError(err)`.

## Middleware

```go
type MiddlewareFunc func(InvokeFunc) InvokeFunc
type InvokeFunc func(ctx context.Context, method string, params json.RawMessage) Response
```

Built-in middleware:
- `zenrpc.Logger(logger)` — logs requests with IP, method, duration, errors
- `zenrpc.Metrics(serverName)` — Prometheus metrics (error count, response duration by method)

Usage:
```go
rpc.Use(zenrpc.Logger(log.New(os.Stderr, "", log.LstdFlags)))
rpc.Use(zenrpc.Metrics("myserver"))
```

## Context Helpers

```go
zenrpc.RequestFromContext(ctx)     // get original Request
zenrpc.NamespaceFromContext(ctx)   // get current namespace
zenrpc.IDFromContext(ctx)          // get request ID
```

## Features

- Single and batch requests
- Named and positional parameters
- Default parameter values via magic comments
- SMD/OpenRPC schema generation
- HTTP, WebSocket, NATS transports
- Server middleware chain

## Code Generation

After writing service methods, run:
```bash
go generate ./...
# or directly:
zenrpc
```

This generates `*_zenrpc.go` files containing the dispatch logic. **Always regenerate after modifying RPC service methods.**
