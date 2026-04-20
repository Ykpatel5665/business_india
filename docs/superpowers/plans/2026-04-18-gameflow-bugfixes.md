# Game Flow Bugfixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all 10 game-flow bugs so the engine + controller produce a rules-correct, crash-free Monopoly game.

**Architecture:** All fixes are in the pure-Dart engine layer (`lib/game_logic/`) and the controller (`lib/controllers/game_controller.dart`). No UI widget changes. Every fix gets a dedicated test in `test/phase3_flow_test.dart`.

**Tech Stack:** Flutter/Dart, `flutter_test`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `test/phase3_flow_test.dart` | CREATE | All new tests for this plan |
| `lib/game_logic/engine/editions/board_india.dart` | MODIFY | Fix Chance card types, add rent tables, add luxury tax amount |
| `lib/game_logic/models/card.dart` | MODIFY | Route payments through engine instead of raw `player.pay()` |
| `lib/game_logic/engine/game_engine.dart` | MODIFY | Fix `handleJailExit` GOOJF logic, expose `chargePlayer` for cards, add `luxuryTaxAmount` handling |
| `lib/game_logic/models/game_config.dart` | MODIFY | Add `luxuryTaxAmount` field |
| `lib/game_logic/models/board_tile.dart` | MODIFY | Add optional `taxAmount` per tile |
| `lib/controllers/game_controller.dart` | MODIFY | Store `MoveResult` across async UI interactions, add `executeTrade` method |

---

### Task 1: Fix "Advance to Nearest Utility/Railroad" Chance cards

The India board has two Chance cards that use `CardType.moveTo` with `targetTileIndex: null`. They should use `CardType.advanceToNearestUtility` and `CardType.advanceToNearestRailroad` which the engine already handles. These cards currently do nothing (silently skipped).

**Files:**
- Modify: `lib/game_logic/engine/editions/board_india.dart:147-149`
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/phase3_flow_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:business_india/game_logic/engine/game_engine.dart';
import 'package:business_india/game_logic/engine/game_factory.dart';
import 'package:business_india/game_logic/models/player.dart';
import 'package:business_india/game_logic/models/property.dart';
import 'package:business_india/game_logic/models/board_tile.dart';
import 'package:business_india/game_logic/models/card.dart' as game_card;
import 'package:business_india/game_logic/models/enums.dart';
import 'package:business_india/game_logic/models/game_config.dart';
import 'package:business_india/game_logic/engine/editions/board_india.dart';

