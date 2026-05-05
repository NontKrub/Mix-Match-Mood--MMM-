# MMM Session Memory (Handoff)

Last updated: 2026-05-04

## What was done

1. **Project setup and stability**
- Added and updated `.github/copilot-instructions.md` based on `README.md`, `CLAUDE.md`, and `Project-Initial.md`.
- Fixed major compile/runtime issues across screens and services.
- Added `hive_generator` and generated:
  - `lib/core/models/clothes.g.dart`
  - `lib/core/models/outfit.g.dart`
  - `lib/core/models/user_preferences.g.dart`
- Updated Hive init to register adapters + open typed boxes.

2. **iOS environment work**
- Installed iOS prerequisites available via terminal:
  - `cocoapods` (pod 1.16.2)
  - `mas`
  - `xcodes`
- Switched to full Xcode and installed iOS simulator runtime.
- Booted simulator (`iPhone 17 Pro`) and ran app successfully.

3. **Important iOS caveat**
- Running from the original path with parentheses (`Mix Match Mood (MMM)`) can trigger a Flutter native-assets tooling crash on iOS.
- Successful simulator run was done from a temporary path without parentheses:
  - `/Users/nont/MyProject/Mix-Match-Mood-MMM-ios-run`

4. **Feature development started (Project-Initial alignment)**
- Added `lib/core/services/stylist_service.dart` for reusable outfit generation/filtering.
- Expanded `HiveService` feedback APIs:
  - like/dislike/rating handling
  - preference updates
  - wear history utilities
- Updated feature screens toward required behavior:
  - `mood_picker_screen.dart`
  - `style_picker_screen.dart`
  - `color_picker_screen.dart`
  - `repeat_alert_screen.dart`
  - `emergency_screen.dart`
  - `missing_piece_screen.dart`
  - `upload_screen.dart`

## Current status / known issues

1. **Validation status improved**
- Replaced the flaky animated `HomeScreen` widget smoke test with stable model-focused tests in `test/widget_test.dart`.
- Safe-path verification now passes:
  - `flutter pub get`
  - `dart analyze` (infos only)
  - `flutter test` (**All tests passed**)

2. **Analyzer state**
- Analyzer mostly reports infos/lints (`prefer_const_*`, etc.).
- No major compile-blocking Dart errors were the main issue at this stage.

3. **Missing Piece feature improved**
- `missing_piece_screen.dart` now supports selected-set analysis:
  - User picks one **top** and one **bottom/pants**.
  - App recommends matching finishing pieces (accessory/jewelry/hat) from wardrobe using color/style/occasion overlap scoring.
  - If no matches exist, app provides buy suggestions (watch/bag/scarf) tailored to selected set.
- Gap analysis now counts `pants` as `bottom` to avoid undercount.

4. **Stylist learning logic improved**
- `stylist_service.dart` now applies stronger local learning weights:
  - preference-aware scoring from `preferredStyles`
  - positive/negative feedback scoring from liked/disliked/rated outfits
  - repeat reduction via wear-history penalties
  - preferred-color seeding from positively rated outfit history
- Outfit generation now also harmonizes target colors across top/bottom/accessory picks for better cohesion.

5. **Weather reality-check logic improved**
- `weather_screen.dart` now implements explicit Project-Initial context rules:
  - rain -> avoid sandal/open-toe guidance
  - hot -> avoid wool/heavy knit guidance
  - cold -> warm layer guidance
  - cold office mode -> blazer recommendation
- Added condition summary chips and dynamic recommendations/tips tied to weather code + temperature.

6. **Wardrobe metadata + repeat-alert behavior improved**
- Added `season` and `lastWorn` support in clothes model:
  - `Clothes.seasons` (default `all-season`)
  - `Clothes.lastWorn` timestamp
- Upload flow now includes a **Season selector** and persists selected seasons.
- `markOutfitAsWorn` now updates `lastWorn` for every item in the outfit.
- Added `archivedOutfitIds` to user preferences and wired archive/unarchive APIs in `HiveService`.
- Repeat Alert screen now:
  - supports archive/unarchive actions per outfit
  - can show/hide archived outfits
  - displays repeat notification with archive quick action
  - aligns with requirement to mark repeated outfits as archived.

7. **Onboarding + app navigation structure implemented**
- Added first-run onboarding flow to collect preferred moods/styles and persist them in `UserPreferences`.
- Added `onboardingCompleted` preference flag and service API (`isOnboardingComplete`, `completeOnboarding`).
- Updated app startup (`main.dart`) to route:
  - first run -> `OnboardingScreen`
  - returning user -> `AppShellScreen`
- Implemented bottom navigation shell with required tabs:
  - Home, Closet, Outfit Gen, Profile
- Added new screens:
  - `closet_screen.dart` (wardrobe manager list with metadata and delete/add actions)
  - `outfit_gen_screen.dart` (hub for mood/style/color/emergency generation)
  - `profile_screen.dart` (preference management + wardrobe stats)

8. **Repeat-photo and weather-context improvements**
- Added repeat photo support to `Outfit`:
  - new field `referencePhotoPath` (Hive persisted)
  - `HiveService.saveOutfitReferencePhoto(...)` to store/update photo
- Repeat Alert now allows saving/updating a reference photo per repeated outfit:
  - quick action in repeat snackbar
  - camera first, gallery fallback
  - UI indicator when photo is saved
- Weather logic now includes an automatic office-context heuristic:
  - if weekday + work hours + low movement, cold-office mode is auto-suggested
  - users can still manually override via existing switch
  - contextual hint text is displayed when auto office context is detected.

## Next session: exact continuation plan

1. Run iOS simulator again from safe path and confirm core flows:
   - Upload & save clothes
   - First-run onboarding and bottom nav routing
   - Closet tab item list/add/delete behavior
   - Generate outfit by mood/style/color
   - Weather screen loads
   - Repeat Alert wear-count behavior
   - Missing Piece set analyzer + matching recommendations
   - Emergency Mode generation
2. Re-run iOS simulator test pass from safe path and verify updated weather + stylist + repeat archive behavior interactively.
3. Real ML visual identification remains heuristic and should be replaced with production ML Kit labeling/classification.
4. Once stable, decide whether to:
   - keep working from safe path, or
   - rename/move the main project directory to remove parentheses.

## Useful commands

```bash
# iOS simulator (safe path)
cd "/Users/nont/MyProject/Mix-Match-Mood-MMM-ios-run"
flutter run -d <simulator-id>

# validation
dart analyze
flutter test

# regenerate Hive adapters (if model fields change)
dart run build_runner build --delete-conflicting-outputs
```
