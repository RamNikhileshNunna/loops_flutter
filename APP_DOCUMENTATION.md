# Loops Flutter App Documentation

## 1. Project Overview

**Loops Flutter** is a mobile client for the [Loops](https://loops.video/) short-form video platform. It is built using **Flutter** and aims to provide a premium, smooth, and feature-rich user experience similar to popular social media apps like TikTok or Instagram Reels.

The app follows a **Clean Architecture** principle but organized by **Features** (Feature-first architecture). This ensures scalability and maintainability.

## 2. Technical Architecture

### 2.1 State Management
The app uses **Riverpod** (specifically `flutter_riverpod` and `riverpod_generator`) for state management. This allows for:
- Dependency Injection (DI).
- Reactive UI updates.
- Separating business logic from UI code.

### 2.2 Navigation
**GoRouter** is used for handling navigation. It supports deep linking and simplifies complex routing scenarios (like nested navigation for the bottom tab bar).

### 2.3 Networking
**Dio** is the HTTP client used for making API requests. It is configured with interceptors to automatically handling authentication tokens and errors.

### 2.4 Code Generation
We use `build_runner` with:
- `freezed`: For immutable data models and unions.
- `json_serializable`: For JSON parsing.
- `riverpod_generator`: For simpler provider syntax.

---

## 3. Code Walkthrough & Workflows

### 3.1 App Initialization (`lib/main.dart`)
This is the entry point of the application.
- **`main()`**: Initializes Flutter bindings and the global `StorageService` (SharedPreferences). It runs the app wrapped in a `ProviderScope`.
- **`routerProvider`**: Defines the navigation graph. It includes a `ShellRoute` for the `MainScreen` (Bottom Navigation Bar) and a separate route for `LoginScreen`. It also handles **Auth Guarding** (redirecting to login if not authenticated).
- **`MainScreen`**: The generic scaffold for the logged-in experience, containing the `BottomNavigationBar`. It maintains a navigation history stack to allow users to "go back" through their tab visits.

### 3.2 Authentication (`lib/features/auth`, `lib/core/auth`)
**Workflow**:
1.  **User opens app**: Checks `AuthRepository.isAuthenticated()`.
2.  **Not logged in**: Redirects to `LoginScreen`.
3.  **Login Flow**:
    - User selects a server (e.g., `loops.video`).
    - App opens a system web browser (`flutter_web_auth_2`) to the server's OAuth page.
    - User logs in and approves the app.
    - Server redirects to `com.example.loopsflutter://login-callback` with an auth code.
    - App intercepts this code in `OAuthService`.
    - `OAuthService` exchanges the code for an Access Token via API.
    - Token is saved securely in `StorageService`.

**Key Classes**:
- `OAuthService`: Handles the complex OAuth handshake and token exchange.
- `AuthRepository`: The facade used by the UI to login, logout, and check status.

### 3.3 The Feed (`lib/features/feed`)
This is the core "For You" experience.
- **`FeedScreen`**: Uses a `PageView.builder` to create a vertically scrolling list of videos. It handles pagination (loading more videos as you scroll).
- **`FeedController`**: A `NotifierProvider` that fetches videos from `VideoRepository` and manages the list of videos. It handles "refresh" and "load more" logic.
- **`VideoPlayerWidget`**: A complex widget responsible for:
    - Initializing the `video_player`.
    - Managing "active" state (only playing effectively when on screen).
    - Displaying overlays (captions, user info).
    - Handling Likes via `VideoActionsRepository`.

### 3.4 Profile System (`lib/features/profile`)
Displays user identity and their content.
- **`ProfileScreen`**: Fetches user details using `CurrentUserController`.
- **tabbed View**: Uses a `NestedScrollView` to allow the header (avatar, bio) to scroll away, leaving the tabs (Videos, Likes) pinned at the top.
- **`ProfileRepository`**: Fetches user details (`/api/v1/accounts/verify_credentials`) and their video feeds.

### 3.5 Explore and Discovery (`lib/features/explore`)
Allows finding new content.
- **`ExploreScreen`**: A `CustomScrollView` composing multiple sections:
    - **Suggested Accounts**: Horizontal list.
    - **Trending Tags**: Horizontal chips acting as filters.
    - **Explore Grid**: Staggered grid of videos for the selected tag.
- **`TrendingTagsFilter`**: Fetches tags from `/api/v1/tags/trending`.

### 3.6 Settings (`lib/features/settings`)
Manages validation and user preferences.
- **`SettingsScreen`**: UI for toggles like "Autoplay", "Dark Mode".
- **`SettingsController`**: Syncs these preferences with the server (`/api/v1/app/preferences`) and local state.

## 4. How the "Back" Button Works
In `MainScreen`, we implemented a custom history stack `_history`.
- Every time a user taps a bottom tab, the index is added to `_history`.
- When the user presses "Back" (Android back button), `PopScope` intercepts it.
- Instead of closing the app, it pops the last index from `_history` and navigates to the previous tab.
- If `_history` has only 1 item, the app closes.

## 5. Skeletal Loading
To make the app feel faster, we use "Skeletons" (shimmer effects) instead of simple spinning circles.
- **`skeletons.dart`**: Contains reusable placeholders (`FeedSkeleton`, `ProfileSkeleton`).
- Screens check `ref.watch(provider).isLoading`. If true and no data exists, they render the Skeleton widget.

---

**Generated by Antigravity AI**
