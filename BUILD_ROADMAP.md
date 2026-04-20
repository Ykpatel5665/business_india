# Build Roadmap — Business India

Every phase ends in something **testable or playable**. Each row is a self-contained milestone — you can stop between them and the project stays green.

Legend: 🎯 acceptance criteria · 📂 touched files · ⏱ rough effort

---

## ✅ Phase 0 — Cleanup & Foundation (DONE, 2026-04-15)

🎯 Project compiles. `flutter analyze` = 0 errors. Dead code and Flame residue removed. Planning docs in place.

📂 Deleted: broken duplicate `game_edition.dart`, entire `persistence/` folder, stub enum files, `ai_player.dart`, stale `GAME_LOGIC.md`, `PROJECT_GUIDE.md`. Pubspec stripped of `flame`, `flame_audio`, `rive`, `shared_preferences_web`, `hive*`, `path_provider`. Root binaries moved to `docs/design-references/`. Added `google_fonts`, `intl`.

📂 Added: `MONOPOLY_RULES_REFERENCE.md`, `PROJECT_AUDIT.md`, `VERDICT.md`, `CLAUDE.md`, `BUILD_ROADMAP.md`.

Remaining minor warnings (unused imports in old widgets, `Math` prefix, `withOpacity` deprecations) — addressed in Phase 3 when the UI is rebuilt.

---

## ✅ Phase 1 — Indian Board & Rupee Currency (DONE, 2026-04-15)

🎯 Tests prove an Indian board is wired end-to-end; money is integer rupees.

Delivered:
- `lib/game_logic/engine/editions/board_india.dart` — 40 Indian tiles (Nashik → Mumbai Bandra), rupee pricing ×1000 (₹60,000 – ₹4,00,000), ₹15,00,000 starting balance, Indian-flavoured Chance + Community Chest decks.
- `game_factory.dart` — `'india'` case added; `'uk'` kept for reference.
- `lib/utils/rupee_formatter.dart` — Indian lakh/crore grouping (`1500000 → ₹15,00,000`) plus a compact form (`₹1.5L`, `₹1.25Cr`).
- Money migrated `double → int` across `player.dart`, `property.dart`, `bank.dart`, `game_config.dart`, `card.dart`, `trade.dart`, `game_engine.dart`.
- Property.upgrade auto-promotes 4 houses → hotel: takes a hotel from the bank, returns 4 houses, sets `hasHotel = true`, `houses = 0`. Two previously-failing tests now pass.
- `board_tile.dart` — Flutter imports removed (IconData/Color dropped; resolve UI metadata in the presentation layer).
- `handleDeck` — negative `steps` handled; null-target cards (nearest utility/railway) no-op with a `CardSkipped` event (full resolver in Phase 2).
- New suite `test/board_india_test.dart` — factory build, tile-position checks, price-tag spot checks, RupeeFormatter.

State:
- `flutter analyze` — **0 errors** (30 infos/warnings, all UI-layer cosmetics in leftover widgets)
- `flutter test` — **66/66 pass** (58 engine + 8 India)

---

## ✅ Phase 2 — Engine Rule Fixes (DONE, 2026-04-15)

🎯 Every rule bug identified in the audit has a dedicated test and passes.

Delivered (`test/phase2_rules_test.dart`, 23 tests, + existing suites updated):

1. **Doubles rule** — `Player.consecutiveDoubles`; `MoveResult.shouldRollAgain`; 3rd consecutive doubles → jail, no move on the 3rd roll.
2. **Auction on decline** — `auctionProperty()` multi-round, terminates on a full pass without raises; `startAuctionWithBidding` now delegates here.
3. **Per-property rent tables** — `Property.rentTable` (list of 6: base → hotel); flat multipliers kept as legacy fallback for older tests.
4. **Even-building** — engine-level `canUpgradeProperty` rejects builds that would make this property exceed the minimum group level.
5. **Full-group + no-mortgage** — same check requires every group member owned + no mortgages.
6. **Bankruptcy to creditor** — `_bankruptToCreditor`: cash, GOOJF cards, and all properties (incl. mortgaged with 10% transfer fee) move to the creditor.
7. **Bankruptcy to bank** — `_bankruptToBank`: houses/hotels returned, properties auctioned one-by-one; triggered via `handleBankruptcy(player)` with no creditor.
8. **Downgrade refund** — `downgradeProperty(property, player)` refunds `houseCost ~/ 2` and returns the house/hotel to the bank (hotel → 4 houses).
9. **Pass-GO in card moves** — `moveTo(target)` via card awards GO reward when wrapping forward; `Go Back N` does NOT award GO.
10. **Mortgaged RR/Utility** — mortgage check moved to top of `calculateRent`, applies to all property types.
11. **GOOJF return** — each held card is tagged with `DeckOrigin`; `useGoojfToLeaveJail` extracts the card from its used/deck pile and pushes it to the bottom of its originating deck.
12. **Nearest utility / railway** — new `CardType.advanceToNearestUtility` / `...Railroad`; engine's `_advanceToNearest` scans forward from the player's tile, awarding GO if wrapped.
13. **Mortgage transfer fee on trade** — `processTrade` charges `mortgageTransferFee` (10%) to the recipient of any mortgaged property; bankruptcy-to-creditor path also applies the fee.
14. **`payRent` flow** — graceful bankruptcy rather than thrown exceptions; legacy tests that expected a throw were updated to assert `isBankrupt` instead.

