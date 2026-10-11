# ChiefOfStaff (iOS App)

A local-first, AGPLv3-licensed iOS companion for personal knowledge management (PKM) and AI operating stacks.

## Architecture & Development Milestones

- **Milestone 1 (Active / v0.1.0):** Quick Capture & Ingest Focus
  - Local queueing (SQLite/SwiftData) with Webhook / REST & Email transport.
- **Milestone 2 (Placeholder / v0.2.0):** Public Brain Query Engine
  - Defense-in-depth search over non-private vault notes (`visibility: public` YAML gate + path exclusions).
- **Milestone 3 (Placeholder / v0.3.0):** Executive Dashboard & Operating Council Status
  - Single-pane status display fetching blocker lists, persona updates, and active schedules via REST API.

## Architecture & Features

- **Quick Capture (Ingest):** Capture notes, brainstorms, and to-dos offline with atomic local disk queueing (`QueueManager`) and background dispatch (`NetworkTransport`).
- **Public Query Engine:** Read-only Markdown search using defense-in-depth privacy controls (`VaultParser`).
- **Executive Dashboard:** Status monitoring for active blockers, system metrics, and council agents (`PersonaConfig`).

## Privacy Engine (Defense-in-Depth)

1. **Rule 1 (YAML Gate):** Default Deny. Notes are blocked from indexing unless frontmatter explicitly includes `visibility: public`.
2. **Rule 2 (Path Exclusion):** Configurable folder exclusions (`00_Inbox`, `00_Private`, `.obsidian`, etc.) are stripped prior to parsing.

## Configuration & Branding
Persona roles and system identities are user-configurable via `Configuration/AppConfig.plist` or environment variables.

## Local Configuration Setup

1. Copy the configuration template to create your local config file:
   ```bash
   cp Configuration/AppConfig.plist.template Configuration/AppConfig.plist
   ```

Edit Configuration/AppConfig.plist to set your custom ingestion endpoints and directory rules:

IngestEndpoint: Your REST API or Webhook listener URL.
IgnoredDirectories: Folders to exclude from vault indexing.

Note: Configuration/AppConfig.plist is excluded via .gitignore to prevent leaking personal endpoints or credentials.