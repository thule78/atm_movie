# State Management Skill

## Goal
Use Provider cleanly without unnecessary rebuilds.

## Rules
- Use `ChangeNotifier` where appropriate.
- Use `context.read()` for actions.
- Use `Consumer` / `Selector` for local reactive updates.
- Avoid high-level `context.watch()` when only a small widget subtree changes.

## Suggested providers
- AuthProvider
- RootNavProvider
- HomeProvider
- ExploreProvider
- MovieDetailProvider
- WatchlistProvider
- CommentProvider
- ProfileProvider
