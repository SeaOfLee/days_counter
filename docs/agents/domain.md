# Domain Docs Layout

This is a **single-context** repository: one `CONTEXT.md` at the repository root describes the whole project, and `docs/adr/` holds architecture decision records (ADRs).

## Reading domain docs

When skills like `to-spec` or `domain-modeling` run, they:

1. Read `/CONTEXT.md` (if it exists) to understand the project, its purpose, and key constraints
2. Read all `*.md` files under `docs/adr/` to see what architectural decisions have been made

If `CONTEXT.md` does not exist, create it with:

- **Project purpose**: what the app is, why it exists, who it's for
- **Current state**: what's done, what's not, key phases or milestones
- **Technology stack**: languages, frameworks, key dependencies
- **Key constraints**: platform limits, deployment rules, non-functional requirements
- **Consumer rules**: how to read this file and when to update it

ADRs should be titled `NNNN-title.md` (e.g. `0001-flutter-over-native.md`) and follow the [Nygard template](https://github.com/adr/madr/blob/main/template/adr-template.md) or similar.

## Multi-context layouts

If this becomes a monorepo later, replace this with a `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files (one per package, one per domain, etc.) and per-context `adr/` directories. Each skill will then read the map, find the relevant context(s), and proceed.
