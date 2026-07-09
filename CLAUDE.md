# CLAUDE.md

Guidance for Claude Code (and other agents) working in this repo.

## What this is

SnapFlow — Flutter app that turns photos into structured step-by-step
workflow manuals (拍照生成操作手册). Targets field workers who can't type
easily: camera capture + voice-to-text + image annotation, saved as
Manual → Step → StepImage, exportable as PDF.

## Stack

- Flutter >=3.24, Dart >=3.5
- State: `flutter_riverpod` (^2.5.1) — `Provider`/`FutureProvider`/`StateProvider`, no code-gen annotations in use
- Persistence: `drift` (SQLite) — schema in `lib/core/db/tables.dart`, generated code in `database.g.dart`
- Files: three-tier storage under app documents dir — `originals/`, `edited/` (post image-editor), `thumbnails/`
- PDF export: `pdf` + `printing`
- Voice: `record` for capture, ASR is a pluggable interface with an offline no-op fallback (`voice_to_text_service.dart`)

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regen database.g.dart after touching tables.dart
flutter analyze
flutter test
flutter build apk --release
```

CI (`.github/workflows/build.yml`) runs analyze + test + builds Android/iOS/Linux on every push to `main` and on `v*` tags; pushes a rolling prerelease under the `latest` tag on main.

## Architecture

Clean-architecture-lite, feature-first. Each feature under `lib/features/<name>/` may have `domain/` (entities, repository interface), `data/` (impl), `presentation/` (pages, widgets).

```
lib/
├── app.dart, main.dart
├── core/
│   ├── db/            drift tables + generated database
│   ├── files/         FileService — three-tier image storage, deleteManualImages()
│   └── theme.dart     SnapFlowTheme (teal-green #0D9488)
├── features/
│   ├── manual/        core CRUD — Manual/Step/StepImage, home + detail pages
│   ├── capture/       camera/gallery abstraction
│   ├── editor/        image editor (crop/rotate/color tools)
│   ├── voice/         ASR interface + hold-to-record button
│   ├── export/        PDF exporter
│   ├── import_export/ JSON export/import (UTF-8 explicit decode — CJK bug history)
│   ├── tag/           Tag CRUD + manual tagging
│   └── template/      built-in + user templates, template picker sheet
└── shared/
    ├── providers.dart     top-level Riverpod providers (db, fileService, manualRepository, tags, sort/filter state)
    └── widgets/           EmptyState, SnapToast, SnapSheet, SnapIconButton
```

## Data model

`Manual 1─* Step 1─* StepImage`, plus `Tag *─* Manual` via `ManualTags`, and standalone `UserTemplates`.
Cascade deletes are defined in `tables.dart` (`onDelete: KeyAction.cascade`) — deleting a Manual cascades to its Steps and StepImages at the DB level; `ManualRepositoryImpl.deleteManual` additionally calls `FileService.deleteManualImages` to clean up on-disk files, since drift cascade only covers rows, not files.

## Conventions

- UI copy is Chinese; keep new user-facing strings Chinese unless the user asks otherwise.
- Delete flows always confirm via `AlertDialog` (取消/删除) before mutating, then invalidate the relevant Riverpod provider and show `SnapToast.show(context, ..., success: true)`.
- Riverpod providers live in `shared/providers.dart` or co-located `*_provider` files inside a feature's `presentation/` or `domain/`; prefer `FutureProvider` for repo-backed async reads and `StateProvider` for local UI state (filters, sort, selection).
- Repository interfaces (`domain/*_repository.dart`) are implemented once in `data/*_repository_impl.dart`; tests substitute a hand-written stub implementing the interface (see `test/widget/home_page_test.dart` `_StubRepo`) rather than mocking.
- `SnapToast` schedules a 2400ms `Timer`; widget tests that trigger a toast must drain it before the test ends (`await tester.binding.delayed(const Duration(milliseconds: 2500));`) or `flutter test` fails on a pending timer.
- No comments explaining *what* code does; only *why*, and only when non-obvious (existing code follows this — e.g. the timer-drain comment in `manual_detail_page_test.dart`).
