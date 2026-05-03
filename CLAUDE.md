# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Mix Match Mood (MMM)** is an AI-powered digital wardrobe and stylist app for cross-platform (Android/iOS). The app allows users to upload clothes, get AI-assisted categorization (top, bottom, pants, hat, jewelry), and receive outfit suggestions based on mood, style, or color. Additional features include weather-based recommendations, repeat outfit alerts, "missing piece" finder, and emergency mode for quick outfit creation.

**Core philosophy:** "Easy to use. Pick your style."

**UI/UX:** Modern, minimalist design with white/beige color palette, smooth animations, and micro-interactions.

## Tech Stack Rationale

- **Flutter** was chosen over React Native + Expo for better AI/ML integration with on-device processing (Google Vision ML Kit) while maintaining smooth UI performance.
- **Hive** for offline-first local storage (no cloud sync yet, privacy-first design).
- **Riverpod + Flutter Hooks** for robust state management.
- All AI processing happens on-device to protect user privacy.

## Architecture

```
lib/
├── main.dart                           # App entry point, initializes Hive, defines MaterialApp
├── core/
│   ├── hive_init.dart                 # Hive database initialization
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette (primary: #C9A688, text: #2D2A26, scaffold: #FAF9F6)
│   │   └── app_theme.dart             # ThemeData, light mode with Material 3
│   └── models/
│       ├── clothes.dart               # Hive model: id, name, type, colors[], styles[], occasions[], imagePath, detectionConfidence, createdAt
│       ├── outfit.dart                # Hive model: id, itemIds[], mood, occasion, selectedAt, liked, rating
│       └── user_preferences.dart      # User settings: preferredMoods[], preferredStyles[], wearHistory[], ratingHistory[]
└── screens/
    ├── home_screen.dart               # Main hub with 8 menu options
    ├── upload_screen.dart             # Image picker + cropper for adding clothes (TODO: ML Kit integration)
    ├── mood_picker_screen.dart        # Mood-based outfit suggestions
    ├── style_picker_screen.dart       # Style-based outfit suggestions
    ├── color_picker_screen.dart       # Color-matching outfit suggestions
    ├── weather_screen.dart            # Weather-based reality check
    ├── repeat_alert_screen.dart       # Repeat outfit alerts
    ├── missing_piece_screen.dart      # Find items to complete an outfit (TODO)
    ├── emergency_screen.dart          # Emergency mode for quick outfits (TODO)
```

## Core Features (Priority Order)

**1. Wardrobe Manager (The Closet)**
- Upload & auto-categorize clothes (top, bottom, accessory, hat, jewelry)
- AI detection of color and style from images

**2. Smart Stylist Engine**
- Mood-based suggestions
- Style-based suggestions  
- Color-based suggestions

**3. Environment-Aware Features**
- Reality Check: Weather-appropriate outfit suggestions
- Repeat Alert: Warn when reusing same outfit

**4. Smart Alerts**
- Missing Piece: Recommend accessories that match selected items
- Emergency Mode: One-button simple outfit for rushed days

**5. Learning System**
- Track user preferences (like/dislike suggestions)
- Improve suggestions over time

## Key Dependencies

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for production (Android APK)
flutter build apk --release

# Build for production (iOS)
flutter build ios --release

# Run tests
flutter test

# Run a single test file
flutter test path/to/test_file.dart

# Format code
flutter format .

# Analyze code
flutter analyze
```

## Testing

Tests are in the `test/` directory. To run all tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/<filename>.dart
```

To run tests with coverage:

```bash
flutter test --coverage
```

## Database Structure

The app uses Hive for offline-first storage. Key boxes include:

- `clothes`: Stores clothing items with image paths, detected attributes
- `outfits`: Stores outfit combinations
- `user_preferences`: Stores user settings and history

## Theme & Styling

- Primary color: `#C9A688` (terracotta/beige)
- Text color: `#2D2A26` (dark brown)
- Background: `#FAF9F6` (off-white)
- Secondary color: `#E8E4DC` (light beige)
- Accent colors: `success`=#8DB998, `warning`=#D4A574, `error`=#E57373

The app uses Material 3 with a light theme, custom AppBar and card themes.

## Development Notes

**Important:** Make sure code is working and tested before adding new features.

**Current State:** Early development phase. Several features are implemented as UI only (TODO placeholders):
- `upload_screen.dart` - Image picker works, but ML Kit detection not yet integrated
- `missing_piece_screen.dart` - Logic not implemented
- `emergency_screen.dart` - Logic not implemented
- `color_picker_screen.dart` - Logic not implemented

**TODO List by File:**
- `upload_screen.dart:181` - Implement ML Kit image classification
- `missing_piece_screen.dart` - Implement recommendation logic
- `emergency_screen.dart` - Implement emergency outfit generation
- `weather_screen.dart` - Integrate weather API
- All suggestion screens - Implement filtering and recommendation algorithms

**Next Steps to Complete:**
1. Implement ML Kit via `mlkit_image_labels` package
2. Implement Hive storage and retrieval for clothes/outfits
3. Implement outfit recommendation logic with user preferences
4. Implement weather API integration via `geolocator` + OpenMeteo
5. Implement like/dislike tracking in `user_preferences.dart`
