# Business India — Project Audit

**Branch**: `NewFly` · **Date**: 2026-04-15 · **Auditor**: Claude Code

A brutally honest evaluation of the current state of the Flutter Monopoly project. All claims are traceable to files/lines. The companion document `MONOPOLY_RULES_REFERENCE.md` is the rules source-of-truth used to judge correctness.

---

## TL;DR

- **The app does not compile out of the box.** `flutter analyze` reports **14 errors** from two broken files (`lib/game_logic/engine/game_edition.dart` duplicate with bad imports, and `lib/game_logic/persistence/hive_adapters.dart` referencing a never-generated `.g.dart`).
- **Zero percent of the game logic is wired into the UI.** The only reachable screen is a landing screen; every button is a no-op (`onPressed: () {}`).
- The **game logic core** (`lib/game_logic/`) is *partially correct* — the shape is right, but 10+ rule bugs remain (auction never triggered, even-building missing, bankruptcy transfers to bank instead of creditor, house rent multipliers are wrong flat values, 3-doubles-to-jail missing, etc.).
- **Tests exist (56 pass, 2 fail)** but reference a **US Monopoly board** while the app ships a **UK Monopoly board**. Neither is the promised "Business India" Indian-themed board.
- **Flame engine migration is a zombie**: `flame`, `flame_audio`, and `rive` are declared in `pubspec.yaml` but imported **nowhere** in `lib/`.

---

## 1. Repo Inventory

### Top-level clutter
- `flutter_01.png` (100 KB), `reference.jpg` (200 KB), `reference.png` (677 KB) — orphan binaries at repo root.
- `coverage/lcov.info` — build artifact checked into git.
- `GAME_LOGIC.md`, `PROJECT_GUIDE.md` — stale design docs describing a state that doesn't exist.

### `lib/` tree (~2,088 LOC Dart)
```
lib/
├─ main.dart (25)                         — Entrypoint. Also contains dead MonopolyFlameApp stub.
├─ game_logic/
│  ├─ engine/
│  │  ├─ game_engine.dart (448)           — Core engine: turn/move/landing/auction/trade/persistence.
│  │  ├─ game_factory.dart (24)           — Builder keyed by edition string.
│  │  ├─ game_edition.dart (32)           — [BROKEN DUPLICATE — bad imports, 10 compile errors]
│  │  └─ editions/
│  │     ├─ game_edition.dart (32)        — The real abstract base class.
│  │     └─ board_uk.dart (103)           — UK board + 16+16 cards.
│  ├─ models/
│  │  ├─ player.dart (146)
│  │  ├─ property.dart (171)
│  │  ├─ board_tile.dart (31)             — LEAKS Flutter import (IconData/Color).
│  │  ├─ bank.dart (52)
│  │  ├─ card.dart (103)
│  │  ├─ trade.dart (112)
│  │  ├─ enums.dart (46)
│  │  ├─ game_config.dart (48)            — copyFrom() throws UnimplementedError.
│  │  ├─ game_status.dart (2)             — DEAD duplicate of enums.dart.
│  │  ├─ tile_type.dart (14)              — DEAD duplicate of enums.dart.
│  │  └─ ai_player.dart (29)              — Trivial subclass, unused.
│  └─ persistence/
│     ├─ hive_adapters.dart (91)          — [BROKEN: references non-existent .g.dart]
│     └─ hive_persistence.dart (51)       — Never initialized in main.dart.
└─ screens/
   ├─ landing_screen.dart (47)
   └─ widgets/
      ├─ animated_background_widget.dart (40)
      ├─ animated_game_button.dart (246)  — Glossy button, includes unused fields + dart:math import.
      ├─ cloud_widget.dart (104)
      ├─ main_action_buttons_widget.dart (40)   — ALL onPressed: () {} (no-op).
      ├─ monopoly_logo_widget.dart (20)
      ├─ user_avatar_widget.dart (24)
      └─ game_button/
         ├─ liquid_ripple.dart (29)
         └─ liquid_ripple_painter.dart (45)
```

### `test/`
- `game_engine_test.dart` — 964 LOC. **Built around a US Monopoly board** (Mediterranean Ave … Boardwalk) while the app ships a UK board. 56 tests pass, **2 fail** (auto-hotel upgrade path).

### `assets/`
- 10 avatar PNGs, 4 cloud SVGs, 1 `loginboard.png`, 1 `background_music.mp3` (never referenced).

### `pubspec.yaml` issues
- `flame: ^1.17.0`, `flame_audio: ^2.11.6`, `rive: ^0.13.20` — **zero imports** in `lib/`. Pure dead weight.
- `shared_preferences_web` declared but unused.
- `hive` + `hive_flutter` — used only by broken persistence code; never initialized in `main.dart`.
- `hive_adapters.dart` declares `part 'hive_adapters.g.dart'` but no `build_runner` / `hive_generator` in dev_deps. **Codegen was never run.**
- 41 packages have newer-incompatible versions.

---

## 2. Game Logic Findings (rule-by-rule)

Legend: ✅ correct · ⚠️ incomplete/buggy · ❌ missing · 🐛 wrong

