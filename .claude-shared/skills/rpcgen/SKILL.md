---
name: rpcgen
description: "TRIGGER when: code imports rpcgen, user asks about generating RPC clients, TypeScript/Go/PHP/Swift/Kotlin/Dart client generation from zenrpc, or OpenRPC schema generation. Use for generating JSON-RPC 2.0 client code from SMD schemas."
---

# rpcgen — JSON-RPC 2.0 Client Code Generator

`github.com/vmkteam/rpcgen` — generates typed client libraries for JSON-RPC 2.0 services (zenrpc) in multiple languages.

## Supported Languages

- **Go** — `GoClient()`
- **TypeScript** — `TSClient()`, `TSCustomClient()`
- **PHP** — `PHPClient()`
- **Swift** — `SwiftClient()`
- **Kotlin** — `KotlinClient()`
- **Dart** — `DartClient()`
- **OpenRPC** — `OpenRPC()` schema document

## Installation

```bash
go get github.com/vmkteam/rpcgen
```

## Basic Usage

```go
import (
    "github.com/vmkteam/rpcgen"
    "github.com/vmkteam/zenrpc/v2"
)

// Create zenrpc server
rpc := zenrpc.NewServer(zenrpc.Options{ExposeSMD: true})
rpc.Register("arith", ArithService{})

// Generate client from SMD schema
gen := rpcgen.FromSMD(rpc.SMD())

// Generate Go client
goCode, err := gen.GoClient().Generate()

// Generate TypeScript client
tsCode, err := gen.TSClient().Generate()
```

## Generator Interface

All generators implement:

```go
type Generator interface {
    Generate() ([]byte, error)
}
```

## HTTP Handler for Dynamic Generation

Expose client generation as HTTP endpoints:

```go
// Serve generated TypeScript client
http.HandleFunc("/api/client.ts", rpcgen.Handler(gen.TSClient()))

// Serve generated Go client
http.HandleFunc("/api/client.go", rpcgen.Handler(gen.GoClient()))

// Serve OpenRPC schema
http.HandleFunc("/api/openrpc.json", rpcgen.Handler(gen.OpenRPC()))
```

`rpcgen.Handler()` wraps any `Generator` into an `http.HandlerFunc`.

## Custom Type Mapping

### TypeScript

```go
gen.TSCustomClient(func(objName string, schema smd.Property) string {
    if objName == "groups" {
        return "Record<number, IGroup>"
    }
    return "" // use default
})
```

### Swift

```go
gen.SwiftClient(func(schema smd.JSONSchema, param smd.ParameterDescription) string {
    // custom type mapping
    return swift.DefaultMap(schema, param)
})
```

### Kotlin

```go
gen.KotlinClient(kotlin.Settings{
    ClassName:  "MyAPI",
    PackageName: "com.example.api",
    Imports:    []string{"com.example.models.*"},
    IsProtocol: true, // generate interface instead of class
    TypeMapper: func(schema smd.JSONSchema, param smd.ParameterDescription) string {
        return "" // use default
    },
})
```

### Dart

```go
gen.DartClient(func(schema smd.JSONSchema, param smd.ParameterDescription) string {
    // custom type mapping
    return ""
})
```

## Initialization Methods

```go
// From zenrpc v2 SMD schema
gen := rpcgen.FromSMD(schema)

// From legacy v1 SMD schema (auto-converts)
gen := rpcgen.FromSMDv1(v1Schema)
```

## Typical Integration

In your server's main.go:

```go
rpc := zenrpc.NewServer(zenrpc.Options{ExposeSMD: true})
rpc.Register("users", UsersService{})
rpc.Register("orders", OrdersService{})

gen := rpcgen.FromSMD(rpc.SMD())

// API endpoints
http.Handle("/api", rpc)

// Generated clients
http.HandleFunc("/api/client.ts", rpcgen.Handler(gen.TSClient()))
http.HandleFunc("/api/client.go", rpcgen.Handler(gen.GoClient()))
http.HandleFunc("/api/openrpc.json", rpcgen.Handler(gen.OpenRPC()))
```
