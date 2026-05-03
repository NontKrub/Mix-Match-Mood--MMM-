# Mix Match Mood (MMM)

AI Stylist and Digital Wardrobe App

## Features

- 📸 Add clothes via camera or gallery
- 🧥 Automatic image recognition (ML Kit)
- 🌈 Color detection and matching
- 😊 Mood-based outfit suggestions
- 🎨 Style-based outfit combinations
- 📱 Offline-first with Hive database
- ⛅️ Weather-aware reality check
- 🔔 Smart alert system
- 🧩 Missing piece finder

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── theme/
│   │   ├── app_colors.dart   # Color palette
│   │   └── app_theme.dart    # Theme configuration
│   └── models/
│       ├── clothes.dart      # Clothes model
│       ├── outfit.dart       # Outfit model
│       └── user_preferences.dart
└── screens/
    └── home_screen.dart      # Main home screen

```

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for production
flutter build apk --release
```

## Technologies Used

- **Flutter 3.41** - UI Framework
- **Hive** - Offline-first local database
- **Google ML Kit** - Image recognition
- **Riverpod** - State management
- **Flutter Hooks** - Reactive UI state

## Development Status

- [x] Project structure setup
- [x] Hive database integration
- [x] Theme and colors configured
- [x] Home screen with navigation
- [ ] Image upload feature
- [ ] Outfit picker implementations
- [ ] Weather service integration
- [ ] Testing app
