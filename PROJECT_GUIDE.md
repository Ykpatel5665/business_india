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

---

## 2. Project Rules & Guidelines

### UI/UX Rules
- Use a consistent color palette, font, and button style across all screens.
- Maintain uniform spacing and padding.
- All screens must be responsive (mobile, tablet, desktop).

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
