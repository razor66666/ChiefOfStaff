# ChiefOfStaff (iOS App)

A local-first, AGPLv3-licensed iOS companion for personal knowledge management (PKM) and AI operating stacks.

## Architecture & Development Milestones

- **Milestone 1 (Active / v0.1.0):** Quick Capture & Ingest Focus
  - Local queueing (SQLite/SwiftData) with Webhook / REST & Email transport.
- **Milestone 2 (Placeholder / v0.2.0):** Public Brain Query Engine
  - Defense-in-depth search over non-private vault notes (`visibility: public` YAML gate + path exclusions).
- **Milestone 3 (Placeholder / v0.3.0):** Executive Dashboard & Operating Council Status
  - Single-pane status display fetching blocker lists, persona updates, and active schedules via REST API.

## Configuration & Branding
Persona roles and system identities are user-configurable via `Configuration/AppConfig.plist` or environment variables.