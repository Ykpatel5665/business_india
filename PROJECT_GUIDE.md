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

---

## 2. Project Rules & Guidelines

### UI/UX Rules
- Use a consistent color palette, font, and button style across all screens.
- Maintain uniform spacing and padding.
- All screens must be fully responsive across mobile, tablet, and desktop devices.
- UI elements (text, buttons, images, etc.) should scale proportionally based on screen size, ensuring content appears larger on bigger screens and appropriately sized on smaller screens.
- Maintain consistent spacing, padding, and layout proportions regardless of device size—visual balance and alignment should remain uniform.
- Use responsive layout techniques (e.g., MediaQuery, LayoutBuilder, or similar) to adapt content dynamically while preserving the overall design integrity.
- Test all screens on multiple device sizes to ensure a seamless and consistent user experience.
- Responsive layouts must not only support mobile, tablet, and desktop breakpoints, but also adapt fluidly to any screen size or aspect ratio. Avoid fixed widths and heights where possible; prefer flexible, percentage-based, or adaptive sizing to prevent scrollbars and overflow on edge cases. Test on a wide range of screen sizes, including in-between and unusual dimensions.

### Code Principles
- Follow DRY (Don't Repeat Yourself): Create reusable widgets/components.
- Use a single state management approach (e.g., Provider, Bloc).
- Consistent naming conventions for files, classes, and variables.
- Add comments to all custom widgets/functions.

### Animation & Assets
- Use Rive/Flare for advanced animations where needed.
- Only use optimized images, icons, and sounds.
- Follow animation guidelines: smooth, non-distracting, and purposeful.

### Testing & Review
- Write widget/unit tests for all major features.
- Use a code review checklist before merging changes.

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
