# BookReader — Flutter eBook Reader MVP

A clean, offline-first mobile eBook reader built with Flutter. Supports EPUB and FB2 formats with Text-to-Speech, customizable reading settings, and local persistence.

---

## 📱 Features

- **Bookshelf** — Browse your library sorted by last opened date
- **EPUB & FB2 support** — Add books via file picker
- **Reader** — Render EPUB content with customizable settings
- **Reading settings** — Font family/size, line spacing, text alignment, themes (Light/Sepia/Dark)
- **Reading modes** — Scroll (continuous) and Pagination (chapter-by-chapter)
- **Text-to-Speech** — Play/Pause/Stop with rate control using platform TTS
- **Progress tracking** — Auto-saves and restores reading position
- **Offline-first** — No internet, no accounts, no cloud sync

---

## 🏗 Architecture

The app follows **Clean Architecture** with three layers:

```
lib/
├── core/               # Constants, theme, shared utilities
├── data/               # Hive repositories, EPUB data source
│   ├── datasources/    # EpubDataSource (epubx parsing)
│   └── repositories/   # BookRepositoryImpl, SettingsRepositoryImpl
├── domain/             # Business logic (entities, repository contracts)
│   ├── entities/       # Book, ReadingSettings (Hive models)
│   └── repositories/   # Abstract repository interfaces
└── presentation/       # Flutter UI (Riverpod state + widgets)
    ├── bookshelf/       # Bookshelf screen, BookCard widget
    └── reader/          # Reader screen, Settings panel, TTS controls
```

### State Management: **Riverpod**
- `booksProvider` — `AsyncNotifier<List<Book>>` for the bookshelf
- `readingSettingsProvider` — `AsyncNotifier<ReadingSettings>` for persisted settings
- `ttsProvider` — `Notifier<TtsState>` for TTS control
- `readerProvider` — `Notifier<ReaderState>` for chapter/page state

### Local Storage: **Hive**
- `Box<Book>` — Stores all book metadata and reading progress
- `Box<ReadingSettings>` — Persists global reading preferences

---

## 📦 Libraries

| Library | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `hive` / `hive_flutter` | Local database (fast, offline, no SQL) |
| `file_picker` | Pick EPUB/FB2 files from device storage |
| `epubx` | Parse EPUB files (metadata, chapters, cover) |
| `flutter_html` | Render HTML chapters from EPUB |
| `flutter_tts` | Platform TTS (Android/iOS built-in) |
| `path_provider` | App documents directory |
| `uuid` | Generate unique book IDs |
| `archive` | ZIP/EPUB archive handling |
| `percent_indicator` | Reading progress bar |

---

## ⚙️ Getting Started

### Prerequisites

- Flutter SDK >= 3.29.0 (stable channel)
- Android SDK (for Android builds) or Xcode 14+ (for iOS builds)

### Run on Device

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run tests
flutter test
```

### Build Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (unsigned)
flutter build apk --release

# Release AAB (for Play Store)
flutter build appbundle --release
```

### Build iOS

```bash
# Build without signing (for CI or testing)
flutter build ios --release --no-codesign
```

#### iOS Signing for Production

For App Store / TestFlight distribution:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set your **Team** in Signing & Capabilities
3. Set your **Bundle Identifier** (e.g., `com.yourcompany.bookreader`)
4. Build & Archive via Xcode Product → Archive

---

## 🔐 CI/CD Secrets

For GitHub Actions iOS distribution (optional):

| Secret | Description |
|---|---|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded `.p12` distribution certificate |
| `APPLE_CERTIFICATE_PASSWORD` | Password for the `.p12` file |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Base64-encoded `.mobileprovision` |
| `APPLE_TEAM_ID` | Apple Developer Team ID |

No secrets are required for Android debug builds.

For release signing on Android, create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=../keystore.jks
```

---

## 🧪 Tests

```bash
flutter test
```

Tests are in `test/domain_test.dart` and cover:
- Book entity creation and copyWith
- ReadingSettings defaults and updates
- Book sorting by last opened date

---

## 📋 Project Structure

```
book_reader/
├── .github/workflows/
│   ├── android.yml          # Android APK/AAB CI build
│   └── ios.yml              # iOS unsigned build
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── lib/
│   ├── main.dart            # App entry point (Hive init, ProviderScope)
│   ├── app.dart             # MaterialApp with theme
│   ├── core/
│   │   ├── constants/       # AppConstants (formats, font sizes, etc.)
│   │   └── theme/           # AppTheme (light/dark/reader themes)
│   ├── data/
│   │   ├── datasources/     # EpubDataSource
│   │   └── repositories/    # Hive-backed implementations
│   ├── domain/
│   │   ├── entities/        # Book, ReadingSettings (+ Hive adapters)
│   │   └── repositories/    # Abstract interfaces
│   └── presentation/
│       ├── bookshelf/       # BookshelfScreen, BookCard, booksProvider
│       └── reader/          # ReaderScreen, SettingsPanel, TtsControls
├── test/
│   └── domain_test.dart     # Unit tests
└── pubspec.yaml
```
