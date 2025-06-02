# Project Guide: Business India Game App

> **Copilot Markdown Rules:**
> 1. Always refer to this file before starting any new task or suggestion.
> 2. Use this file as the single source of truth for project rules, progress, and decisions.
> 3. If you notice any inconsistency between code and this file, suggest corrections.
> 4. If the user asks for a summary, always use the latest information from this file.
> 5. If you think a new rule, guideline, or best practice should be added, proactively suggest it to the user.
> 6. Never ignore or skip any instruction or rule written in this file.
> 7. If you are unsure about a requirement, ask the user for clarification referencing this file.
> 8. Keep your suggestions and code consistent with the standards and patterns described here.

---

## 1. Project Progress Log
- **[YYYY-MM-DD]**: [Summary of work done, pending tasks, next steps]

---

## 2. Project Rules & Guidelines

### UI/UX & Theming
- Use a central theme file for all colors, fonts, and text styles.
- Support both light and dark modes using ThemeMode.
- Never hardcode spacing, padding, or margin; use global constants.
- All screens must be fully responsive (mobile, tablet, desktop) using LayoutBuilder, MediaQuery, or scaling packages.
- Use only predefined text styles and maintain a consistent layout grid.

### Code Principles & Structure
- Follow DRY: Extract all repeated UI into reusable widgets/components under /lib/widgets or /lib/components.
- Use a single state management approach (Provider, Riverpod, or Bloc).
- Avoid setState() in full widgets; prefer state management.
- Use clear naming conventions: feature_screen_name.dart, FeatureCard, feature_controller.dart, etc.
- Add inline comments to all custom widgets, utility functions, and business logic.
- Organize code with this structure:
  - /lib/core: constants, themes, global utils
  - /lib/features: each screen + logic (e.g., /home, /board)
  - /lib/widgets: shared components
  - /lib/animations: Rive/Flare files, custom animations
  - /lib/services: data, storage, API, providers/blocs
  - /lib/models: data classes (e.g., Player, GameState)

### Reusability & Responsiveness
- Extract shared layouts (e.g., board, player info, dice area) into modular widgets.
- If a visual pattern is repeated, convert it into a widget immediately.
- Use const constructors wherever possible to reduce rebuilds.
- Never hardcode pixel sizes; always base on screen dimensions.
- Text must scale for different resolutions.
- Maintain global constants for spacing (e.g., AppPadding.small).

### Animation & Assets
- Use Rive/Flare for advanced/interactive animations only when meaningful.
- Store all animations under /lib/animations.
- All assets must be compressed and optimized.
- Animate only with purpose—animations must be smooth, fast, and non-distracting.

### Testing & Review
- Every major widget and screen must have at least one widget test.
- Business logic (e.g., turn handling, balance checks) must be unit tested.
- Use a checklist before merging: Responsive? Reusable? Themed? Fully tested?

---

## 3. Extra Suggestions

### Accessibility
- Ensure readable font sizes and minimum contrast ratio of 4.5:1.
- Use semantic labels (Semantics widget) for screen readers where needed.

### Localization
- Use Flutter intl package for future multi-language support.
- Store all user-facing strings in a localization file.

### Error Handling
- Use try-catch around all network/storage logic.
- Display friendly error messages with context-aware descriptions.

### Performance
- Use const constructors wherever possible.
- Use ListView.builder, PageView.builder, and lazy-load large UI.
- Cache network and asset images using cached_network_image or asset bundles.

### Versioning
- Maintain a changelog in /docs/CHANGELOG.md or tag Git commits.
- Update app version in pubspec.yaml and build.gradle accordingly.

### Documentation
- Keep this PROJECT_GUIDE.md updated with all new rules, decisions, and changes.
- Add inline comments and README sections for features as needed.

---

## 4. Useful Links
- [Design Reference App](https://play.google.com/store/apps/details?id=business.monopoly.city&pcampaignid=web_share)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Rive Animations](https://rive.app/)

---

> **Update this file daily with progress, rules, and any new decisions. This will help keep the project organized and bug-free!**
