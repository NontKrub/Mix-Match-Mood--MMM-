# Copilot Instructions for Mix Match Mood (MMM)

## Build, test, and lint commands

Use Flutter CLI from the repo root:

```bash
flutter pub get
flutter analyze
flutter test
flutter test test/<filename>.dart
flutter build apk --release
flutter build ios --release
```

Hive model adapters are required for files using `part '*.g.dart'` in `lib/core/models/`. If generated files are missing, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## High-level architecture

- App startup flow is `lib/main.dart` → `initHive()` (`lib/core/hive_init.dart`) → `MaterialApp(home: HomeScreen())`.
- `HomeScreen` is the navigation hub. It routes by menu-title string matching to feature screens (upload, mood/style/color pickers, weather, repeat alert, missing piece, emergency mode).
- Persistence is local-first with Hive:
  - Boxes: `clothes`, `outfits`, `user_preferences`
  - Data models: `Clothes`, `Outfit`, `UserPreferences` in `lib/core/models/`
  - Access layer: singleton `HiveService` in `lib/core/services/hive_service.dart`
- Feature screens read/write through `HiveService` directly (no repository layer or router abstraction yet).
- Upload flow (`lib/screens/upload_screen.dart`) uses `ImagePicker` + `MLKitService` placeholder analysis, then saves a `Clothes` record to Hive.
- Weather flow (`lib/screens/weather_screen.dart`) uses `Geolocator` + Open-Meteo HTTP call and computes recommendation text in-screen.

## Product intent and feature boundaries (from Project-Initial.md)

- Core app mission: AI stylist + digital wardrobe with the UX promise **“Easy to use. Pick your style.”**
- Target features should map to these modules:
  - Wardrobe Manager: upload garments and auto-tag type/style/color
  - Smart Stylist Engine: outfit generation by mood, style, and color
  - Reality Check: weather-aware outfit suitability
  - Smart Alerts: repeat-outfit alert + missing-piece recommendation
  - Emergency Mode: one-tap quick “safe/simple” outfit
  - Learning System: local like/dislike feedback influencing future suggestions
- Privacy requirement: keep clothing recognition and recommendation logic local-first; do not introduce external image upload by default.
- Platform direction: maintain cross-platform Flutter implementation for Android/iOS.

## Key conventions in this codebase

- Keep the app’s visual identity aligned with existing constants and usage:
  - Primary: `#C9A688`, scaffold: `#FAF9F6`, secondary: `#E8E4DC`, text: `#2D2A26`
  - Shared color/theme definitions live in `lib/core/theme/`.
- Hive-specific conventions:
  - Stable `typeId`s are already assigned: `Clothes=0`, `Outfit=1`, `UserPreferences=2` (do not change once data exists).
  - Box keys are item IDs (`clothes.id`, `outfit.id`); user preferences are stored under key `'prefs'`.
- Most screen state is local (`StatefulWidget`) with in-widget filtering/projection into `List<Map<String, dynamic>>`. Follow this local-state pattern unless explicitly introducing Riverpod usage.
- IDs are generated as timestamp-based strings in several flows (e.g., upload/emergency outfit). Keep ID formats consistent when adding related features.
- Product direction from project docs (`README.md`, `CLAUDE.md`): privacy-first local processing, offline-first storage, and the core UX line “Easy to use. Pick your style.”
- Current roadmap expectation from project brief: keep code working before adding new features, and prioritize concrete implementation of upload intelligence, recommendation logic, weather integration, and feedback-based personalization.
