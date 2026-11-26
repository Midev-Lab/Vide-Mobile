# Vide — Work Log and Current State

**Updated:** 2026-11-26

## Repository state

- Flutter/Dart mobile app for Vide, a university study companion.
- Current branch: `copilot/vide-mobile-project`
- Current branch commit: `aba0172` (`docs: expand project README`)
- Organization remote: `git@github.com:Midev-Lab/Vide-Mobile.git`
- `main` is at `7542d28` (`fix: correct StudyProfileScreen label`).
- The branch contains the current `main` history and is pushed to the organization repository. Today's UI work is currently in the working tree and has not been committed.
- App entry point uses `MaterialApp.router`, GoRouter, and `ThemeMode.light`. The initial route is `/chat`.

## Changes made today

### Icons and project rules

- Confirmed `phosphoricons_flutter` is the icon dependency in `pubspec.yaml`; the old `phosphor_flutter` package is absent.
- Kept Phosphor glyph definitions centralized in `lib/core/theme/app_icons.dart`, rendered through `AppIcon`. Package icon names were verified against the package source; no names needed replacing.
- Updated `AGENTS.md` to use written prompt specifications instead of Figma or reference screenshots. Kept the standalone-screen architecture guidance.
- Updated `docs/SCREENS.md` to retain screen descriptions without screenshot references.

### Drawer and shared shell

- Refined the drawer’s compact navigation, route-based selected state, Recents, header, and pinned account/New study controls.
- Added the shared push-style `AppShell`: the drawer is underneath a translated, full-screen page; the page has an animated rounded left edge and matching shadow.
- Fixed drawer layout constraints and added a transparent `Material` ancestor for its InkWells.
- Added a full-screen green backing layer in the shell and set its subtree’s default Scaffold background to the green theme token.
- Balanced the drawer header and page top bar using shared header sizing, icon targets, and spacing tokens.
- The shell preserves keyboard insets and waits for the keyboard to dismiss before opening the drawer.

### Chat composer and keyboard layout

- Reworked the composer into a 56px resting pill and a focused/filled rounded card.
- Added multiline sentence-capitalized input (up to five lines), mode selection, attachment control, voice/send icon transition, whitespace-only send disabling, press scaling, and light haptics.
- The disclaimer is hidden while the keyboard is open or the field is focused. Bottom padding uses the safe area plus 8px when closed and 8px when open.
- Changed the chat page body to a resizable `Column`; the greeting centers in available space as the keyboard opens. The logo scales down and can hide on short layouts, while the headline remains.
- Added theme tokens for the new composer dimensions, radius, motion, and opacity behavior.

### Documentation and profile label

- Rewrote `README.md` with the app summary, features, setup, structure, design rules, and team workflow.
- Corrected the Study Profile placeholder from `Study profil` to `Study profile`.
- Preserved the organization repository’s original `LICENSE` history when pushing to `main`; no force push was used.

### Focus timer

- Added one app-wide `FocusTimerController`, hosted above the router and backed by the existing `AppStorage`/SharedPreferences layer. It supports idle, running, paused, and finished states; persists the selected duration, state, remaining time, and end time; derives running time from `endTime`; and refreshes after app resume.
- On completion, the controller sends a heavy haptic, shows “Focus session complete,” and returns to idle. Accessibility announcements are limited to state changes and minute boundaries.
- Added the idle duration picker and running/paused controls as a root `OverlayEntry`. The overlay now provides its own transparent `Material` and theme `DefaultTextStyle`, with a responsive scrollable surface.
- Refined the header to fixed 88px leading/trailing slots around an ellipsized centered title. Removed the trailing plus button; the drawer’s “New study” action still routes to Chat.
- Made the running/paused timer pill 32px high, 16px radius, and at most 84px wide, while preserving a 48px hit target. The popover controls remain equal-width in a row at 1.3 text scale.
- Updated the corresponding timer layout/radius tokens. Colors and text styles continue to resolve through the theme.
- Main implementation: `lib/features/focus/state/focus_timer_controller.dart`, `lib/features/focus/widgets/focus_timer_header_control.dart`, `lib/features/focus/widgets/focus_timer_popover.dart`, and `lib/shared/widgets/dashboard_header.dart`.
- Relevant tests: `test/focus_timer_controller_test.dart`, `test/focus_timer_layout_test.dart`, and the drawer navigation check in `test/app_shell_layout_test.dart`.

### Attach sheet, camera, and quota