void main() {
  group('Task 1 — Nearest Utility/Railroad Chance cards', () {
    test('India Chance deck contains advanceToNearestUtility card type', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final deck = edition.getChanceDeck();
      final utilityCards = deck.where(
        (c) => c.type == CardType.advanceToNearestUtility,
      );
      expect(utilityCards.length, 1,
          reason: 'Chance deck must have exactly 1 "nearest utility" card');
    });

    test('India Chance deck contains advanceToNearestRailroad card type', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final deck = edition.getChanceDeck();
      final rrCards = deck.where(
        (c) => c.type == CardType.advanceToNearestRailroad,
      );
      expect(rrCards.length, 1,
          reason: 'Chance deck must have exactly 1 "nearest railroad" card');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — cards have `CardType.moveTo`, not the expected types.

- [ ] **Step 3: Fix the two Chance cards in board_india.dart**

In `lib/game_logic/engine/editions/board_india.dart`, replace the two broken cards (around lines 147-149):

Old:
```dart
    Card(description: 'Advance to nearest Utility. Throw dice and pay owner 10× if owned; else you may buy from bank.',
        type: CardType.moveTo, targetTileIndex: null),
    Card(description: 'Advance to nearest Railway. Pay owner double the usual rent; else you may buy from bank.',
        type: CardType.moveTo, targetTileIndex: null),
```

New:
```dart
    Card(description: 'Advance to nearest Utility. Throw dice and pay owner 10× if owned; else you may buy from bank.',
        type: CardType.advanceToNearestUtility),
    Card(description: 'Advance to nearest Railway. Pay owner double the usual rent; else you may buy from bank.',
        type: CardType.advanceToNearestRailroad),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: PASS

- [ ] **Step 5: Run full test suite**

Run: `flutter test`
Expected: All 89 existing + 2 new tests pass.

- [ ] **Step 6: Commit**

```bash
git add test/phase3_flow_test.dart lib/game_logic/engine/editions/board_india.dart
git commit -m "fix: use correct CardType for nearest utility/railroad Chance cards"
```

---

### Task 2: Add per-property rent tables to India board

All 22 street properties in `board_india.dart` use the legacy fallback multiplier `[1, 5, 15, 45, 65, 75]` which produces wrong rents at 4-house and hotel levels. Each property needs an explicit `rentTable: [base, 1h, 2h, 3h, 4h, hotel]` matching the official Monopoly values scaled ×1000.

**Files:**
- Modify: `lib/game_logic/engine/editions/board_india.dart:38-127`
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing test**

Add to `test/phase3_flow_test.dart`:

```dart
  group('Task 2 — India board rent tables', () {
    test('every street property has an explicit rentTable', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final board = edition.getBoard();
      final streets = board
          .where((t) => t.property != null && t.property!.type == PropertyType.street)
          .map((t) => t.property!)
          .toList();
      expect(streets.length, 22);
      for (final p in streets) {
        expect(p.rentTable, isNotNull,
            reason: '${p.name} must have an explicit rentTable');
        expect(p.rentTable!.length, 6,
            reason: '${p.name} rentTable must have 6 entries [base,1h,2h,3h,4h,hotel]');
        expect(p.rentTable![0], p.baseRent,
            reason: '${p.name} rentTable[0] must equal baseRent');
      }
    });

    test('Nashik hotel rent is 250000 (not legacy 150000)', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final board = edition.getBoard();
      final nashik = board[1].property!;
      expect(nashik.getHouseRent(5), 250000); // hotel
    });

    test('Mumbai Bandra hotel rent is 2000000', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final board = edition.getBoard();
      final bandra = board[39].property!;
      expect(bandra.getHouseRent(5), 2000000); // hotel
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — `rentTable` is null, hotel rents are wrong.

- [ ] **Step 3: Add rent tables to all 22 street properties**

In `lib/game_logic/engine/editions/board_india.dart`, update each street property. The rent tables are the official US Monopoly values ×1000:

```
Brown group (cg 0):
  Nashik:    rentTable: [2000, 10000, 30000, 90000, 160000, 250000]
  Ranchi:    rentTable: [4000, 20000, 60000, 180000, 320000, 450000]

Light blue (cg 1):
  Jaipur:    rentTable: [6000, 30000, 90000, 270000, 400000, 550000]
  Lucknow:   rentTable: [6000, 30000, 90000, 270000, 400000, 550000]
  Bhopal:    rentTable: [8000, 40000, 100000, 300000, 450000, 600000]

Pink (cg 2):
  Chandigarh: rentTable: [10000, 50000, 150000, 450000, 625000, 750000]
  Indore:     rentTable: [10000, 50000, 150000, 450000, 625000, 750000]
  Nagpur:     rentTable: [12000, 60000, 180000, 500000, 700000, 900000]

Orange (cg 3):
  Kochi:            rentTable: [14000, 70000, 200000, 550000, 750000, 950000]
  Coimbatore:       rentTable: [14000, 70000, 200000, 550000, 750000, 950000]
  Vishakhapatnam:   rentTable: [16000, 80000, 220000, 600000, 800000, 1000000]

Red (cg 4):
  Ahmedabad: rentTable: [18000, 90000, 250000, 700000, 875000, 1050000]
  Pune:      rentTable: [18000, 90000, 250000, 700000, 875000, 1050000]
  Surat:     rentTable: [20000, 100000, 300000, 750000, 925000, 1100000]

Yellow (cg 5):
  Hyderabad: rentTable: [22000, 110000, 330000, 800000, 975000, 1150000]
  Bangalore: rentTable: [22000, 110000, 330000, 800000, 975000, 1150000]
  Chennai:   rentTable: [24000, 120000, 360000, 850000, 1025000, 1200000]

Green (cg 6):
  Kolkata:        rentTable: [26000, 130000, 390000, 900000, 1100000, 1275000]
  Delhi:          rentTable: [26000, 130000, 390000, 900000, 1100000, 1275000]
  Mumbai Suburbs: rentTable: [28000, 150000, 450000, 1000000, 1200000, 1400000]

Dark blue (cg 7):
  Mumbai South:  rentTable: [35000, 175000, 500000, 1100000, 1300000, 1500000]
  Mumbai Bandra: rentTable: [50000, 200000, 600000, 1400000, 1700000, 2000000]
```

Example for Nashik (position 1):
```dart
    BoardTile(position: 1, type: TileType.property, label: 'Nashik',
        property: Property(name: 'Nashik', price: 60000, baseRent: 2000, colorGroup: 0, houseCost: 50000,
            rentTable: [2000, 10000, 30000, 90000, 160000, 250000])),
```

Apply the same pattern to all 22 street properties.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: PASS

- [ ] **Step 5: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/game_logic/engine/editions/board_india.dart test/phase3_flow_test.dart
git commit -m "fix: add per-property rent tables to India board (correct 4h/hotel rents)"
```

---

### Task 3: Differentiate Income Tax vs Luxury Tax

Both tax tiles charge the same `config.taxAmount` (₹200K). Real Monopoly: Income Tax = $200 (₹200K), Luxury Tax = $100 (₹100K). Fix by adding an optional `taxAmount` field to `BoardTile` and using it in the engine's `_handleTaxLanding`.

**Files:**
- Modify: `lib/game_logic/models/board_tile.dart`
- Modify: `lib/game_logic/engine/game_engine.dart:234-243`
- Modify: `lib/game_logic/engine/editions/board_india.dart:125` (Luxury Tax tile)
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing test**

Add to `test/phase3_flow_test.dart`:

```dart
  group('Task 3 — Tax tile differentiation', () {
    test('Income Tax charges 200000, Luxury Tax charges 100000', () {
      final players = [
        Player(name: 'P1', tokenId: 1, balance: 1500000),
        Player(name: 'P2', tokenId: 2, balance: 1500000),
      ];
      final engine = MonopolyGameEngineBuilder(
        players: players,
        config: indiaDefaultConfig,
      ).create('india');
      engine.status = GameStatus.active;

      // Move P1 to Income Tax (position 4)
      final p1 = engine.players[0];
      final balanceBefore1 = p1.balance;
      p1.position = 4;
      engine.handleLanding(p1);
      expect(p1.balance, balanceBefore1 - 200000,
          reason: 'Income Tax should charge ₹2,00,000');

      // Move P1 to Luxury Tax (position 38)
      final balanceBefore2 = p1.balance;
      p1.position = 38;
      engine.handleLanding(p1);
      expect(p1.balance, balanceBefore2 - 100000,
          reason: 'Luxury Tax should charge ₹1,00,000');
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — both charge ₹200K.

- [ ] **Step 3: Add taxAmount to BoardTile**

In `lib/game_logic/models/board_tile.dart`:

```dart
class BoardTile {
  final int position;
  final TileType type;
  final String label;
  final Property? property;
  /// Per-tile tax amount. If null, engine falls back to `config.taxAmount`.
  final int? taxAmount;

  BoardTile({
    required this.position,
    required this.type,
    required this.label,
    this.property,
    this.taxAmount,
  });

  // ... existing getters unchanged ...
}
```

- [ ] **Step 4: Update engine to use per-tile taxAmount**

In `lib/game_logic/engine/game_engine.dart`, change `_handleTaxLanding`:

Old:
```dart
  void _handleTaxLanding(Player player) {
    final outcome = _chargePlayer(player, config.taxAmount, creditor: null);
    if (outcome == PayOutcome.paid) {
      bank.addToFreeParking(config.taxAmount);
      notifyGameEvents("TaxPaid", data: {
        "player": player.name,
        "amount": config.taxAmount,
      });
    }
  }
```

New:
```dart
  void _handleTaxLanding(Player player) {
    final tile = board[player.position];
    final amount = tile.taxAmount ?? config.taxAmount;
    final outcome = _chargePlayer(player, amount, creditor: null);
    if (outcome == PayOutcome.paid) {
      bank.addToFreeParking(amount);
      notifyGameEvents("TaxPaid", data: {
        "player": player.name,
        "amount": amount,
      });
    }
  }
```

- [ ] **Step 5: Set Luxury Tax amount on India board**

In `lib/game_logic/engine/editions/board_india.dart`, update the Luxury Tax tile (position 38):

Old:
```dart
    BoardTile(position: 38, type: TileType.tax, label: 'Luxury Tax'),
```

New:
```dart
    BoardTile(position: 38, type: TileType.tax, label: 'Luxury Tax', taxAmount: 100000),
```

- [ ] **Step 6: Run tests**

Run: `flutter test`
Expected: All tests pass including the new tax test.

- [ ] **Step 7: Commit**

```bash
git add lib/game_logic/models/board_tile.dart lib/game_logic/engine/game_engine.dart lib/game_logic/engine/editions/board_india.dart test/phase3_flow_test.dart
git commit -m "fix: differentiate Income Tax (200K) from Luxury Tax (100K)"
```

---

### Task 4: Fix card payments to handle bankruptcy gracefully

`card.dart` methods `applyEffect`, `_applyPropertyRepairs`, `_applyPayOtherPlayers` call `player.pay()` directly which throws on insufficient funds. `_applyCollectFromOtherPlayers` uses `bypassFundCheck: true` which lets balances go negative. All card payments must route through the engine's `_chargePlayer` for graceful bankruptcy.

**Files:**
- Modify: `lib/game_logic/models/card.dart:41-97`
- Modify: `lib/game_logic/engine/game_engine.dart` (make `chargePlayer` available to cards)
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing tests**

Add to `test/phase3_flow_test.dart`:

```dart
  group('Task 4 — Card payments handle bankruptcy', () {
    test('pay card with insufficient funds triggers bankruptcy, not crash', () {
      final engine = buildTestEngine(balance: 10);
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      final card = game_card.Card(
        description: 'Pay 500',
        type: CardType.pay,
        amount: 500,
      );
      // Should NOT throw — should bankrupt the player gracefully.
      expect(() => card.applyEffect(p1, engine), returnsNormally);
      expect(p1.isBankrupt, true);
    });

    test('propertyRepairs card with insufficient funds triggers bankruptcy', () {
      final engine = buildTestEngine(balance: 10);
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      // Give P1 a property with houses to trigger repair costs.
      final prop = engine.board[1].property!;
      prop.owner = p1;
      p1.ownedProperties.add(prop);
      prop.houses = 3;
      final card = game_card.Card(
        description: 'Repairs',
        type: CardType.propertyRepairs,
        amount: 25,   // per house
        amount2: 100,  // per hotel
      );
      expect(() => card.applyEffect(p1, engine), returnsNormally);
      expect(p1.isBankrupt, true);
    });

    test('collectFromOtherPlayers does not make payers go negative', () {
      final engine = buildTestEngine(balance: 5);
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      final p2 = engine.players[1];
      p2.balance = 5;
      final card = game_card.Card(
        description: 'Collect 50 from each',
        type: CardType.collectFromOtherPlayers,
        amount: 50,
      );
      card.applyEffect(p1, engine);
      // P2 couldn't afford 50, so they go bankrupt — balance should NOT be negative.
      expect(p2.balance, greaterThanOrEqualTo(0));
      expect(p2.isBankrupt, true);
    });

    test('payOtherPlayers bankrupts payer if they cannot afford all payments', () {
      final engine = buildTestEngine(balance: 30);
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      final card = game_card.Card(
        description: 'Pay each player 50',
        type: CardType.payOtherPlayers,
        amount: 50,
      );
      card.applyEffect(p1, engine);
      expect(p1.isBankrupt, true);
    });
  });
```

Also add the `buildTestEngine` helper at the top of the file (same as in `phase2_rules_test.dart`):

```dart
/// Minimal 40-tile test board. Same as phase2_rules_test.dart.
GameEngine buildTestEngine({
  int balance = 1500,
  Random? random,
}) {
  final board = <BoardTile>[
    BoardTile(position: 0, type: TileType.go, label: 'Go'),
    BoardTile(position: 1, type: TileType.property, label: 'Brown 1',
      property: Property(name: 'Brown 1', price: 60, baseRent: 2, colorGroup: 0, houseCost: 50,
          rentTable: [2, 10, 30, 90, 160, 250])),
    BoardTile(position: 2, type: TileType.communityChest, label: 'CC'),
    BoardTile(position: 3, type: TileType.property, label: 'Brown 2',
      property: Property(name: 'Brown 2', price: 60, baseRent: 4, colorGroup: 0, houseCost: 50,
          rentTable: [4, 20, 60, 180, 320, 450])),
    BoardTile(position: 4, type: TileType.tax, label: 'Tax'),
    BoardTile(position: 5, type: TileType.property, label: 'Railroad A',
      property: Property(name: 'Railroad A', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
    for (var i = 6; i <= 9; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 10, type: TileType.jail, label: 'Jail'),
    BoardTile(position: 11, type: TileType.property, label: 'Utility A',
      property: Property(name: 'Utility A', price: 150, baseRent: 4, colorGroup: 9, type: PropertyType.utility)),
    for (var i = 12; i <= 29; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Filler'),
    BoardTile(position: 30, type: TileType.goToJail, label: 'GoToJail'),
    for (var i = 31; i <= 35; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Filler'),
    BoardTile(position: 36, type: TileType.property, label: 'Railroad B',
      property: Property(name: 'Railroad B', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
    for (var i = 37; i <= 39; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Filler'),
  ];
  final p1 = Player(name: 'P1', tokenId: 1, balance: balance);
  final p2 = Player(name: 'P2', tokenId: 2, balance: balance);
  return GameEngine(
    players: [p1, p2],
    board: board,
    chanceDeck: [],
    communityChestDeck: [],
    config: const GameConfig(),
    random: random,
  );
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — `pay` card throws exception, `collectFromOtherPlayers` produces negative balance.

- [ ] **Step 3: Add `chargePlayer` public method to GameEngine**

In `lib/game_logic/engine/game_engine.dart`, add a public wrapper (the existing `_chargePlayer` stays private):

```dart
  /// Public charge path used by Card effects that need bankruptcy handling.
  /// Returns the outcome so callers know whether the player went bankrupt.
  PayOutcome chargePlayer(Player player, int amount, {Player? creditor}) {
    return _chargePlayer(player, amount, creditor: creditor);
  }
```

- [ ] **Step 4: Rewrite card.dart payment methods to use engine.chargePlayer**

In `lib/game_logic/models/card.dart`, replace the payment paths:

Replace the `applyEffect` switch case for `CardType.pay`:
```dart
      case CardType.pay:
        gameEngine.chargePlayer(player, amount!, creditor: null);
        break;
```

Replace `_applyPropertyRepairs`:
```dart
  void _applyPropertyRepairs(Player player, GameEngine gameEngine) {
    int houseCount = 0;
    int hotelCount = 0;
    for (final property in player.ownedProperties) {
      houseCount += property.houses;
      if (property.hasHotel) hotelCount++;
    }
    final int total = houseCount * (amount ?? 0) + hotelCount * (amount2 ?? 0);
    if (total > 0) {
      gameEngine.chargePlayer(player, total, creditor: null);
    }
  }
```

Replace `_applyPayOtherPlayers`:
```dart
  void _applyPayOtherPlayers(Player player, GameEngine gameEngine) {
    for (final other in gameEngine.players) {
      if (other != player && !other.isBankrupt) {
        final outcome = gameEngine.chargePlayer(player, amount!, creditor: other);
        if (outcome == PayOutcome.paid) {
          other.receive(amount!);
        }
        if (player.isBankrupt) break;
      }
    }
  }
```

Replace `_applyCollectFromOtherPlayers`:
```dart
  void _applyCollectFromOtherPlayers(Player player, GameEngine gameEngine) {
    for (final other in gameEngine.players) {
      if (other != player && !other.isBankrupt) {
        final outcome = gameEngine.chargePlayer(other, amount!, creditor: player);
        if (outcome == PayOutcome.paid) {
          player.receive(amount!);
        }
      }
    }
  }
```

Update the method signatures — `_applyPropertyRepairs` and the two pay/collect methods now take `GameEngine` as a parameter. Update the calls in `applyEffect`:

```dart
      case CardType.propertyRepairs:
        _applyPropertyRepairs(player, gameEngine);
        break;
```

(The other two already pass `gameEngine`.)

Also add the import at the top of `card.dart`:
```dart
import 'enums.dart';
```
(Already imported — just verify `PayOutcome` is accessible.)

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: All tests pass. The 4 new card-bankruptcy tests pass. Existing card tests in `game_engine_test.dart` still pass.

- [ ] **Step 6: Commit**

```bash
git add lib/game_logic/models/card.dart lib/game_logic/engine/game_engine.dart test/phase3_flow_test.dart
git commit -m "fix: route card payments through engine for graceful bankruptcy handling"
```

---

### Task 5: Fix engine auto-using GOOJF cards involuntarily

`handleJailExit` uses `||` logic that forces GOOJF card usage whenever a player has one and fails to roll doubles, even on turn 1 or 2. Per official rules, GOOJF usage is always the player's choice. The only forced action on the 3rd failed attempt is paying ₹50K.

**Files:**
- Modify: `lib/game_logic/engine/game_engine.dart:270-284`
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing test**

Add to `test/phase3_flow_test.dart`:

```dart
  group('Task 5 — GOOJF card is not auto-used', () {
    test('player with GOOJF who fails jail roll on turn 1 keeps the card', () {
      final engine = buildTestEngine();
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      p1.inJail = true;
      p1.jailTurns = 0;
      p1.position = 10;
      p1.goojfCards.add(DeckOrigin.chance);

      // Roll non-doubles while in jail on turn 1.
      engine.movePlayer(3, 4);

      // Player should still be in jail AND still have their GOOJF card.
      expect(p1.inJail, true, reason: 'Should remain in jail after non-doubles on turn 1');
      expect(p1.goojfCards.length, 1, reason: 'GOOJF card should NOT be auto-used');
      expect(p1.jailTurns, 1);
    });

    test('player forced to pay on 3rd failed jail roll, even with GOOJF card', () {
      final engine = buildTestEngine();
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      p1.inJail = true;
      p1.jailTurns = 2; // This is the 3rd attempt.
      p1.position = 10;
      p1.goojfCards.add(DeckOrigin.chance);
      final balanceBefore = p1.balance;

      engine.movePlayer(3, 4);

      // On 3rd failed roll, player is forced out by paying — NOT by using GOOJF.
      expect(p1.inJail, false);
      expect(p1.goojfCards.length, 1, reason: 'GOOJF card should be preserved');
      expect(p1.balance, balanceBefore - engine.config.jailExitCost);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — engine auto-uses the GOOJF card.

- [ ] **Step 3: Fix handleJailExit to never auto-use GOOJF**

In `lib/game_logic/engine/game_engine.dart`, replace `handleJailExit`:

Old:
```dart
  void handleJailExit(Player player) {
    if (player.jailTurns >= config.maxJailTurns - 1 ||
        player.goojfCards.isNotEmpty) {
      if (player.goojfCards.isNotEmpty) {
        _useGoojfCard(player);
      } else {
        _chargePlayer(player, config.jailExitCost, creditor: null);
      }
      player.inJail = false;
      player.jailTurns = 0;
      notifyGameEvents("PlayerExitedJail", data: {"player": player.name});
    } else {
      player.jailTurns++;
    }
  }
```

New:
```dart
  void handleJailExit(Player player) {
    if (player.jailTurns >= config.maxJailTurns - 1) {
      // 3rd failed attempt: forced to pay bail. GOOJF is never auto-used.
      _chargePlayer(player, config.jailExitCost, creditor: null);
      player.inJail = false;
      player.jailTurns = 0;
      notifyGameEvents("PlayerExitedJail", data: {"player": player.name});
    } else {
      player.jailTurns++;
    }
  }
```

- [ ] **Step 4: Run tests**

Run: `flutter test`
Expected: All tests pass. Verify that the existing GOOJF test in `phase2_rules_test.dart` (line 379) still passes — it tests the `useGoojfToLeaveJail` voluntary path, which is unchanged.

- [ ] **Step 5: Commit**

```bash
git add lib/game_logic/engine/game_engine.dart test/phase3_flow_test.dart
git commit -m "fix: never auto-use GOOJF card; only forced exit is paying bail on 3rd turn"
```

---

### Task 6: Store MoveResult across async UI interactions (doubles fix)

The controller loses the `MoveResult.shouldRollAgain` flag when the UI needs async interaction (buy dialog, card reveal, auction). After buying a property or acknowledging a non-moving card, the phase goes to `postMove` even when doubles were rolled. Fix by storing the pending `MoveResult` in the controller.

**Files:**
- Modify: `lib/controllers/game_controller.dart`
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing tests**

Add to `test/phase3_flow_test.dart`:

```dart
  group('Task 6 — Doubles preserved across async UI', () {
    test('controller preserves doubles after buying a property', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

      // Manually simulate: player rolled doubles and landed on unowned property.
      final p1 = controller.currentPlayer;
      // Move to an unowned property (position 1 = Nashik on India board).
      p1.position = 1;
      controller.lastDice1 = 3;
      controller.lastDice2 = 3; // doubles

      // Simulate the _resolveLanding setting landedBuy.
      // After buying, the phase should go to idle (roll again), not postMove.
      controller.pendingProperty = controller.engine.board[1].property!;

      // Expose the stored move result: doubles = should roll again.
      controller.storeMoveResult(MoveResult(shouldRollAgain: true, sentToJail: false));

      // Player buys.
      controller.buyPendingProperty();

      expect(controller.phase, TurnPhase.idle,
          reason: 'After buying with doubles, player should roll again');
    });

    test('controller preserves doubles after non-moving card', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

      // Simulate: rolled doubles, landed on Chance, drew a "receive money" card.
      controller.storeMoveResult(MoveResult(shouldRollAgain: true, sentToJail: false));
      controller.pendingCard = game_card.Card(
        description: 'Collect 50000',
        type: CardType.receive,
        amount: 50000,
      );

      controller.acknowledgeCard();

      expect(controller.phase, TurnPhase.idle,
          reason: 'After non-moving card with doubles, player should roll again');
    });

    test('controller does NOT grant doubles after Go To Jail card', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

      controller.storeMoveResult(MoveResult(shouldRollAgain: true, sentToJail: false));
      controller.pendingCard = game_card.Card(
        description: 'Go to Jail',
        type: CardType.goToJail,
      );

      controller.acknowledgeCard();

      // Player was sent to jail by card — no doubles bonus.
      expect(controller.phase, isNot(TurnPhase.idle));
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — `storeMoveResult` doesn't exist, and buying goes to `postMove`.

- [ ] **Step 3: Add MoveResult storage to GameController**

In `lib/controllers/game_controller.dart`, add these changes:

1. Add the import for `MoveResult` (already imported via `game_engine.dart`).

2. Add a field to store the pending move result:

```dart
  // After the pendingProperty/pendingCard line (~line 67):
  MoveResult? _pendingMoveResult;
```

3. Add public setter for tests and for `rollDice`:

```dart
  void storeMoveResult(MoveResult result) {
    _pendingMoveResult = result;
  }
```

4. Add a helper to resolve whether to roll again or end turn:

```dart
  void _resolvePostAction() {
    final result = _pendingMoveResult;
    _pendingMoveResult = null;
    if (_phase == TurnPhase.gameOver) return;
    if (currentPlayer.isBankrupt) {
      endTurn();
      return;
    }
    if (result != null && result.shouldRollAgain && !currentPlayer.inJail) {
      _phase = TurnPhase.idle;
    } else {
      _phase = TurnPhase.postMove;
    }
    _clearToast();
    notifyListeners();
  }
```

5. Update `rollDice` to store the MoveResult (around line 170, after `engine.movePlayer`):

After `final result = engine.movePlayer(roll[0], roll[1]);`, add:
```dart
    _pendingMoveResult = result;
```

6. Update `_afterLanding` to use `_pendingMoveResult` instead of the parameter:

Replace the entire `_afterLanding` method:
```dart
  void _afterLanding(MoveResult result) {
    _resolvePostAction();
  }
```

Actually, simpler: just make `_afterLanding` use the stored result:

Old:
```dart
  void _afterLanding(MoveResult result) {
    if (_phase == TurnPhase.gameOver) return;
    if (currentPlayer.isBankrupt) {
      endTurn();
      return;
    }
    if (result.shouldRollAgain && !currentPlayer.inJail) {
      _phase = TurnPhase.idle;
    } else {
      _phase = TurnPhase.postMove;
    }
    _clearToast();
    notifyListeners();
  }
```

New:
```dart
  void _afterLanding([MoveResult? _]) {
    _resolvePostAction();
  }
```

7. Update `buyPendingProperty` to use `_resolvePostAction`:

Old:
```dart
    pendingProperty = null;
    _phase = TurnPhase.postMove;
    notifyListeners();
```

New:
```dart
    pendingProperty = null;
    _resolvePostAction();
```

8. Update `_resolveAuction` to use `_resolvePostAction`:

Old:
```dart
    auction = null;
    _phase = TurnPhase.postMove;
    notifyListeners();
```

New:
```dart
    auction = null;
    _resolvePostAction();
```

9. Update `acknowledgeCard` to use `_resolvePostAction` for non-moving cards:

Replace the block at the end of `acknowledgeCard`:

Old:
```dart
    // Card didn't move us (e.g. pay/receive)
    _phase = currentPlayer.inJail
        ? TurnPhase.goToJailNotice
        : TurnPhase.postMove;
    notifyListeners();
    if (_phase == TurnPhase.goToJailNotice) {
      Future.delayed(const Duration(milliseconds: 900), () {
        _phase = TurnPhase.postMove;
        notifyListeners();
      });
    }
```

New:
```dart
    // Card didn't move us (e.g. pay/receive)
    if (currentPlayer.inJail) {
      _pendingMoveResult = null; // No doubles after going to jail.
      _phase = TurnPhase.goToJailNotice;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 900), () {
        _phase = TurnPhase.postMove;
        notifyListeners();
      });
    } else {
      _resolvePostAction();
    }
```

10. Update `_resetPendingState` to clear `_pendingMoveResult`:

Add `_pendingMoveResult = null;` to `_resetPendingState()`.

- [ ] **Step 4: Run tests**

Run: `flutter test`
Expected: All tests pass, including the 3 new doubles-preservation tests.

- [ ] **Step 5: Commit**

```bash
git add lib/controllers/game_controller.dart test/phase3_flow_test.dart
git commit -m "fix: preserve doubles bonus across buy/auction/card async interactions"
```

---

### Task 7: Wire trade through the controller (UI update + logging)

The trade panel calls `engine.processTrade(trade)` directly, bypassing the controller. This means no `notifyListeners()` call, no log entry, and the UI doesn't refresh.

**Files:**
- Modify: `lib/controllers/game_controller.dart`
- Modify: `lib/widgets/panels/trade_panel.dart:155-171`
- Test: `test/phase3_flow_test.dart`

- [ ] **Step 1: Write failing test**

Add to `test/phase3_flow_test.dart`:

```dart
  group('Task 7 — Trade wired through controller', () {
    test('executeTrade updates log and notifies listeners', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

      // Give P1 a property to trade.
      final prop = controller.engine.board[1].property!; // Nashik
      final p1 = controller.currentPlayer;
      final p2 = controller.engine.players[1];
      prop.owner = p1;
      p1.ownedProperties.add(prop);

      final logCountBefore = controller.log.length;

      controller.executeTrade(
        partner: p2,
        offeredProperties: [prop],
        requestedProperties: [],
        offeredCash: 0,
        requestedCash: 0,
      );

      expect(prop.owner, p2, reason: 'Property should transfer to P2');
      expect(controller.log.length, greaterThan(logCountBefore),
          reason: 'Trade should add a log entry');
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/phase3_flow_test.dart -v`
Expected: FAIL — `executeTrade` doesn't exist.

- [ ] **Step 3: Add executeTrade to GameController**

In `lib/controllers/game_controller.dart`, add after the `tryUnmortgage` method:

```dart
  // ─── Trading ───

  bool executeTrade({
    required Player partner,
    required List<Property> offeredProperties,
    required List<Property> requestedProperties,
    required int offeredCash,
    required int requestedCash,
  }) {
    final trade = Trade(
      fromPlayer: currentPlayer,
      toPlayer: partner,
      offeredProperties: offeredProperties,
      requestedProperties: requestedProperties,
      offeredCash: offeredCash,
      requestedCash: requestedCash,
    );
    if (!trade.isValid()) return false;
    try {
      engine.processTrade(trade);
    } catch (_) {
      return false;
    }
    _log.add(GameLogEntry(
        '${currentPlayer.name} traded with ${partner.name}'));
    notifyListeners();
    return true;
  }
```

Add import for `Trade` at the top:
```dart
import '../game_logic/models/trade.dart';
```

- [ ] **Step 4: Update trade_panel.dart to use controller.executeTrade**

In `lib/widgets/panels/trade_panel.dart`, replace the `_execute` method:

Old:
```dart
  void _execute() {
    final c = context.read<GameController>();
    final trade = Trade(
      fromPlayer: c.currentPlayer,
      toPlayer: _partner!,
      offeredProperties: _offering.toList(),
      requestedProperties: _requesting.toList(),
      offeredCash: _offerCash,
      requestedCash: _requestCash,
    );
    try {
      c.engine.processTrade(trade);
    } catch (_) {
      // Invalid trade — surface as a quick toast could be added later.
    }
    Navigator.of(context).pop();
  }
```

New:
```dart
  void _execute() {
    final c = context.read<GameController>();
    c.executeTrade(
      partner: _partner!,
      offeredProperties: _offering.toList(),
      requestedProperties: _requesting.toList(),
      offeredCash: _offerCash,
      requestedCash: _requestCash,
    );
    Navigator.of(context).pop();
  }
```

Remove the `Trade` import from `trade_panel.dart` since it's no longer needed there:
```dart
// Remove: import '../../game_logic/models/trade.dart';
```

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze`
Expected: No new errors (the unused `Trade` import removal should reduce warnings).

- [ ] **Step 7: Commit**

```bash
git add lib/controllers/game_controller.dart lib/widgets/panels/trade_panel.dart test/phase3_flow_test.dart
git commit -m "fix: wire trades through controller for UI updates and logging"
```

---

### Task 8: Update controller tax toast to show correct per-tile amount

The controller's `_resolveLanding` hardcodes `config.taxAmount` in the toast message for all tax tiles. Now that tiles can have their own `taxAmount`, the toast must reflect the actual amount charged.

**Files:**
- Modify: `lib/controllers/game_controller.dart:232-239`

- [ ] **Step 1: Update _resolveLanding tax case**

In `lib/controllers/game_controller.dart`, update the `TileType.tax` case in `_resolveLanding`:

Old:
```dart
      case TileType.tax:
        _phase = TurnPhase.taxNotice;
        toastMessage = '${currentPlayer.name} paid ₹${engine.config.taxAmount} tax';
        toastAmount = -engine.config.taxAmount;
        toastPlayer = currentPlayer;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1200));
        _afterLanding(moveResult);
        break;
```

New:
```dart
      case TileType.tax:
        final taxTile = engine.board[currentPlayer.position];
        final taxAmt = taxTile.taxAmount ?? engine.config.taxAmount;
        _phase = TurnPhase.taxNotice;
        toastMessage = '${currentPlayer.name} paid ₹$taxAmt tax';
        toastAmount = -taxAmt;
        toastPlayer = currentPlayer;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1200));
        _afterLanding(moveResult);
        break;
```

- [ ] **Step 2: Run tests and analyze**

Run: `flutter test && flutter analyze`
Expected: All pass, no new errors.

- [ ] **Step 3: Commit**

```bash
git add lib/controllers/game_controller.dart
git commit -m "fix: tax toast shows per-tile amount (Income Tax vs Luxury Tax)"
```

---

### Task 9: Final verification and cleanup

Run the full suite, analyze, and verify build.

- [ ] **Step 1: Run full test suite**

Run: `flutter test -v`
Expected: All tests pass (89 existing + ~15 new).

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 errors (some cosmetic infos OK).

- [ ] **Step 3: Build APK**

Run: `flutter build apk --debug`
Expected: Build succeeds.

- [ ] **Step 4: Final commit with all flow fixes**

```bash
git add -A
git commit -m "Phase 3.5: Game flow bugfixes — 10 critical gameplay issues resolved

- Fix nearest utility/railroad Chance cards (were silently skipped)
- Add per-property rent tables to all 22 India street properties
- Differentiate Income Tax (₹2L) from Luxury Tax (₹1L)
- Route card payments through engine for graceful bankruptcy
- Fix GOOJF card never auto-used (player's choice only)
- Preserve doubles bonus across buy/auction/card interactions
- Wire trades through controller for UI updates
- Fix tax toast to show per-tile amount"
```