| Rule | Verdict | Evidence |
|---|---|---|
| 40-tile board, correct order | ⚠️ UK names (Old Kent Rd … Mayfair) — **not Indian-themed** | `board_uk.dart:17-58` |
| Dice roll | ⚠️ `rollDiceWithRules` result unused; UI/tests pass dice directly into `movePlayer` | `game_engine.dart:65-79, 373-396` |
| Doubles → roll again, 3 doubles → jail | ❌ Missing. No doubles counter, no reroll loop | — |
| Movement, passing GO ($200) | 🐛 Buggy. Pass-GO detected via `position - dice < 0` **after** modular move. Breaks for "Go Back 3", and card-based `moveTo` past GO awards nothing. GO tile explicit landing awards $200 again (double-pay). | `game_engine.dart:202-233` |
| Buying property | ✅ Basic path works. Silently fails on insufficient funds (no auction) | `game_engine.dart:409-428` |
| **Mandatory auction on decline** | ❌ `startAuction` exists but never invoked from decline path. `startAuctionWithBidding` has an **infinite loop** when nobody bids | `game_engine.dart:81-135, 247` |
| Rent — base | ✅ | `property.dart:38-49` |
| Rent — monopoly ×2 (no houses) | ✅ | `property.dart:47` |
| Rent — house/hotel tiers | 🐛 Hardcoded flat multipliers `[1,5,15,45,65,75]`. Real Monopoly rents vary per property. Wrong for every street. | `property.dart:6, 65-67` |
| Rent — railroad 25/50/100/200 | ✅ via `baseRent * 2^(n-1)` | `property.dart:60-63` |
| Rent — utility 4×/10× dice | ✅ | `property.dart:51-53` |
| Rent — no rent when mortgaged | ⚠️ Works for streets; **mortgaged railroads/utilities still charge rent** | `property.dart:38-46` |
| Jail — 3 entries | ⚠️ Tile + card yes; 3-doubles missing | `game_engine.dart:219-220`, `card.dart:34` |
| Jail — 3 exits | ⚠️ Pay/card/doubles present but entangled with movement | `game_engine.dart:147-160, 379-390` |
| Jail — 3-attempt counter | ⚠️ `jailTurns` caps at 3 | `game_config.dart:33` |
| Jail — forced pay on 3rd | ✅ | `game_engine.dart:148-152` |
| Chance — 16 cards present | ⚠️ Present but "advance to nearest RR/Utility" cards have `targetTileIndex: null` → `handleDeck` throws | `board_uk.dart:61-78`, `game_engine.dart:296-311` |
| Chance — "Go Back 3" | 🐛 Uses `steps: -3`, lands correctly but skips pass-GO logic entirely | — |
| Community Chest — 16 cards | ⚠️ Plausible but hotel-repair cost missing for some variants | `card.dart:71-83` |
| Card deck reshuffle | ⚠️ Random pick instead of shuffled stack. GOOJF goes to used pile on draw but player never returns it — can be re-drawn while held | `game_engine.dart:273-286` |
| Mortgage value 50% | ✅ | `property.dart:34` |
| Unmortgage 10% interest | ✅ | `property.dart:36` |
| 10% fee on mortgaged property trade | ❌ Not implemented | `trade.dart:89-98` |
| Houses — even-building rule | ❌ Explicit TODO | `property.dart:95` |
| Houses — must own full color group | ❌ Not checked | `property.dart:146-149` |
| Houses — no mortgages in group | ❌ Not checked | — |
| House/hotel supply 32/12 | ✅ | `bank.dart:7-9` |
| Sell back at half price | 🐛 `downgrade()` doesn't refund player; also doesn't call `takeHouse` | `property.dart:120-130` |
| Trading — cash + property | ✅ | `trade.dart` |
| Trading — GOOJF cards | ❌ Not modeled in Trade | — |
| Trading — reject properties with houses | ⚠️ No validation | — |
| Trading — mortgaged transfer fee | 🐛 Transfers without fee/choice | — |
| Bankruptcy — to player | 🐛 `declareBankruptcy` returns properties **to bank, not creditor** | `player.dart:121-127` |
| Bankruptcy — to bank (auction) | ❌ No auction of recovered properties | — |
| Insufficient-funds flow | 🐛 `Player.pay` throws; `payRent` doesn't catch. Bankruptcy handler exists but is never called | `player.dart:39-44`, `game_engine.dart:398-407` |
| Win condition | ⚠️ `checkGameEnd` logic ok but only runs from `nextTurn`, not after bankruptcy | `game_engine.dart:430-443` |

---

## 3. Architecture & Code Quality

