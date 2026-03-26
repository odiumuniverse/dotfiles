---
name: colgen
description: "TRIGGER when: code uses colgen annotations, user asks about generating collection types, typed slices, ID extraction, indexing/grouping helpers, or colgen directives. Use for generating Go collection boilerplate from struct annotations."
---

# colgen — Collection Generator for Go

`github.com/vmkteam/colgen` — generates typed collection types (slices) with utility methods from struct comment annotations. Eliminates boilerplate for ID extraction, indexing, grouping, and relationship hydration.

## Installation

```bash
go install github.com/vmkteam/colgen/cmd/colgen@latest
```

## Basic Usage

Annotate your struct:

```go
//go:generate colgen

//colgen:News:StatusID,Group(TagIDs)
type News struct {
    ID       int
    StatusID int
    TagIDs   []int
    Title    string
}
```

Run:
```bash
go generate ./...
```

This generates a `Newss` typed slice (or `NewsList` with `-list` flag) with methods like `IDs()`, `UniqueStatusIDs()`, `GroupByTagIDs()`, etc.

## Annotation Syntax

```
//colgen:<TypeName>:<Generator1>,<Generator2>(<Field>),<Generator3>(<Field>,<Arg>)
```

The type name after `colgen:` becomes the collection type name (adds `s` suffix by default).

## Available Generators

### Basic Field Operations

| Generator | Generated Method | Description |
|-----------|-----------------|-------------|
| `<Field>` (bare) | `<Field>s()` | Extract field values as slice |
| `Unique<Field>` | `Unique<Field>s()` | Extract unique field values |
| `Index(<Field>)` | `IndexBy<Field>()` | Map from field value to item |
| `Group(<Field>)` | `GroupBy<Field>()` | Map from field value to slice of items |
| `Count(<Field>)` | `CountBy<Field>()` | Map from field value to count |
| `Flatten(<Field>)` | `Flatten<Field>s()` | Flatten nested slices |

### Relationship Hydration

| Generator | Generated Method | Description |
|-----------|-----------------|-------------|
| `Fill(Target,FK)` | `Fill<Target>(<Target>s)` | One-to-one fill by FK |
| `FillSlice(Target,FK)` | `Fill<Target>s(<Target>s)` | One-to-many fill by FK |

### Type Conversion

| Generator | Generated Method | Description |
|-----------|-----------------|-------------|
| `Cast(Interface)` | `Cast<Interface>()` | Cast items to interface |
| `Map(TargetType)` | `Map<TargetType>()` | Convert to another struct type |
| `MapP(TargetType)` | `MapP<TargetType>()` | Convert to pointer of another struct type |

## Examples

### Full Annotation

```go
//colgen:User:StatusID,Unique(RoleID),Index(Email),Group(DepartmentID),Count(Status),Fill(Avatar,UserID)
type User struct {
    ID           int
    Email        string
    StatusID     int
    RoleID       int
    DepartmentID int
    Status       string
    Avatar       *Avatar
}
```

Generated type `Users` (slice `[]User`) will have:
- `IDs() []int`
- `StatusIDs() []int`
- `UniqueRoleIDs() []int`
- `IndexByEmail() map[string]User`
- `GroupByDepartmentID() map[int]Users`
- `CountByStatus() map[string]int`
- `FillAvatar(Avatars)`

### Using Generated Collections

```go
users := Users{user1, user2, user3}

ids := users.IDs()                          // []int{1, 2, 3}
byEmail := users.IndexByEmail()             // map[string]User
byDept := users.GroupByDepartmentID()        // map[int]Users
uniqueRoles := users.UniqueRoleIDs()         // []int (deduplicated)

// Hydrate relationships
avatars := loadAvatars(users.IDs())
users.FillAvatar(avatars)  // sets Avatar field on each user
```

## CLI Flags

| Flag | Description |
|------|-------------|
| `-list` | Use `List` suffix instead of `s` (e.g., `UserList` instead of `Users`) |
| `-imports` | Custom import paths for generated file |
| `-funcpkg` | Package for helper functions |

## Inline Mode

For direct constructor generation without annotations on existing types.

## go:generate Directive

Place at the top of the file containing annotated structs:

```go
//go:generate colgen
```

Or specify input file explicitly:

```go
//go:generate colgen -input=model.go
```
