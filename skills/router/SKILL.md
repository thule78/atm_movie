# Router Skill

## Goal
Keep navigation predictable and bottom tabs persistent.

## Rules
- Put route definitions in `router/`.
- Use a dedicated `RootScreen` for bottom navigation.
- Switch tabs inside `RootScreen`; do not push new tab pages.
- Use `IndexedStack` to preserve tab state.

## Push routes allowed for
- movie detail
- trailer player
- comments
- edit profile
- auth-related screens before root
