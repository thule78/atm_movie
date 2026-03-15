# API Skill

## Goal
Integrate movie data cleanly and securely.

## Rules
- Use movie endpoints only.
- Keep API key in `.env`.
- Never hardcode the API key in Dart files.
- Centralize base URLs and endpoint paths in `core/network/api_constants.dart`.
- Use a dedicated API client for request handling and error mapping.
- Support these feature groups only:
  - movie list
  - movie detail
  - movie recommendations
  - movie videos
  - movie search

## Avoid
- TV endpoints
- season/episode endpoints
- mixed movie/TV abstractions unless product scope changes