Architectural side effects:
- New `MoveResult` return type on `movePlayer` so UI knows whether to re-enable the roll button.
- `Card.origin: DeckOrigin?` for correct return-to-deck behaviour.
- `Player.goojfCards: List<DeckOrigin>` replaces the old integer count (with a back-compat getter/setter on `getOutOfJailCards`).
- `isMonopoly` now works for utilities (enables 10× dice rent) as well as streets.
- Deterministic RNG support on `GameEngine(random: ...)` for reproducible tests.

Deferred to later phases (not strictly rule fixes):
- Typed payment results on the public API — internal engine now uses `PayOutcome` but callers still see exceptions for low-level `Player.pay`. Cosmetic, not a correctness issue.
- Splitting `game_engine.dart` into sub-managers — file is 580 LOC and legible; split when it grows further.

State after Phase 2:
- `flutter analyze` — **0 errors** (24 cosmetic infos in leftover UI widgets)
- `flutter test` — **89/89 pass** (58 engine + 8 India + 23 Phase 2)

⏭ Next: Phase 3 — first playable UI (landing → setup → board with dice + moving tokens).

---

## ✅ Phase 3 REBUILD — Ironjaw-quality overhaul (DONE, 2026-04-15)

The original Phase 3 UI felt too flat. This rebuild replicates the flow of
"Business Game" by Ironjaw Studios:

- **9 screens**: splash (particles+shimmer+progress), main menu, game mode, player setup, game screen, settings, how-to-play
- **30+ widget files** across `widgets/board/`, `widgets/dice/`, `widgets/cards/`, `widgets/panels/`, `widgets/dialogs/`, `widgets/common/`
- **TurnPhase state machine** (11 phases) with context-sensitive action panel
- **Cream board on felt table** with corner tile variants, InteractiveViewer zoom/pan, animated tokens with stepped-path movement, 3D dice with X/Y perspective rotation
- **Property landing card** with full rent table, mortgage/house-cost cells
- **Auction dialog** with +₹10K/₹50K/₹100K bid chips and round-robin bidding
- **Chance/CC cards** with 3D flip reveal
- **Property manager** sheet with even-build rule and mortgage toggle
- **Trade panel** (two-column, partner picker, cash ±)
- **Game over** with confetti particles and trophy pop
- **Sound manager** scaffolded (stubs for audio assets)

Verified:
- `flutter analyze` — **0 errors** (39 cosmetic infos)
- `flutter test` — **89/89 pass** (engine untouched)
- `flutter build apk --debug` — compiles successfully

⏭ Next: polish + AI bots + audio assets + persistence.

## ✅ Phase 3 — First Playable UI (DONE, 2026-04-15)

🎯 Full playable game loop: landing → setup → board with dice, tokens, buy/auction/rent/cards/jail/win.

**Scope creep:** the roadmap called only for "dice + move" at Phase 3, but we shipped the full playable loop (Phases 3 + 4 combined). Buy/auction, rent, jail choices, Chance/CC card reveal, and the game-over overlay are all wired. Houses/hotels and trading UI (Phase 5) remain future work.

