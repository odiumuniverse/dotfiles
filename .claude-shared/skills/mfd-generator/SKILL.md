---
name: mfd-generator
description: "TRIGGER when: user asks about mfd-generator, database model generation, repo generation, VT service generation, mfd files/XML, or database code scaffolding. Use for generating Go models, repositories, test helpers, and VT admin interfaces from PostgreSQL schemas."
---

# mfd-generator — Database Code Generator

`github.com/vmkteam/mfd-generator` — generates Go models, repositories, validators, search structs, test helpers, and VT (admin) interface code from PostgreSQL database schemas via `.mfd` XML files.

## Installation

```bash
go install github.com/vmkteam/mfd-generator@latest
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `mfd-generator xml` | Generate project base with mfd files, namespaces and entities from DB |
| `mfd-generator xml-vt` | Generate namespaces and entities for VT project sections |
| `mfd-generator xml-lang` | Generate language XML files |
| `mfd-generator model` | Generate Go models for database interaction |
| `mfd-generator repo` | Generate Go repositories for data manipulation |
| `mfd-generator dbtest` | Generate Go helper functions for database testing |
| `mfd-generator vt` | Generate Go files for VT-service creation |
| `mfd-generator template` | Generate JavaScript templates for VT interface |
| `mfd-generator server` | Start web interface for managing mfd files |
| `mfd-generator version` | Show version |

## Generator Groups

### Group 1 — XML Foundation (run first)

Generate `.mfd` XML files from the database:

```bash
# Generate base mfd project file from database
mfd-generator xml

# Generate VT-specific sections
mfd-generator xml-vt

# Generate language files
mfd-generator xml-lang
```

The `.mfd` file (e.g., `docs/model/apisrv.mfd`) is the central config describing all entities, their fields, relations, and settings.

### Group 2 — Go Backend

```bash
# Generate Go models (structs, search params, etc.)
mfd-generator model

# Generate Go repositories for a specific namespace
NS=common mfd-generator repo
NS=target mfd-generator repo

# Generate test helper functions
mfd-generator dbtest
```

### Group 3 — VT Admin Interface

```bash
# Generate Go VT-service files
mfd-generator vt

# Generate JavaScript templates for admin UI
mfd-generator template
```

## Typical Project Workflow

1. Design database schema in PostgreSQL
2. Run `mfd-generator xml` to generate `.mfd` file
3. Edit `.mfd` file to customize entities, relations, search params
4. Run `mfd-generator model` to generate Go model structs
5. Run `mfd-generator repo` per namespace for repository layer
6. Run `mfd-generator vt` + `mfd-generator template` for admin UI

## Makefile Integration

**IMPORTANT: Always check the project Makefile for how mfd-generator is invoked.** Typical targets:

```makefile
# Generate DB models
mfd-model:
    mfd-generator model -c docs/model/apisrv.mfd

# Generate repository for a namespace
mfd-repo:
    mfd-generator repo -c docs/model/apisrv.mfd -n $(NS)

# Generate XML from database
mfd-xml:
    mfd-generator xml -c docs/model/apisrv.mfd
```

## Dictionary / Custom Translations

The `.mfd` file supports a `<Dictionary>` section for custom translations:

```xml
<Dictionary>
    <user>Custom User Label</user>
</Dictionary>
```

Accessible via `Translate(RuLang, "user")` in generated code.

## Web Interface

```bash
mfd-generator server
```

Opens a browser UI for visually managing `.mfd` files, entities, and generation settings.

## Key Concepts

- **Namespace** — logical grouping of entities (e.g., `common`, `target`, `billing`)
- **Entity** — maps to a database table, defines fields, relations, search params
- **MFD file** — XML file containing all entity definitions and generation settings
- Generated files follow the pattern: `model_name.go`, `model_name_search.go`, `model_name_repo.go`
