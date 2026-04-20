# CLAUDE.md — Business India Project Context

**Read this file first in every new session.** It tells you what this project is, the ground rules, the file layout, and where to look for more detail.

---

## Project

**Business India** is an Indian-themed Monopoly game built in Flutter for mobile (Android/iOS) and desktop. Local multiplayer (2–6 players, pass-and-play on one device). Goal: a **published-quality** game — polished UI, smooth animations, correct rules, Indian city theming with ₹ (rupees).

### The user
- **Non-coder.** Gives direction; Claude writes all the code and makes all technical decisions.
- Cares about: premium UI/UX, smooth animations, correct game rules, "looks published not amateur."
- Platform: Ubuntu Linux with Flutter installed (3.32.4 / Dart 3.8.1).

### Theme translation
- Currency: **US$ → ₹ rupees**, integer only, Indian number formatting (use `intl` package). Starting balance: ₹15,00,000 (15 lakh) — proportional to classic $1500.
- Board: Indian cities grouped by region. Suggested mapping (finalize in Phase 1):
  - Brown → Nashik, Ranchi
  - Light blue → Jaipur, Lucknow, Bhopal
  - Pink → Chandigarh, Indore, Nagpur
  - Orange → Kochi, Coimbatore, Vishakhapatnam
  - Red → Ahmedabad, Pune, Surat
  - Yellow → Hyderabad, Bangalore, Chennai
  - Green → Kolkata, Delhi, Mumbai (suburbs)
  - Dark blue → Mumbai (South), Mumbai (Bandra)
  - Railways → Mumbai Central, Howrah Jn, Chennai Central, New Delhi
  - Utilities → Tata Power, Indian Oil
  - Taxes → Income Tax, Luxury Tax (GST variant)

---

## Ground rules for Claude

1. **The source of truth for rules is `MONOPOLY_RULES_REFERENCE.md`.** If something contradicts that file, the file wins. Flag discrepancies.
2. **UI layer must NEVER import from `lib/game_logic/`'s internals except through a thin adapter.** Game logic contains zero Flutter imports. Keep it that way.
3. **Money is `int` (rupees)**, never `double`. The current codebase uses `double` — migrate in Phase 2.
4. **Flame is the game canvas.** As of the 2026-04-20 cartoon rebuild, Flame (`flame: ^1.18.0`) renders the board, tokens, dice, houses, and particle effects in `lib/game/`. Material widgets are the *outer* scaffold (routing, screens, dialogs, overlays). They NEVER appear inside the board canvas, and the board canvas NEVER uses Material widgets. Rule: if it lives inside the 11×11 square, it's Flame; if it sits around the edges (HUD, action bar, modals), it's Flutter with CartoonPanel/CartoonButton.
5. **State management**: `provider` + `ChangeNotifier`. One `GameController extends ChangeNotifier` wraps `GameEngine` and exposes reactive state to the UI.
6. **Persistence is deferred until Phase 7.** Do not bring Hive back. When needed, use `shared_preferences` with JSON.
7. **Always run `flutter analyze` and `flutter test` before declaring any task done.** Target: zero errors, all tests passing.
8. **Work phase-by-phase as laid out in `BUILD_ROADMAP.md`.** Each phase ends in something testable/playable.
9. **Responsive**: phones (360–480 dp), tablets (600+ dp), and landscape. Use `LayoutBuilder` and scale clamps — do not divide by a magic 400.
10. **Theme centrally.** `lib/app/theme/` — `game_colors.dart`, `game_fonts.dart`, `game_shapes.dart`, `game_theme.dart`. Zero hardcoded colors/shadows in widget files; everything composes `GameColors` and `CartoonShape.cartoonBox`. Shadows are always HARD (blurRadius: 0), offset down-right.
11. **No Material aesthetic inside the game.** Inside any game flow (menu, setup, game screen, overlays): no `Card`, no `ListTile`, no `AppBar`, no `ElevatedButton`, no `Switch`, no soft Material shadows. Use `CartoonButton`, `CartoonPanel`, `CartoonDialog`, `CartoonToggle`, `CartoonChip`. `Scaffold` is OK as an outer structural element only.