- Rebuilt the attach sheet under `lib/features/chat/attach/` with a responsive scrollable layout, tokenized spacing/radii, a single drag handle, edge-to-edge recent-photo strip, loading thumbnails, and the yellow Add chat card. Tile definitions use `AttachAction`.
- Added injectable picker, recent-photo, and camera services. Gallery and document selection use native pickers; recent photos use `photo_manager`.
- Added a high-resolution camera controller with permission prechecks, tap-to-request behavior, lifecycle pause/resume, flash/flip/focus/capture controls, and safe disposal. The full-screen scanner reuses the same controller and includes capture review and Retake/Use photo actions.
- Added native camera permission status/settings integration. Android declares `CAMERA`; iOS camera/photo usage strings were confirmed present in `ios/Runner/Info.plist`.
- Replaced `file_picker` with the endorsed `file_selector` after the former’s Swift Package Manager dependency prevented iOS resolution.
- Added unknown-by-default `ChatQuota` state and repository/provider. Debug quota previews accept `--dart-define=VIDE_DEBUG_CHAT_QUOTA=unknown|0|1|5`; production does not invent a quota value.
- Main implementation: `lib/features/chat/attach/attach_sheet.dart`, its `models/`, `services/`, `state/`, and `widgets/` files, plus `lib/features/quota/`.
- Relevant tests: `test/attach_sheet_layout_test.dart`, `test/camera_preview_controller_test.dart`, and `test/chat_quota_repository_test.dart`.
- Audited app overlays: the timer popover was the custom root `OverlayEntry` without a guaranteed Material ancestor and is fixed. The sidebar popup is under the shell’s `Material`; modal sheets/dialogs and Scaffold snackbars use Flutter’s Material routes/components.

## Current codebase

- Shared theme tokens and icon registry are in `lib/core/theme/`; reusable widgets are in `lib/shared/widgets/`.
- The router wraps the main routes in `AppShell`. `/chat` uses `ChatScreen` and hosts the app-wide focus timer. The attach sheet is in `lib/features/chat/attach/`. `/chat-home` currently resolves to a simple placeholder screen. Other feature routes are registered, with several screens still placeholders or in progress.
- `README.md` marks the drawer as done and chat home/composer as in progress. `docs/SCREENS.md` still has older “not built” status labels that do not fully reflect the current partial implementation.
- Backend functionality is not represented as complete; the README still has setup/configuration placeholders to resolve.

## Validation performed

- `flutter analyze`: passed with no issues after the shell, composer, and theme-token changes.
- `flutter test test/app_shell_layout_test.dart`: passed.
- `flutter test test/chat_composer_layout_test.dart`: passed. It exercises a 320px-wide layout with a simulated keyboard inset and five lines of text, plus keyboard-first drawer opening.
- Built and launched on the iPhone 17 simulator; a capital-`R` hot restart completed.
- The iOS build emitted the existing notice that `flutter_secure_storage` does not support Swift Package Manager.
- Focus timer follow-up: `flutter analyze` passed; `flutter test test/focus_timer_layout_test.dart test/focus_timer_controller_test.dart test/app_shell_layout_test.dart` passed (7 tests), including 320px/1.3x layout and the drawer “New study” route. The updated app built and launched on iPhone 17.
- Attach-sheet follow-up: `flutter analyze` passed; focused attach, camera-state, and quota tests passed (8 tests). `flutter build apk --debug` and an iOS simulator build/launch succeeded. Android emitted Kotlin Gradle Plugin and Java 8 source/target deprecation warnings.
- An idle focus-header simulator screenshot was captured at `~/.copilot/session-state/6388c765-b3cf-4ada-b6d2-d7f7abb6240c/files/focus-timer/idle-header.png`. Other requested timer-state screenshots were not captured.

## Known limitations

- A full-shell 320px layout attempt surfaced overflows in the existing page top bar and sidebar footer. Those components were outside the requested composer/shell-keyboard scope and were left unchanged; the focused 320px composer/greeting test passes.
- The existing `test/widget_test.dart` expects the app to start at `/` on `BlankScreen`, while the router’s initial location is `/chat`. This expectation was previously identified as stale and was not changed here.
- The attach sheet returns selected `XFile`s through callbacks, but the chat screens still have TODO/no-op photo, file, Add chat, and limit-state handlers. This repository has no existing compression/validation/upload pipeline to connect; selection alone does not attach or upload the files.
- The physical camera path, OS permission prompt, scanner transition, and captured-image review still require real-device verification. The iPhone simulator has no usable camera; camera-unavailable behavior is covered by tests.
- Chat quota is unknown by default. A zero quota shows the limit-state UI/message, but navigation to a real Phase 5 limit screen remains TODO.
- The app remains light-mode-first. Theme-token resolution is retained, but dark-mode appearance was not tested.
- Interactive captures of the idle picker, running header, and running popover were not taken; only the idle header was captured.