| Severity | Finding |
|---|---|
| **SEVERE** | Does not compile. 14 errors from duplicate `game_edition.dart` + ungenerated Hive adapter. |
| **SEVERE** | No state management layer. Provider declared but unused. GameEngine uses a single nullable callback. |
| **SEVERE** | No UI↔logic glue. Nothing constructs a `GameEngine` outside tests. No game screen exists. |
| **HIGH** | `board_tile.dart:3` imports `package:flutter/material.dart` for IconData/Color — Flutter leaks into the logic layer. |
| **HIGH** | Enum duplication: `enums.dart` vs `game_status.dart` vs `tile_type.dart` vs `hive_adapters.dart` — four parallel declarations of `GameStatus`/`TileType`. |
| **HIGH** | Persistence is entirely non-functional: no `Hive.initFlutter()`, no adapter registration, `GameConfig.copyFrom` throws. |
| **MEDIUM** | `game_engine.dart` does too much (turn + move + landing + auction + trade + persistence + events) in 448 LOC. |
| **MEDIUM** | Money as `double`. Monopoly is integer-only — floating-point drift will appear in mortgage/repair math. |
| **MEDIUM** | Exceptions used for game flow (`pay` throws on insufficient funds). Tests catch and swallow. |
| **LOW** | 56 analyzer issues total (14 errors, 12 warnings, 30 infos — deprecated `withOpacity`, unused imports, `print` calls, missing super params). |

---

## 4. UI/UX

- Only reachable screen: `LandingScreen` — gradient bg, animated clouds, a `loginboard.png` logo, 3 glass buttons, a hardcoded "Player 1" avatar.
- **No game screen. No setup screen. No routes.** `MaterialApp` has zero named routes.
- `MainActionButtonsWidget.onPressed: () {}` — every button is a no-op.
- `animated_game_button.dart` is 246 LOC with inline decoration, an unused `_scaleAnim`, and an unused `dart:math` import. Scale = `screen.width / 400` with no clamp → tiny on phones, huge on tablets.
- No `ThemeData`, no color tokens, colors hardcoded inline. Cyan gradient vs yellow/blue/white buttons — inconsistent palette.
- Not Indian-themed anywhere visually.

---

## 5. Build & Test Output

```
flutter --version  →  Flutter 3.32.4 / Dart 3.8.1
flutter pub get    →  OK (41 packages have newer-incompatible versions)
flutter analyze    →  56 issues, 14 ERRORS (build-blocking)
flutter test       →  58 tests: 56 passed, 2 FAILED
```

**Test failures** — both caused by `Property.upgrade` not auto-promoting 4 houses → hotel without an explicit `buildHotel: true`:
- `Player cannot build more than 4 houses and 1 hotel`
- `Player builds four houses then a hotel on a property`

---

## 6. Playability

If you `flutter run` today:

1. **Build fails** (14 compile errors).
2. After deleting the two broken files → app launches to landing screen.
3. Clouds drift, logo renders, 3 buttons appear.
4. Tap **Play** → nothing.
5. Tap **How to Play** → nothing.
6. Tap **Settings** → nothing.

**Dead end at the first screen.** There is no game. You cannot reach the board, roll dice, move, or buy a property via the UI.

---

## 7. Leftover / Dead Code Inventory (deletion list)

| File / Dep | Reason |
|---|---|
| `lib/game_logic/engine/game_edition.dart` | Broken duplicate, 10 compile errors |
| `lib/game_logic/persistence/hive_adapters.dart` | References ungenerated `.g.dart`; re-declares models |
| `lib/game_logic/persistence/hive_persistence.dart` | Non-functional; calls throwing `copyFrom` |
| `lib/game_logic/models/game_status.dart` | Dead duplicate enum |
| `lib/game_logic/models/tile_type.dart` | Dead duplicate enum |
| `lib/game_logic/models/ai_player.dart` | Trivial, unused |
| `lib/main.dart` → `MonopolyFlameApp` stub | Dead Flame scaffolding |
| `pubspec.yaml` → `flame`, `flame_audio`, `rive`, `shared_preferences_web` | Unused deps |
| `assets/background_music.mp3` | Unreferenced |
| `flutter_01.png`, `reference.jpg`, `reference.png` (root) | Move to `docs/` or delete |
| `coverage/` | Build artifact, should be gitignored |

---

## 8. Scores

| Dimension | Score |
|---|---|
| Game Logic Correctness | **4 / 10** |
| Code Quality | **3 / 10** |
| UI/UX | **3 / 10** |
| Project Health | **2 / 10** |
| Playability | **1 / 10** |
| **Overall** | **2.6 / 10** |

---

## 9. Salvageability

**Keep**: `lib/game_logic/engine/*` (minus the broken duplicate), `lib/game_logic/models/*` (minus the dead enum stubs and board_tile's Flutter leak), the test suite (with board swapped to India), the cloud/background widgets for atmospheric use.

**Throw away**: Hive persistence, the 246-LOC glass button, `main_action_buttons_widget`, landing screen buttons (no-op), all Flame/Rive deps, duplicate enums, stale docs.

**Rewrite**: the rule bugs listed in §2 (one-file patches, 10–50 LOC each), the entire UI layer (no game screen exists), the board (UK → India with rupee pricing).

The shape of the game engine is sound. The data model is sound. The test harness is genuinely valuable as a regression net. Rewriting from zero would discard ~2,000 LOC of working skeleton and a week of scaffolding for no gain. But the UI is a shell and must be built from scratch.