---

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.32.4 / Dart 3.8.1 |
| Game canvas | `flame` 1.18.x (board, tokens, dice, particles) |
| Audio | `flame_audio` + `audioplayers` (sfx stubs until sound assets ship) |
| UI animation | `flutter_animate`, `gap` |
| State management | `provider` 6.x + `ChangeNotifier` |
| SVG | `flutter_svg` |
| Fonts | `google_fonts` — Fredoka (display), Nunito (body) |
| Number formatting | `intl` (for lakh/crore) |
| Asset bootstrap | `http` + `archive` + `path_provider` (Kenney download script at `tool/fetch_kenney.dart`) |
| Storage (future) | `shared_preferences` (JSON) |
| Testing | `flutter_test` |

---

## Folder structure (2026-04-20 cartoon rebuild)

```
lib/
├─ main.dart                           — Entrypoint; provider + MaterialApp + splash route
├─ app/                                — UI layer (Flutter widgets)
│  ├─ controllers/
│  │  ├─ game_controller.dart          — ChangeNotifier wrapping GameEngine
│  │  └─ sound_manager.dart            — audio stub / facade
│  ├─ theme/
│  │  ├─ game_colors.dart              — saturated cartoon palette
│  │  ├─ game_fonts.dart               — Fredoka + Nunito presets (GoogleFonts)
│  │  ├─ game_shapes.dart              — CartoonShape.cartoonBox etc.
│  │  └─ game_theme.dart               — minimal ThemeData
│  ├─ widgets/
│  │  ├─ cartoon_button.dart           — hard-shadow scale-on-press button
│  │  ├─ cartoon_panel.dart            — rounded cartoon surface + CartoonChip
│  │  ├─ cartoon_dialog.dart           — replaces AlertDialog
│  │  ├─ cartoon_toggle.dart           — chunky switch (no Material Switch)
│  │  └─ money_counter.dart            — animated rupee counter with ± popups
│  └─ screens/
│     ├─ backdrop.dart                 — sunset gradient + floating coin/dice/house
│     ├─ splash_screen.dart
│     ├─ menu_screen.dart
│     ├─ player_setup_screen.dart
│     ├─ game_screen.dart              — HUD + GameWidget(Flame) + action bar + overlays
│     ├─ game_overlays.dart            — landing / auction / card / jail / trade / property / gameover
│     ├─ how_to_play_screen.dart
│     └─ settings_screen.dart
├─ game/                               — Flame canvas layer. ZERO Material widgets.
│  ├─ business_game.dart               — FlameGame; owns board, tokens, dice
│  ├─ art/                             — CustomPainters (cartoon art): token, dice, house,
│  │                                     hotel, coin, table, trophy, confetti, card back,
│  │                                     city landmark silhouettes
│  └─ components/                      — Flame components: board, tile, token, dice,
│                                        house, hotel, money particle, confetti
├─ game_logic/                         — ZERO Flutter imports. Engine, models, editions.
└─ utils/
   └─ rupee_formatter.dart             — ₹15,00,000 / ₹1.5L formatting

test/
├─ game_engine_test.dart
├─ board_india_test.dart
├─ phase2_rules_test.dart
└─ phase3_flow_test.dart               — exercises GameController

tool/
└─ fetch_kenney.dart                   — optional one-shot to download Kenney board-game pack

assets/
├─ avatars/                            — legacy PNGs (superseded by TokenPainter)
├─ images/{tiles,tokens,cards,ui,backgrounds}/ — Kenney pack lands here if fetched
├─ rive/                               — reserved for future Rive animations
└─ generated/                          — reserved for runtime-rendered caches
```

---

## Current state (as of Cartoon Rebuild, 2026-04-20)

Flat Material UI from Phase 3 has been replaced with a Flame-backed cartoon look (Monopoly Go / Board Kings style). Game logic is unchanged — 105 existing tests still pass.

