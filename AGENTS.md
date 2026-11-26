# AGENTS.md

## Project

Vide is a Flutter app. Always output Flutter/Dart code — never React, JSX, Tailwind, or web code.

## Screen specifications

Build every screen from the written specification in the prompt. Colors, fonts, spacing, and radii must come only from existing theme tokens in `lib/core/theme/`. Never hardcode these values in a screen. Use icons only through the shared `AppIcon` widget and `AppIcons` registry.

## Rules

1. **Flutter only.** Generate Flutter/Dart UI.

2. **No hardcoded design values.** Never hardcode colors, fonts, spacing, or radii. Use existing theme tokens and shared widgets. Scan `lib/` first and reuse what already exists:
   - Theme tokens: `lib/core/theme/` (`app_colors.dart`, `app_text_styles.dart`, `app_radii.dart`, `app_theme.dart`)
   - Shared widgets: `lib/shared/widgets/` (`app_button.dart`, `app_text_field.dart`, `bottom_sheet_helper.dart`)
   - If a required token or shared widget is missing, ask before adding it. Never inline design values in a screen.

3. **Standalone screens.** Put each screen in its own folder at `lib/features/<feature>/screens/<screen>/`, with its screen, controller, and screen-specific widgets there. A screen must never import another screen. Navigate only through named routes registered in the single router file, `lib/core/router/app_router.dart`. Put reusable UI in `lib/shared/`, and use one folder per screen.
4. **Follow project conventions.** Use the central `lib/core/router/` and the barrel files (`theme.dart`, `widgets.dart`, `router.dart`) for imports where appropriate.
5. **Complete files on edits.** When modifying an existing file, return the entire file, not a diff or fragment.
6. **Verify against the prompt.** Check the screen against the written specification provided in the prompt.
7. **All icons come through `AppIcon` and `AppIcons`.** Define icon glyphs in `lib/core/theme/app_icons.dart` and render them through `AppIcon` from `lib/shared/widgets/app_icon.dart`. The icon package is `phosphoricons_flutter`; only `lib/core/theme/app_icons.dart` may import it. Screens and widgets must never import `phosphoricons_flutter` directly, and icons from other sets (Material, Cupertino, raw icon assets) must never be mixed in.
8. **Sentence case.** Use sentence case for all user-facing UI text.

## Light mode first

- For now, build and test every screen in LIGHT mode only. Dark mode comes later, after the light screens are done.
- Lock the app to ThemeMode.light in the app entry file so it ignores the phone's dark mode setting.
- Do not delete or break any dark theme tokens that already exist. Leave them in place, just unused for now.
- Do not build dark variants or add dark-mode logic until I say "start dark mode".
- Always read colors from the theme tokens. Never hardcode light or dark colors inside a screen, so adding dark mode later is only a theme change.

## Written-spec fidelity

- Implement the written prompt specification without adding unspecified UI.
- Flutter widgets add default styling (TextField borders and fill, Card elevation, Material ripple and splash, ListTile padding, button shapes and minimum sizes, AppBar styling). Override or turn off defaults that are not specified.
- Use theme tokens for colors, fonts, spacing, and radii; never hardcode these values in a screen.
- Check the completed screen against the written prompt specification and report any remaining differences.
