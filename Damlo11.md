# Vide — Work Log and Current State

**Updated:** 2026-11-26

## Repository state

- Flutter/Dart mobile app for Vide, a university study companion.
- Current branch: `copilot/vide-mobile-project`
- Current branch commit: `aba0172` (`docs: expand project README`)
- Organization remote: `git@github.com:Midev-Lab/Vide-Mobile.git`
- `main` is at `7542d28` (`fix: correct StudyProfileScreen label`).
- The branch contains the current `main` history and is pushed to the organization repository. The working tree was clean when this report was written.
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

## Current codebase

- Shared theme tokens and icon registry are in `lib/core/theme/`; reusable widgets are in `lib/shared/widgets/`.
- The router wraps the main routes in `AppShell`. `/chat` uses `ChatScreen`; `/chat-home` currently resolves to a simple placeholder screen. Other feature routes are registered, with several screens still placeholders or in progress.
- `README.md` marks the drawer as done and chat home/composer as in progress. `docs/SCREENS.md` still has older “not built” status labels that do not fully reflect the current partial implementation.
- Backend functionality is not represented as complete; the README still has setup/configuration placeholders to resolve.

## Validation performed

- `flutter analyze`: passed with no issues after the shell, composer, and theme-token changes.
- `flutter test test/app_shell_layout_test.dart`: passed.
- `flutter test test/chat_composer_layout_test.dart`: passed. It exercises a 320px-wide layout with a simulated keyboard inset and five lines of text, plus keyboard-first drawer opening.
- Built and launched on the iPhone 17 simulator; a capital-`R` hot restart completed.
- The iOS build emitted the existing notice that `flutter_secure_storage` does not support Swift Package Manager.

## Known limitations

- A full-shell 320px layout attempt surfaced overflows in the existing page top bar and sidebar footer. Those components were outside the requested composer/shell-keyboard scope and were left unchanged; the focused 320px composer/greeting test passes.
- The existing `test/widget_test.dart` expects the app to start at `/` on `BlankScreen`, while the router’s initial location is `/chat`. This expectation was previously identified as stale and was not changed here.
