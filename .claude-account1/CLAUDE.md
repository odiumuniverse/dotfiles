# CLAUDE.md — Global Instructions

## Language & Communication

- Always respond in Russian
- Be concise: lead with action, skip preamble
- No trailing summaries — user reads diffs themselves

## Development Workflow (all Go projects)

- **Monorepo pattern**: each service has its own `go.mod`, `Makefile`, `vendor/`. Always `cd` into the service directory before running commands
- **Before tests**: `make fmt lint db-test`
- **Single test**: `go test ./path/to/pkg/... -run TestName -v`
- **Pre-commit**: `make pre-commit` (runs mod, generate, fmt, lint, db-test, test)

### Feature Development Process

1. First write tests and describe test scenarios — wait for user approval
2. Only then implement the feature code
3. Run tests to verify

### Bug Fixing Process

1. Write reproduction test that fails
2. Run test to confirm failure
3. Fix the code
4. Run tests to verify fix

## Available Skills — Use Proactively

### Code Generation (use instead of manual editing)

- `/zenrpc` — for JSON-RPC 2.0 services, method signatures, middleware. Trigger: code imports zenrpc, any RPC modifications
- `/mfd-generator` — for DB model/repo generation from PostgreSQL. Trigger: DB schema changes, new tables/columns
- `/pgmigrator` — for SQL migrations. Trigger: schema changes, new migration files
- `/colgen` — for Go collection type generation from struct annotations
- `/rpcgen` — for generating RPC clients (TS/Go/PHP/Swift/Kotlin/Dart) from zenrpc SMD schemas
- `/embedlog` — for structured slog logging with Prometheus metrics
- `/cron` — for cron job management in Go services

### Code Quality (use after writing code)

- `/simplify` — review changed code for reuse, quality, efficiency
- `/code-review:code-review` — full code review of a PR
- `/feature-dev:feature-dev` — guided feature development with architecture focus
- `/feature-dev:code-explorer` — deep analysis of existing codebase features
- `/feature-dev:code-architect` — design feature architectures based on existing patterns

### Infrastructure & Deployment

- `/orbstack` — manage Docker containers/images/volumes, docker-compose, Linux VMs, Kubernetes. Use MCP tools instead of shell docker/kubectl commands
- `/pgmdd` — visual ERD design, reverse engineering PostgreSQL to diagrams

### Maintenance

- `/claude-md-management:revise-claude-md` — update CLAUDE.md with session learnings
- `/claude-md-management:claude-md-improver` — audit and improve CLAUDE.md files

## Available MCP Servers

Use these instead of raw shell commands when possible:

- **tmux** (`mcp__tmux__*`) — manage tmux sessions, execute long-running commands, capture output. Use for builds/tests that may take time
- **orbstack** (`mcp__orbstack__*`) — Docker/VM management. Prefer over `docker` CLI
- **web-reader** (`mcp__web-reader__*`) — read web pages
- **web-search-prime** (`mcp__web-search-prime__*`) — web search
- **obsidian** (`mcp__obsidian__*`) — access Obsidian vault notes
- **context7** (`mcp__context7__*`) — library documentation lookup
- **language-server** (`mcp__language-server__*`) — LSP operations (go-to-definition, references, hover)
- **zai-mcp-server** (`mcp__zai-mcp-server__*`) — custom AI server
- **zread** (`mcp__zread__*`) — enhanced reading

## Enabled Plugins

- **gopls-lsp** — Go language server integration. Use for type checking, references, rename
- **code-review** — automated code review
- **code-simplifier** — simplify and refine code
- **feature-dev** — guided feature development with code exploration and architecture
- **security-guidance** — security best practices review
- **skill-creator** — create/modify custom skills

## Context Economy Tips

- Use `Glob` and `Grep` for targeted file/code search — avoid Agent for simple lookups
- Use `language-server` MCP for go-to-definition instead of manual grep
- Use `context7` MCP to look up library docs instead of web search
- For long-running commands (test suites, builds), use tmux MCP or `run_in_background`
- Prefer `Edit` over full file `Write` — sends only the diff
- When exploring unfamiliar code, use `feature-dev:code-explorer` agent to avoid polluting main context

## Database Defaults

```
PGHOST=localhost  PGUSER=postgres  PGPASSWORD=postgres
PGDATABASE=topscan (dev) / topscan-test (test)
```

## Key Technologies (across projects)

- **Go** with Echo v4, ZenRPC v2 (JSON-RPC 2.0), go-pg ORM
- **PostgreSQL** with generated models (mfd-generator) and migrations (pgmigrator)
- **Testing**: Convey (BDD), `test.Setup(t)` for DB integration tests
- **Docker/OrbStack** for containerization
- **Stripe, AWS, GCP, Slack** integrations
