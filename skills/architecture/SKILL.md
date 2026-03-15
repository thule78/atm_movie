# Architecture Skill

## Goal
Keep `atm_movie` aligned with a senior-level Flutter architecture.

## Rules
- Use feature-first structure.
- Keep `router/` as a first-class folder.
- Keep shared/global code in `core/`.
- Keep feature-specific logic inside the feature folder.
- Use `RootScreen` + `IndexedStack` for the bottom navigation shell.
- Do not introduce TV/download/subscription logic.

## Required folders
- `router/`
- `core/`
- `features/`

## Output standard
Every architecture decision must reduce confusion, avoid rebuild issues, and respect movie-only scope.
