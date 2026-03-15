# Firebase Skill

## Goal
Use Firebase for authentication and user-generated app data.

## Setup rules
- Android Firebase config file must exist at `android/app/google-services.json`.
- Initialize Firebase before app flow checks auth state.
- Auth methods allowed:
  - Email/Password
  - Google
  - Anonymous guest

## Firestore usage
Store:
- user profile details
- watchlist data
- movie comments

## Recommended collections
- `users/{userId}`
- `users/{userId}/watchlist/{movieId}`
- `movies/{movieId}/comments/{commentId}`

## Security rules intent
- users can edit only their own profile
- users can manage only their own watchlist
- authenticated users can post comments
