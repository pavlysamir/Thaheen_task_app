# Thaheen LMS – Mini Offline Learning Platform 🎓🩺

A clean, offline-first Flutter application built for health-sciences students to browse courses, track learning progress, and watch video lessons with resume and sequential unlock capabilities. Designed Arabic-first with full RTL support and an English toggle.

---

## 🚀 How to Run the App

### Prerequisites

- **Flutter SDK**: 3.22.0 or higher (Tested on Flutter 3.47.5 / Dart 3.13.4)
- **Platforms Supported**: Android, iOS, Windows, macOS, Web

### Steps

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd thaheen_lms
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run unit & widget tests:**

   ```bash
   flutter test
   ```

   _(All 14 tests pass with 100% success)._

4. **Verify static analysis:**

   ```bash
   flutter analyze
   ```

   _(0 errors, 0 warnings, 0 lints)._

5. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🌿 Git Branching Strategy

The repository follows a clean Git Flow model where features and test suites are developed on isolated branches, merged into `develop`, and delivered to `main`:

```
main
  │
  └── develop
        │
        ├── feature/project-setup
        ├── feature/courses
        ├── feature/progress
        ├── feature/player
        ├── feature/rtl-ui
        └── test/progress-tests
```

---

## 🏛️ Architecture & State Management

The project is structured according to **Feature-First Clean Architecture**, balancing clean separation of concerns with pragmatic design to avoid over-engineering.

```
lib/
├── core/                                # Shared infrastructure
│   ├── di/
│   │   └── injection_container.dart       # GetIt Service Locator
│   ├── error/
│   │   └── exceptions.dart                # Domain-specific exceptions
│   ├── localization/
│   │   └── app_localizations.dart         # Arabic-first & English localizations
│   ├── routing/
│   │   └── app_router.dart                # GoRouter with type-safe routes
│   ├── theme/
│   │   └── app_theme.dart                 # Medical/Health-sciences theme
│   └── utils/
│       └── duration_formatter.dart        # mm:ss time formatting
│
├── features/
│   ├── courses/                         # Courses discovery & details
│   │   ├── data/
│   │   │   ├── datasources/             # CoursesAssetDataSource (bundled JSON)
│   │   │   ├── models/                  # CourseModel, SectionModel, LessonModel
│   │   │   └── repositories/            # CoursesRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/                # Course, Section, Lesson
│   │   │   └── repositories/            # CoursesRepository
│   │   └── presentation/
│   │       ├── cubit/                   # CoursesCubit & CoursesState
│   │       ├── pages/                   # CoursesPage & CourseDetailPage
│   │       └── widgets/                 # CourseCard, ContinueWatchingCard, LessonTile
│   │
│   ├── progress/                        # Business rules & persistent progress
│   │   ├── data/
│   │   │   ├── datasources/             # ProgressLocalDataSource (SharedPreferences)
│   │   │   ├── models/                  # LessonProgressModel
│   │   │   └── repositories/            # ProgressRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/                # LessonProgress & LessonStatus
│   │   │   ├── repositories/            # ProgressRepository
│   │   │   └── services/
│   │   │       └── progress_service.dart # Domain Service (Pure business rules)
│   │   └── presentation/
│   │       └── widgets/                 # ProgressBadge
│   │
│   └── player/                          # Video playback orchestration
│       └── presentation/
│           ├── cubit/                   # PlayerCubit & PlayerState
│           ├── pages/                   # LessonPlayerPage
│           └── widgets/                 # PlayerControlsOverlay, RtlSeekBar, PlaybackSpeedSheet
│
└── main.dart                            # App initialization & root provider
```

### Conceptual Domain Separation

- **`courses`**: Owns static course curriculum data (`JSON` → `Models` → `Entities` via `.toEntity()`).
- **`progress`**: Owns all progress calculations, sequential unlock business rules, and local persistence.
- **`player`**: A coordinator orchestrating `VideoPlayerController`, `ProgressService`, and `ProgressRepository` without coupling business decisions into the UI.

### Why flutter_bloc (Cubit)?

- Provides predictable, immutable, and testable state transitions.
- Cubit eliminates the ceremony of verbose event definitions while maintaining clear boundaries between UI and logic.
- UI components reactively rebuild only when relevant state slices change (`BlocConsumer`, `BlocBuilder`).

### Why Domain `ProgressService` Instead of 5 Separate UseCases?

Rather than creating 5 individual use case classes for simple arithmetic calculations, we encapsulated the domain logic inside `ProgressService`:

