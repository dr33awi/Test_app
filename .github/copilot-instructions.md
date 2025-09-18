# Copilot Instructions for test_athkar_app

## Project Overview
- This is a Flutter mobile application, with code and assets organized for cross-platform (Android, iOS, Windows, Linux, macOS) support.
- Main app logic is in `lib/`, with features grouped by domain (e.g., `asma_allah`).
- The project uses custom theming, widgets, and localized assets (fonts, images, JSON data).

## Key Architectural Patterns
- **Feature-based structure:** Each feature (e.g., `asma_allah`) has its own models, widgets, and logic under `lib/features/`.
- **Theming:** App-wide theming is managed in `app/themes/` and used throughout widgets (see `app_theme.dart`).
- **Widgets:** Custom widgets are in `lib/features/<feature>/widgets/`. Example: `asma_allah_widgets.dart` defines reusable cards and headers for displaying names of Allah.
- **Models:** Data models (e.g., `AsmaAllahModel`) are defined per feature in `models/` subfolders.
- **Assets:** JSON data, images, and fonts are in `assets/` and referenced in code and `pubspec.yaml`.

## Developer Workflows
- **Build:** Use standard Flutter commands:
  - `flutter pub get` to fetch dependencies
  - `flutter run` to launch the app
  - `flutter build apk` or `flutter build ios` for production builds
- **Testing:** No custom test instructions found; use `flutter test` for any present tests.
- **Debugging:** Use Flutter DevTools or IDE-integrated debugging.
- **Platform-specific:** Android and iOS native code is under `android/` and `ios/`.

## Project-Specific Conventions
- **Color Palette:** Olive green shades are defined as constants in widgets (see `asma_allah_widgets.dart`).
- **Localization:** Arabic text and fonts are used throughout; ensure RTL and font support.
- **Widget Reuse:** Prefer composing new UI from existing widgets (e.g., `OliveAsmaCard`, `SimpleOliveHeader`).
- **Dark Mode:** Many widgets check `context.isDarkMode` for theming.
- **Minimal Animation:** Some widgets are intentionally simple (see comments in `asma_allah_widgets.dart`).

## Integration Points
- **Assets:** All assets must be declared in `pubspec.yaml`.
- **Themes:** Use `AppTheme` and related classes for consistent styling.
- **Custom Painters:** Islamic patterns are rendered with custom painters (see `IslamicPatternPainter`).

## Examples
- To add a new feature, create a folder under `lib/features/`, add `models/`, `widgets/`, and update navigation as needed.
- To add a new card style, follow the pattern in `asma_allah_widgets.dart` (stateless, themed, reusable).

## References
- Main entry: `lib/main.dart`
- Example feature: `lib/features/asma_allah/`
- Theming: `lib/app/themes/`
- Assets: `assets/`, `pubspec.yaml`

---
For questions, follow Flutter/Dart best practices unless overridden above. Update this file if you introduce new conventions or workflows.
