---
name: pgmdd
description: "TRIGGER when: user asks about pgmdd, MicroOLAP Database Designer for PostgreSQL, visual ERD design, reverse engineering PostgreSQL database to diagram, generating SQL from diagram, or syncing diagram changes to a live PostgreSQL database."
---

# pgmdd — MicroOLAP Database Designer for PostgreSQL

GUI desktop tool (Windows/.exe, works on macOS/Linux via Wine) for visual ERD design, reverse engineering, SQL generation, and database synchronization for PostgreSQL 7.3 through 17+.

Official site: http://www.microolap.com/products/database/postgresql-designer/
PDF manual: http://www.microolap.com/products/database/postgresql-designer/help/pgmdd_en.pdf

## Installation

1. Download `pgmdd.zip` from the official site
2. Unzip and run `PgMDD.exe` (standalone, no installer required)
3. On macOS/Linux: run via Wine/WineHQ

## Core Operations

### Connect to Database
`Database | Connect` or `Ctrl+Shift+N`
- Opens Connection Manager
- Create/select a connection profile (host, port, user, password, database)

### Reverse Engineer (DB → Diagram)
`File | Reverse Engineer | PostgreSQL database` or `Ctrl+R`

Options tab:
- "Reverse Engineer references" — extracts foreign keys
- "Auto layout objects after reverse engineering"
- "Color reversed objects"

Selection tab — pick from: Tables, Views, Stored Procedures, Types & Domains

### Generate Database (Diagram → SQL → DB)
`Database | Generate Database` or `Ctrl+G`

Tabs:
- **Database & Tables** — tables, PKs, FKs, constraints, indexes, triggers, defaults, comments, DROP options
- **Views & Stored Routines** — functions, procedures, views
- **Owners & Privileges** — ownership and ACL (GRANT/REVOKE)
- **Options** — identifier case (Mixed = preserve original), type names (PostgreSQL-specific vs ANSI SQL), pre-generation validation, post-generation action:
  - Execute internally via SQL Executor
  - Open with external `.sql` app
  - Save only (don't run)
- **Selection** — choose specific Tables, Routines, Views, Types, Sequences

Flow: OK → SQL script → SQL Executor → review/edit → Execute SQL

### Modify Database (Sync Diagram Changes to Live DB)
`Database | Modify Database` or `Ctrl+M`

1. Connects to target DB
2. Reverse engineers current state
3. Diffs against diagram
4. Shows list of changes — check/uncheck per-object
5. Click "Generate SQL" → SQL Executor → Execute SQL

### SQL Executor (Built-in)
- `Alt+F9` — Execute script in single transaction
- Script slicing: separate tabs for each result set
- Code completion, syntax validation
- Supports PostgreSQL types, functions, columns

### ACL Manager
- Manage GRANT/REVOKE at object level

## Export / Reports
- Export diagram as: SQL script, EMF, PNG, GIF, JPG, BMP
- Generate HTML report with hyperlinked sections and diagram images

## Universal Reverse Engineering
Can also import schemas from: MySQL, Oracle, MSSQL, MS Access

## PostgreSQL Version Support
- PostgreSQL 7.3 through 17+
- v1.11.0: added PostgreSQL 9.5 + SSH tunneling
- v1.12.0: PostgreSQL 10.x
- Later: PostgreSQL 11, 12, 16, 17

## Known Limitations
- ANSI `RETURNS TABLE` syntax in functions not supported
  → Use `OUT` parameters with `SETOF RECORD` instead
- GUI-only; no CLI interface

## Typical Workflow

1. Connect to PostgreSQL (`Ctrl+Shift+N`)
2. Reverse engineer existing DB (`Ctrl+R`) — select objects, click OK
3. Review/modify diagram — add tables, columns, FK relations, indexes
4. Validate and generate SQL (`Ctrl+G`) — review in SQL Executor
5. Execute SQL against target DB
6. For incremental changes: `Modify Database` (`Ctrl+M`) to sync diff only

## Tips

- When generating, use **Mixed case** for identifiers to preserve original naming
- Use "Save only" post-generation action to review SQL before executing
- For concurrent index creation, run the `CREATE INDEX CONCURRENTLY` statement manually after generation (pgmdd doesn't handle non-transactional DDL)
- Connection profiles are stored in the app; update them if the DB host/credentials change
- For PostgreSQL 16/17: use the latest pgmdd version (1.16.1173+)
