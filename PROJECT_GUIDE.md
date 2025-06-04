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

## 1. Project Progress Log

- **[Date]**: [Summary of work done, pending tasks, next steps]
- **[Date]**: [Add new entries daily or as progress is made]
- Splash screen now stays visible for 2 seconds before automatically navigating to the home screen.
- Full-screen, animated, and responsive login screen scaffolded. User selects avatar and enters name before accessing home screen. Navigation updated to show login after splash.
- **[2025-06-04]**: Identified a limitation in the current responsive layout logic. The app uses fixed breakpoints (mobile, tablet, desktop) and fixed maxWidth/scale for content, which can cause scrollbars or layout issues on in-between or non-standard screen sizes. Need to implement a more fluid, adaptive layout that works for all possible screen dimensions, not just common device classes.
- **[2025-06-05]**: Improved accessibility across all reusable widgets (semantic labels for avatars, buttons, text fields, and header images). Enhanced code comments for all custom widgets in `ui_components.dart` for clarity and maintainability. Confirmed all UI code follows DRY, responsive, and accessibility guidelines. Documentation updated per workflow rules. (Test cases to be added later.)
- **[2025-06-04]**: Refactored all main screens and UI components to use centralized theming and constants (`app_theme.dart`). All colors, font sizes, and spacing are now consistent and easily maintainable across the app. This prepares the codebase for future design changes and ensures full compliance with project guidelines. (Next: localization and error handling improvements.)
- **[2025-06-04]**: Added user-friendly error handling to the login flow. Users now see clear, actionable SnackBar messages if they try to submit without selecting an avatar or with an invalid name. All user-facing errors are non-technical and easy to understand, fully complying with project guidelines. (Next: extend error handling and best practices to other screens as needed.)
- **[2025-06-04]**: Finalized refactor of `mode_selection_screen.dart`. All repeated UI is now DRY and uses reusable widgets. Added and integrated `AppStrings` for all user-facing strings (localization-ready). Implemented accessible, themed `GameModeButton` in `ui_components.dart`. Centralized all theming, spacing, and error handling. Verified that the screen is fully accessible, robust, and error-free. The codebase is now highly maintainable and ready for further improvements or testing. (Next: extend improvements to other screens and add widget/unit tests.)

---

## 2. Project Rules & Guidelines

### UI/UX Rules
- Use a consistent color palette, font, and button style across all screens. Reference the design system or Figma file if available.
- Maintain uniform spacing and padding.
- All screens must be fully responsive across mobile, tablet, and desktop devices.
- UI elements (text, buttons, images, etc.) should scale proportionally based on screen size, ensuring content appears larger on bigger screens and appropriately sized on smaller screens.
- Maintain consistent spacing, padding, and layout proportions regardless of device size—visual balance and alignment should remain uniform.
- Use responsive layout techniques (e.g., MediaQuery, LayoutBuilder, or similar) to adapt content dynamically while preserving the overall design integrity.
- Test all screens on multiple device sizes to ensure a seamless and consistent user experience.
- Responsive layouts must not only support mobile, tablet, and desktop breakpoints, but also adapt fluidly to any screen size or aspect ratio. Avoid fixed widths and heights where possible; prefer flexible, percentage-based, or adaptive sizing to prevent scrollbars and overflow on edge cases. Test on a wide range of screen sizes, including in-between and unusual dimensions.
- All screens must meet minimum accessibility standards: good color contrast, readable font sizes, and screen reader support.

### Code Principles
- Follow DRY (Don't Repeat Yourself): Create reusable widgets/components.
- Use a single state management approach (e.g., Provider, Bloc).
- Consistent naming conventions for files, classes, and variables.
- Add comments to all custom widgets/functions.
- Game logic must be separated from UI code (see GAME_LOGIC.md for architecture).

### Animation & Assets
- Use Rive/Flare for advanced animations where needed.
- Only use optimized images, icons, and sounds.
- Follow animation guidelines: smooth, non-distracting, and purposeful.

### Error Handling & Security
- All user-facing errors must be clear, actionable, and non-technical.
- Never log sensitive user data in production. Store user data securely.

### Performance
- Optimize images and assets. Use lazy loading where possible.
- All screens should be optimized for smooth performance, including on low-end devices.

### Testing & Review
- Write widget/unit tests for all major features and game logic.
- Use a code review checklist before merging changes.
- Review and update dependencies regularly. Avoid deprecated packages.

### Workflow
- Use feature branches for new work. Pull requests must pass all tests and review before merging.
- Keep documentation and this guide updated with all major decisions and progress.

---

## 3. Extra Suggestions

- Accessibility: Ensure good color contrast, readable font sizes, and screen reader support.
- Localization: Plan for future multi-language support.
- Error Handling: Show user-friendly error messages.
- Performance: Optimize images, use lazy loading where possible.
- Versioning: Track app versions and major changes.
- Documentation: Keep this file updated with all major decisions and progress.

---

## 4. Useful Links
- [Design Reference App](https://play.google.com/store/apps/details?id=business.monopoly.city&pcampaignid=web_share)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Rive Animations](https://rive.app/)

---

> **Update this file daily with progress, rules, and any new decisions. This will help keep the project organized and bug-free!**
