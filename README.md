## 1. atm_movie - Project Summary
is a Flutter mobile application for discovering movies, watching trailers, saving movies to a personal list, and posting comments. The app focuses on **movie trailer review**, not full streaming.

## 2. Product Scope
### In Scope
- Splash and welcome flow
- Sign up / sign in
- Google login
- Guest login
- Home screen with featured movie and curated sections
- Explore screen with search
- Movie detail screen
- Embedded YouTube trailer playback
- Watchlist / My List
- Profile and edit profile
- Movie comments using Firestore

### Out of Scope
- TV series
- Downloads
- Offline viewing
- Full movie playback
- Subscription or payment flow

## 3. Core User Flows
### First-time user
1. Splash
2. Welcome
3. Auth selection
4. Login / signup / guest
5. Root screen

### Returning user
1. Splash
2. Session check
3. Root screen if authenticated
4. Welcome/Auth if not authenticated

### Main content flow
1. Open Home
2. Browse featured movie or lists
3. Open Movie Detail
4. Play trailer inside app
5. Add to My List or open comments

## 4. Navigation Structure
Primary bottom tabs:
- Home
- Explore
- My List
- Profile
