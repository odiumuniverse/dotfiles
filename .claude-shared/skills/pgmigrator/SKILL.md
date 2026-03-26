---
name: pgmigrator
description: "TRIGGER when: user asks about database migrations, pgmigrator, creating SQL migration files, running/planning/verifying migrations, or PostgreSQL schema changes. Use for managing incremental PostgreSQL migrations."
---

# pgmigrator — PostgreSQL Migration Tool

`github.com/vmkteam/pgmigrator` — simple CLI for incremental (up-only) PostgreSQL migrations. Designed for local development and staging environments.

## Installation

```bash
go install github.com/vmkteam/pgmigrator@latest
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `pgmigrator plan` | Preview pending migrations without executing |
| `pgmigrator run` | Execute all pending migrations |
| `pgmigrator dryrun` | Test migrations in a transaction that rolls back |
| `pgmigrator skip` | Mark migrations as completed without executing |
| `pgmigrator last` | Show recently applied migrations |
| `pgmigrator verify` | Validate migration integrity via MD5 checksums |
| `pgmigrator init` | Generate default `pgmigrator.toml` config |
| `pgmigrator redo` | Re-execute the most recent migration |

## Migration File Naming

Pattern: `YYYY-MM-DD-<description>.sql`

```
2024-01-15-create-users.sql
2024-01-16-add-email-index.sql
2024-02-01-create-orders-NONTR.sql
2024-02-05-manual-data-fix-MANUAL.sql
```

### Special Suffixes

| Suffix | Behavior |
|--------|----------|
| `-NONTR.sql` | Runs outside transaction (for concurrent index creation, etc.) |
| `-MANUAL.sql` | Ignored by pgmigrator (manual-only migrations) |

### Why Date-Based Naming

- More transparent than version numbers
- Reduces merge conflicts in team development
- Easy to see migration history chronologically

## Configuration

`pgmigrator.toml` must be in the migrations directory:

```toml
[database]
host = "localhost"
port = 5432
user = "postgres"
password = "postgres"
database = "myapp"

[settings]
statement_timeout = "30s"
file_mask = "*.sql"
```

Generate default config:
```bash
pgmigrator init
```

## Typical Workflow

1. Create migration file: `2024-03-14-add-status-column.sql`
2. Preview: `pgmigrator plan`
3. Test: `pgmigrator dryrun`
4. Apply: `pgmigrator run`
5. Verify integrity: `pgmigrator verify`

## Creating a New Migration

```bash
# Create a new migration file with today's date
touch migrations/$(date +%Y-%m-%d)-description.sql
```

Write SQL in the file:
```sql
ALTER TABLE users ADD COLUMN status TEXT NOT NULL DEFAULT 'active';
CREATE INDEX idx_users_status ON users (status);
```

For non-transactional operations (e.g., concurrent index):
```bash
touch migrations/$(date +%Y-%m-%d)-add-concurrent-index-NONTR.sql
```

```sql
CREATE INDEX CONCURRENTLY idx_users_email ON users (email);
```

## Database Tracking

pgmigrator creates a tracking table storing:
- Filename
- Execution timestamp
- MD5 checksum (for `verify` command)
- Transactional flag

## Key Design Decisions

- **Up-only**: no down migrations — simpler, safer
- **PostgreSQL only**: highly specialized, uses PG-specific features
- **File-based**: works with SQL files, not Go code
- **Date-based naming**: avoids version number conflicts
