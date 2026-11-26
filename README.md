# Vide

Vide is a mobile study companion for university students, built with Flutter. Students chat with an AI that adapts to how they want to study, save key ideas as flashcards, and stay on track with a focus timer.

Vide also has a web app at vide.midev.ng. This repo is the mobile app.

## Features

- **Chat** with study modes (Casual, Tutor, Socratic, Quiz Master, Exam coach, and more)
- **Flashcards** for definitions and quiz mistakes
- **Focus timer** with sprint presets
- **Study profile** that remembers your level, focus and teaching style
- **All chats** with search and mode filters

## Build status

| Area | Status |
|------|--------|
| Theme, shared widgets, navigation | Done |
| App drawer (push-style) | Done |
| Chat home and composer | In progress |
| Flashcards | Not started |
| Focus timer | Not started |
| Study profile | Not started |
| All chats | Not started |

## Getting started

You need Flutter installed ([install guide](https://docs.flutter.dev/get-started/install)).

```bash
git clone https://github.com/[your-username]/vide.git
cd vide
flutter pub get
flutter run
```

If the app needs keys or config, copy `.env.example` to `.env` and fill in the values. Never commit the real `.env`.

## Project structure

```
lib/
  app/            router, app shell (drawer + page)
  core/           theme tokens, network, storage
  shared/widgets/ reusable widgets (buttons, icons, top bar, sheets)
  features/<feature>/screens/<screen>/
                  one folder per screen: screen, controller, widgets
docs/
  ARCHITECTURE.md how the app is structured
  SCREENS.md      the list of screens and what each contains
AGENTS.md         rules for coding agents working in this repo
```

Each screen stands alone: it never imports another screen, it navigates only through named routes, and it works with fake data first so it runs before the backend exists. Read `docs/ARCHITECTURE.md` before adding a screen.

## Design rules

- Colors, fonts, spacing and radius come from the theme tokens in `lib/core/theme`. Never hardcode them.
- Icons come only from `AppIcons` through the `AppIcon` widget (Phosphor icons, via `phosphoricons_flutter`). Don't import an icon package directly in a screen and don't mix in other icon sets.
- All UI text is in sentence case.

## Tech

- Flutter / Dart
- State management: [Riverpod, or whatever pubspec.yaml uses]
- Backend: [Firebase / custom API / not connected yet]

## Working with the team

- Never commit directly to `main`. Make a branch for your work: `git checkout -b feature/<screen-name>`.
- Run `git pull` before you start each day.
- When a piece is done, push your branch and open a Pull Request. Someone else reviews and merges it.
- Split work by screen, so two people rarely edit the same files.
- Run `flutter analyze` before you push and fix any issues.

If you use a coding agent, it reads `AGENTS.md` for the project rules. Don't edit those rules without telling the team.