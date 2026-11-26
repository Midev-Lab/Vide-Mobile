# Vide

Vide is a Flutter mobile study companion for university students. It brings study chat, focus sessions, and attachment tools into one app.

The web app is at [vide.midev.ng](https://vide.midev.ng). This repository contains the mobile app.

## Features

- **Study chat and composer** with study-mode selection and attachment controls.
- **Focus timer** with persistent idle, running, and paused states, duration presets, and header controls.
- **Attachment sheet** with recent photos, gallery and document pickers, and a camera-based note scanner.
- **App drawer** with navigation, recent chats, and a New study action.
- Flashcards, study profile, and All chats are planned or still in progress.

Some screens have working UI and native selection flows but are not yet connected to backend actions. See [Known limitations](#known-limitations).

## Build status

| Area | Status |
|------|--------|
| Theme tokens, shared widgets, and navigation | Done |
| App drawer and New study navigation | Done |
| Focus timer UI, persistence, and controls | Done |
| Chat home and composer | In progress |
| Attachment sheet and native pickers | In progress |
| Camera scanner and capture review | Implemented; device verification required |
| Flashcards | Not started |
| Study profile | Not started |
| All chats | Not started |

## Getting started

Install Flutter using the [official guide](https://docs.flutter.dev/get-started/install), then run:

```bash
git clone https://github.com/Midev-Lab/Vide-Mobile.git
cd Vide-Mobile
flutter pub get
flutter run
```

The current app starts at `/chat` and uses the light theme. The mobile UI can run without backend credentials; backend integrations are not complete.

## Using the focus timer

1. Tap the stopwatch at the right side of the chat header.
2. Choose a preset or adjust the duration, then tap **Start focus**.
3. Tap the running pill to pause, resume, or end the session.

The timer is persisted across app restarts and calculates running time from its end time. There is no timer-state debug override.

## Previewing chat quota states

In debug builds, the Add chat card can be previewed with:

```bash
flutter run --dart-define=VIDE_DEBUG_CHAT_QUOTA=unknown
flutter run --dart-define=VIDE_DEBUG_CHAT_QUOTA=0
flutter run --dart-define=VIDE_DEBUG_CHAT_QUOTA=1
flutter run --dart-define=VIDE_DEBUG_CHAT_QUOTA=5
```

The production quota defaults to unknown until a real quota source is connected; it does not invent a remaining-chat count.

## Camera and permissions

Camera permission is not requested when the attachment sheet opens. Tap **Scan notes** to request it. Recent photos use the platform photo-library permission, and Files opens the native document picker.

The iOS camera and photo usage descriptions are in `ios/Runner/Info.plist`; Android declares the `CAMERA` permission in `android/app/src/main/AndroidManifest.xml`. The iOS simulator has no usable camera, so it displays the static scanner fallback. Verify granted camera permission, live preview, scanner transition, capture, and review on a physical device.

## Project structure

```text
lib/
  core/
    router/                 Named routes and app router
    storage/                Existing app storage
    theme/                  Theme tokens, text styles, and icon registry
  features/
    chat/
      attach/                Sheet, picker/camera services, scanner, and widgets
      presentation/          Chat screens
    focus/
      state/                 App-wide focus timer controller
      widgets/               Header timer and popover
    quota/                   Chat quota model, repository, and providers
  shared/
    dashboard/               App shell and drawer
    widgets/                 Shared UI components
test/                        Widget and controller tests
```

Screens navigate through named routes registered centrally. Keep UI in Flutter/Dart, use theme tokens for visual styling, and render Phosphor icons through `AppIcon` with glyphs from `AppIcons`.

## State and dependencies

- Flutter and Dart.
- GoRouter for named navigation.
- `ChangeNotifier` with an inherited scope for the single focus timer controller.
- Riverpod for chat quota state.
- `AppStorage` backed by SharedPreferences for focus timer persistence.
- `camera`, `photo_manager`, `image_picker`, and `file_selector` for camera, photo, and document selection.

## Validation

Run analysis and focused tests with:

```bash
flutter analyze
flutter test test/focus_timer_layout_test.dart test/focus_timer_controller_test.dart test/app_shell_layout_test.dart
flutter test test/attach_sheet_layout_test.dart test/camera_preview_controller_test.dart test/chat_quota_repository_test.dart
```

An Android debug build can be checked with `flutter build apk --debug`.

## Known limitations

- Chat-screen callbacks for selected photos/files, Add chat, and quota-limit navigation are currently TODOs. The picker returns selected files, but there is no existing compression, validation, upload, or attachment pipeline connected to the chat.
- The default chat quota is unknown. A zero quota shows the limit state/message, but navigation to a dedicated limit screen is not implemented.
- Camera permission, live preview, scanner transition, and captured-image review require physical-device verification. Camera-unavailable fallback behavior is covered by tests.
- The app is light-mode-first. Dark theme tokens remain available, but the dark-mode UI has not been validated.
- One legacy `test/widget_test.dart` still expects the initial route to be `/` with `BlankScreen`; the app currently starts at `/chat`.
- Android builds may warn that `photo_manager` uses the Kotlin Gradle Plugin and that Java source/target 8 is deprecated. The iOS build may warn that `flutter_secure_storage` does not support Swift Package Manager.

## Working with the team

- Do not commit directly to `main`. Create a feature branch, for example `git checkout -b feature/<screen-name>`.
- Pull the latest changes before starting work.
- Run `flutter analyze` and relevant tests before pushing.
- Push the branch and open a pull request for review.
- Split work by screen or feature when possible.
- Coding agents should follow `AGENTS.md`; do not change those project rules without discussing it with the team.
