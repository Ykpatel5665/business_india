# Verdict

**Date**: 2026-04-15 · See `PROJECT_AUDIT.md` for evidence.

---

## The Decision: **Option A — Continue with the existing project, aggressively cleaned up**

Not Option B (new project + copy logic). Not Option C (full rewrite). **Option A with heavy surgery.**

---

## Why not Option B (`business_india_v2`)

Creating a fresh Flutter project and copying the good parts sounds clean, but it's actually wasteful:

- The **only** things worth copying are `lib/game_logic/*` and `test/*`. That's 1 folder and 1 file.
- A fresh Flutter project means re-generating `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` platform scaffolds — **none of which have anything wrong with them today**.
- You lose the git history of the game logic work, which the audit scored 4/10 — not 0/10. There's genuine learning encoded in those 960 lines of tests.
- `business_india_v2` would just be `business_india` minus 5 broken files. That's a deletion, not a new project.

## Why not Option C (full rewrite)

- The engine/models layer captures the right shape. Throwing away the test suite means losing the one artifact that proves any part of the game works.
- Writing a correct Monopoly engine from scratch is 1–2 weeks of focused work. We can fix the existing bugs in 1–2 days.

## Why Option A

- **Remove** the ~8 broken/dead files in the "Deletion List" (§7 of audit). This alone gets `flutter analyze` from 14 errors → 0 errors. One commit.
- **Purge** Flame/Rive from `pubspec.yaml` — zero imports reference them.
- **Patch** the 10 engine rule bugs identified in §2 of the audit. Each is 10–50 LOC with a new test. Bundled fixes, ~2 days.
- **Rebuild** the board as Indian cities with ₹ (rupee) pricing — one file, ~100 LOC.
- **Rebuild** the UI layer on top of the patched engine. This is the bulk of new work and would be rebuilt under *any* option. Option A is not worse here.
- **Defer** Hive persistence until there's something worth saving. Replace later with a simple JSON-over-`shared_preferences` approach when needed.

## What will be preserved vs. replaced

### Kept (after surgery)
- `lib/game_logic/engine/game_engine.dart`, `game_factory.dart`, `editions/game_edition.dart`
- `lib/game_logic/models/player.dart`, `property.dart`, `bank.dart`, `card.dart`, `trade.dart`, `enums.dart`, `game_config.dart`
- `test/game_engine_test.dart` (board swapped to India, auto-hotel path fixed)
- `lib/screens/widgets/animated_background_widget.dart`, `cloud_widget.dart` — atmospheric assets worth reusing
- Flutter project scaffolding (`android/`, `ios/`, `web/`, etc.)

### Deleted
- `lib/game_logic/engine/game_edition.dart` (duplicate)
- `lib/game_logic/persistence/*` (both files — non-functional)
- `lib/game_logic/models/game_status.dart`, `tile_type.dart`, `ai_player.dart`
- `lib/screens/widgets/main_action_buttons_widget.dart`, `animated_game_button.dart`, `game_button/*`
- `lib/main.dart` → dead `MonopolyFlameApp` stub
- `pubspec.yaml` → `flame`, `flame_audio`, `rive`, `shared_preferences_web`
- Root binaries: `flutter_01.png`, `reference.jpg`, `reference.png` (moved to `docs/`)
- `coverage/` (gitignored)
- Stale `GAME_LOGIC.md`, `PROJECT_GUIDE.md` (superseded by `CLAUDE.md` + `MONOPOLY_RULES_REFERENCE.md`)

### Fixed (engine surgery)
1. Add `consecutiveDoubles` counter to Player; 3 doubles → jail, no move on 3rd.
2. Wire auction into the "decline to buy" path; fix infinite loop in bidding.
3. Move house/hotel rent values **into** each property's data (per-property table, not a global flat multiplier).
4. Implement even-building rule (max 1 house difference within a color group).
5. Require full-group ownership + no mortgages in group before building.
6. Fix bankruptcy-to-creditor: assets transfer to the player, not the bank.
7. Implement bankruptcy-to-bank → auction recovered properties.
8. Fix `Property.downgrade` half-price refund + house-return-to-bank.
9. Fix pass-GO detection for card-based moves (`moveTo`) and "Go Back 3".
10. Fix mortgaged railroad/utility rent leak (move mortgage check to top of rent calc).
11. Make GOOJF card return to deck when used.
12. Stop using `Exception` for game flow; use typed `RentUnpaid`/`Bankrupt` events.
13. Convert money from `double` → `int` (rupees, integer only).
14. Remove `Flutter` import leak from `board_tile.dart` (move icon/color to UI layer).

### Rebuilt from scratch
- **Board data**: Indian cities theme (see `CLAUDE.md` for the mapping).
- **Currency**: ₹ rupees, integer, with Indian number formatting (lakh/crore).
- **UI layer**: game screen (board + dice + turn HUD + player panel), setup screen, landing nav flow.
- **State management**: `provider` + `ChangeNotifier` wrapping `GameEngine` (provider is already in `pubspec` but unused today).
- **Theme**: proper `ThemeData` with a color token system and `google_fonts` for typography.

---

## Estimated effort

| Phase | Scope | Est. effort |
|---|---|---|
| 0 | Cleanup (delete dead code, fix analyze, remove Flame deps) | ~1 session |
| 1 | Indian board + rupee currency + fix auto-hotel test | ~1 session |
| 2 | Engine bug fixes (auction, doubles, even-build, bankruptcy) | ~2 sessions |
| 3 | First playable: landing → setup → game screen with dice + move | ~3 sessions |
| 4 | Rent/buy/auction UI + turn HUD | ~2 sessions |
| 5 | Houses/hotels UI + trading UI + jail UI | ~2 sessions |
| 6 | Polish: theme tokens, animations, sounds, responsive layout | ~2 sessions |
| 7 | Persistence (save/load) | ~1 session |

Detailed phasing with acceptance criteria lives in `BUILD_ROADMAP.md`.