Delivered:
- **Full UI teardown** — removed `lib/screens/` and `lib/widgets/` (old landing buttons/clouds), relocated avatars to `assets/avatars/`.
- **Design system** — `lib/theme/app_colors.dart` (jewel palette + 10 group colors + 6 player colors), `app_typography.dart` (Cinzel display + Inter body via `google_fonts`), `app_theme.dart` (spacing / radii / shadows / gradients / ThemeData.dark).
- **Controller** — `lib/controllers/game_controller.dart` (`ChangeNotifier` over `GameEngine`): turn phases, pending property/card, rolling flag, event log derived from engine events.
- **Screens**:
  - `landing_screen.dart` — minimal hero with gold ₹ emblem + "New Game" CTA
  - `setup_screen.dart` — 2–6 player slots with name, color picker (6), avatar picker (10), duplicate-prevention
  - `game_screen.dart` — HUD + board + event log + context-sensitive action bar + modal overlays
- **Board widgets** (`lib/widgets/`):
  - `monopoly_board.dart` — 11×11 perimeter grid with felt background, center brand panel housing dice, tokens overlaid as animated `Positioned` pieces
  - `board_tile_view.dart` — tile variants (corner, tax, chance, community chest, property street with color strip on inner edge, railway/utility with icon); improvement dots + hotel icon; compact rupee formatting
  - `player_token.dart` — radial-gradient disc with numbered badge and glow
  - `dice_view.dart` — 2 animated dice with CustomPainter dot faces, tumble + bounce during roll
  - `player_hud.dart` — spotlight for current player (avatar, name, balance) + horizontal pip strip of other players
  - `action_bar.dart` — phase-aware buttons (Roll / Buy / Auction / End Turn / Jail options / Reveal Card / Back to Lobby)
  - `event_log.dart` — collapsible rolling log
  - `card_reveal_dialog.dart` — modal reveal for Chance / Community Chest draws
- **Routing + providers** wired in `main.dart`.

Verified:
- `flutter analyze` — **0 errors** (18 infos, all cosmetic)
- `flutter test` — **89/89 pass** (engine untouched)
- `flutter build linux --debug` — compiles cleanly (produces `build/linux/x64/debug/intermediates_do_not_run/business_india`)

⏭ Next: Phase 5 — houses/hotels/mortgage/trading UI (buy the build menu, mortgage toggle, trade modal). Phase 4's economy was absorbed into Phase 3.

---

## Phase 4 — Buy, Rent, Auction UI 🎯 economy is alive

- Property landing dialog: "Buy ₹X / Pass" with auto-auction on pass.
- Rent auto-payment with balance animation.
- Auction modal: round-robin bidding UI, all players bid, highest wins.
- Bankruptcy modal (to creditor / to bank).
- Transactions log side panel.

🎯 Acceptance: a full 2-player money game plays to bankruptcy. End-game screen shows winner.

⏱ ~2 sessions

---

## Phase 5 — Houses, Hotels, Mortgage, Trading, Jail UI

- Build menu: pick a property in your color group, build/sell house. Even-building enforced by UI (sell-first hint).
- Mortgage toggle on property cards with 10% interest math shown clearly.
- Trade modal: two-column drag-to-trade (cash + properties + GOOJF cards).
- Jail UI: "Pay ₹50 / Use card / Roll doubles" prompt on turn start.
- Chance / Community Chest card reveal animation.

🎯 Acceptance: a full rule-correct game playable including all above.

⏱ ~2 sessions

---

## Phase 6 — Polish & Published Feel

- Finalize theme: Indian art direction — mandala patterns, warm gold/maroon palette, festival-lantern accents.
- Sound design: dice clatter, cash register, property buy jingle, bankruptcy theme. Background ambient music toggle.
- Haptics on dice land, turn change.
- Proper responsive layouts for phone portrait, phone landscape, tablet.
- Accessibility pass: text scale, high-contrast mode, Hindi/English toggle (deferred if scope creeps).
- Widget tests for critical screens; golden tests for board layout.

🎯 Acceptance: screen recordings look publishable. Runs smoothly at 60fps on a mid-range Android phone.

⏱ ~2 sessions

---

## Phase 7 — Persistence & Settings

- Save/load game state to `shared_preferences` as JSON (roll your own `toJson`/`fromJson` on the engine).
- Settings screen: sound on/off, haptics on/off, Free Parking house rule toggle, starting balance.
- "Continue" button on landing screen when a save exists.

🎯 Acceptance: quit mid-game, reopen, resume exactly where you left off.

⏱ ~1 session

---

## Post-roadmap (future, not committed)

- AI opponents (revive & rewrite `ai_player.dart` properly with tiered strategies)
- Online multiplayer (Firebase or Supabase backend)
- More boards (regional India variants, international)
- In-app purchases for cosmetic board skins
- Play Store / App Store release