1. `shouldComplete({currentPositionSec, totalDurationSec})` (The 90% threshold rule).
2. `isLessonUnlocked({lessonId, course, completedLessonIds})` (Sequential unlock rule).
3. `calculateCourseProgress({course, completedLessonIds})` (Course % calculation).
4. `getContinueWatching({courses, progressMap})` (Identifying the most recent unfinished lesson).

This keeps the codebase clean and pragmatic, while allowing **100% pure, fast unit testing** without mocking dependencies.

### Why SharedPreferences for Local Persistence?

- **Zero build friction:** No code generation (`build_runner`), schema migrations, or native compile steps needed.
- **Fast:** Synchronously cached in memory after initial read.
- **Ownership:** Scoped directly inside `ProgressLocalDataSource` where persistence belongs.

---

## ✨ Features Implemented

1. **Courses Screen:**
   - Visual course cards with thumbnail, medical instructor title, lesson count, and real-time progress bar.
   - **"Continue Watching" Card:** Dynamically appears at the top if the student has an unfinished lesson with instant resume.
   - Pull-to-refresh to re-sync progress.

2. **Course Details Screen:**
   - Grouped sections and lessons with formatted durations (`mm:ss`).
   - Dynamic lesson status badges: **لم يبدأ (Not Started)**, **قيد المشاهدة (In Progress)**, **مكتمل (Completed)**, and **مُقفل (Locked)**.
   - **Sequential Unlock:** Lessons unlock in order. Tapping a locked lesson displays a friendly Arabic dialogue explaining the prerequisite.

3. **Lesson Player Screen:**
   - Custom overlay controls: Play/pause, forward/rewind 10 seconds, and seek bar.
   - **Playback Speed Selector:** Modal bottom sheet supporting `1.0x`, `1.25x`, `1.5x`, and `2.0x`.
   - **Auto Resume:** Automatically restores the student's last watched position.
   - **90% Completion Rule:** Triggers automatically at $\ge 90\%$ watched duration, updates local storage, unlocks the next lesson, and shows a celebration notification.
   - **Next Lesson Button:** Intelligently enabled or disabled according to unlock rules.
   - **Fullscreen / Landscape Mode:** Smooth orientation switching.

4. **Arabic-First & RTL Support:**
   - Configured with `Directionality: TextDirection.rtl` by default.
   - App bar language switch button allows instant toggling between Arabic and English.

5. **Error & State Handling:**
   - Gracefully handles loading, empty lists, and missing/corrupted video files with informative fallback cards and retry options (no red screens).

---

## 🧪 Testing

Unit and widget tests are located in `test/`:

- `test/progress_service_test.dart`:
  - ✅ 90% rule under threshold
  - ✅ 90% rule at/above threshold
  - ✅ Edge cases (zero or negative duration)
  - ✅ First lesson always unlocked
  - ✅ Subsequent lessons locked when previous incomplete
  - ✅ Subsequent lessons unlocked when previous complete
  - ✅ Unknown lesson handling
  - ✅ 0% course progress
  - ✅ Fractional course progress (e.g. 25%, 50%, 100%)
  - ✅ Continue watching empty state
  - ✅ Continue watching single in-progress lesson
  - ✅ Continue watching selection of most recently updated lesson
- `test/widget_test.dart`:
  - ✅ `ProgressBadge` completed status rendering
  - ✅ `ProgressBadge` locked status rendering

Run all tests via:

```bash
flutter test
```

---

## ⚖️ Trade-offs & What I'd Do With More Time

### Trade-offs:

- **`SharedPreferences` vs `Hive`/`Isar`/`SQLite`:** For an offline mini-LMS storing lesson IDs and timestamps, `SharedPreferences` provides the most stable, dependency-light solution. If the curriculum expanded to thousands of courses, an embedded relational or key-value database would be preferred.
- **Bundled Assets vs Remote Streaming:** Videos and courses are bundled offline inside `assets/`. In a full production app, video streaming (HLS/DASH) with an encrypted offline download manager would be integrated.

### With More Time:

- **Dark Mode:** Add dark slate theme support for night-time studying.
- **In-Video Bookmarks & Notes:** Enable students to write timestamped notes saved locally.
- **Interactive Quizzes:** Short multiple-choice checkpoints at the end of each lesson before triggering completion.
- **Picture-in-Picture (PiP):** Allow students to take notes while video plays in a floating window.