- ✅ `flutter analyze` — target 0 errors (cosmetic infos OK)
- ✅ `flutter test` — 105 tests (engine + controller flow), all pass
- ✅ `flutter build apk --debug` — compiles
- ✅ Phase 0: old `lib/{screens,widgets,controllers,theme}` deleted; deps rebuilt
- ✅ Phase 1: 10 cartoon CustomPainters in `lib/game/art/` (token, house, hotel, dice, coin, table, card backs, trophy, confetti, city-landmark silhouettes for all 40 tiles). Kenney download is a one-shot script; sandbox blocked HTTP so painters are primary.
- ✅ Phase 2: `lib/app/theme/` — saturated palette, Fredoka+Nunito, hard-shadow `CartoonShape`
- ✅ Phase 3: `CartoonButton`, `CartoonPanel`, `CartoonDialog`, `CartoonToggle`, `MoneyCounter`
- ✅ Phase 4: Flame game + board/tile/corner/token/dice/house/hotel/particle/confetti components
- ✅ Phase 5: splash, menu, setup, game, how-to-play, settings screens all rebuilt in cartoon look; 7 overlays (property landing, auction, card reveal, jail choice, property manager, trade, game over)
- ✅ Phase 6: controller relocated to `lib/app/controllers/game_controller.dart` (same public API)
- ✅ Phase 7: LayoutBuilder at every screen root; Compact/Regular/Expanded breakpoints

### Visual rules (non-negotiable)
- Rounded corners ≥ 16px. Material's 4–8px default is banned.
- Borders ≥ 3px, solid dark outline (`GameColors.outline`).
- Shadows are HARD and OFFSET (`blurRadius: 0`, down-right). No Material blur.
- Colors come from `GameColors.happy{Red,Blue,Green,Yellow,Purple,Orange,Pink,Teal}` or `.gold`.
- Fonts: Fredoka for display/numbers/buttons, Nunito for body. No Inter, Roboto, Playfair, Cinzel.

## Engine API used by the UI

- `controller.startGame(slots)` — builds India engine from setup
- `controller.rollDice()` — async (900ms animation), transitions phase
- `controller.buyPendingProperty()` / `auctionPendingProperty()`
- `controller.payToLeaveJail()` / `useGoojfCard()` / `rollForJail()`
- `controller.resolveCard()` — applies the pending Chance/CC draw
- `controller.endTurn()` — advances to next non-bankrupt player

## Key engine API (Phase 2 additions — for UI wiring)

- `engine.movePlayer(d1, d2) → MoveResult{shouldRollAgain, sentToJail}`
- `engine.auctionProperty(property)` — call when a player declines to buy
- `engine.buyProperty()` — current player buys their tile
- `engine.canUpgradeProperty(property, player)` / `engine.upgradeProperty(..., enforceGroupRules: true)`
- `engine.downgradeProperty(property, player)` — half-price refund
- `engine.payToLeaveJail(player)` / `engine.useGoojfToLeaveJail(player)`
- `engine.handleBankruptcy(player, creditor: X?)` — forced resolution
- `engine.handleDeck(card)` — applies a drawn Chance/Community Chest card
- `engine.gameListener = (event, data) { ... }` — UI subscribes here

---

## Essential references

| File | Purpose |
|---|---|
| `MONOPOLY_RULES_REFERENCE.md` | Exhaustive rules reference (all 40 squares, all 32 cards, auction/jail/mortgage/bankruptcy). Use to write tests and verify engine behavior. |
| `PROJECT_AUDIT.md` | Full audit of the pre-cleanup state — rule-by-rule verdicts with `file.dart:line` evidence. |
| `VERDICT.md` | The Option-A decision and rationale. |
| `BUILD_ROADMAP.md` | Phased milestones, each one ending in a testable/playable increment. |

---

## How to work

1. Start each session by reading this file.
2. Check `BUILD_ROADMAP.md` for the current phase and its acceptance criteria.
3. Write or update tests **before or alongside** code — use the `MONOPOLY_RULES_REFERENCE.md` as the spec.
4. `flutter analyze` + `flutter test` before every commit.
5. Commit at phase boundaries with a message like `Phase N: <short description>`.
6. When in doubt, ask the user only about product decisions (theme, feel, priorities). Make all technical decisions yourself.
