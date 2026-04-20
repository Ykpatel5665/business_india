// Phase 2 rule fixes — one focused test per fix.
//
// These tests lock in the corrections made to the engine against
// MONOPOLY_RULES_REFERENCE.md. When a fix is touched, the corresponding
// test here must continue to pass.

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:business_india/game_logic/engine/game_engine.dart';
import 'package:business_india/game_logic/models/player.dart';
import 'package:business_india/game_logic/models/property.dart';
import 'package:business_india/game_logic/models/board_tile.dart';
import 'package:business_india/game_logic/models/card.dart';
import 'package:business_india/game_logic/models/enums.dart';
import 'package:business_india/game_logic/models/game_config.dart';
import 'package:business_india/game_logic/models/trade.dart';

/// Minimal 40-tile test board with two brown properties sharing colorGroup 0,
/// one railroad, one utility, plus standard corners. Integer "units" — not
/// tied to rupee scale so tests stay readable.
GameEngine buildTestEngine({
  int balance = 1500,
  int startingBalance = 1500,
  Random? random,
}) {
  final board = <BoardTile>[
    BoardTile(position: 0, type: TileType.go, label: 'Go'),
    BoardTile(
      position: 1,
      type: TileType.property,
      label: 'Brown 1',
      property: Property(
        name: 'Brown 1',
        price: 60,
        baseRent: 2,
        colorGroup: 0,
        houseCost: 50,
        rentTable: [2, 10, 30, 90, 160, 250],
      ),
    ),
    BoardTile(position: 2, type: TileType.communityChest, label: 'CC'),
    BoardTile(
      position: 3,
      type: TileType.property,
      label: 'Brown 2',
      property: Property(
        name: 'Brown 2',
        price: 60,
        baseRent: 4,
        colorGroup: 0,
        houseCost: 50,
        rentTable: [4, 20, 60, 180, 320, 450],
      ),
    ),
    BoardTile(position: 4, type: TileType.tax, label: 'Tax'),
    BoardTile(
      position: 5,
      type: TileType.property,
      label: 'Railroad A',
      property: Property(
        name: 'Railroad A',
        price: 200,
        baseRent: 25,
        colorGroup: 8,
        type: PropertyType.railroad,
      ),
    ),
    for (var i = 6; i <= 9; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 10, type: TileType.jail, label: 'Jail'),
    BoardTile(
      position: 11,
      type: TileType.property,
      label: 'Utility A',
      property: Property(
        name: 'Utility A',
        price: 150,
        baseRent: 4,
        colorGroup: 9,
        type: PropertyType.utility,
      ),
    ),
    for (var i = 12; i <= 29; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Filler'),
    BoardTile(position: 30, type: TileType.goToJail, label: 'GoToJail'),
    for (var i = 31; i <= 35; i++)
      BoardTile(position: i, type: TileType.chance, label: 'Filler'),
    BoardTile(
      position: 36,
      type: TileType.property,
      label: 'Railroad B',
      property: Property(
        name: 'Railroad B',
        price: 200,
        baseRent: 25,
        colorGroup: 8,
        type: PropertyType.railroad,
      ),
    ),
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
    config: GameConfig(startingBalance: startingBalance),
    random: random,
  );
}

void main() {
  group('Phase 2 — Doubles rule', () {
    test('Rolling doubles sets shouldRollAgain', () {
      final e = buildTestEngine();
      final result = e.movePlayer(3, 3);
      expect(result.shouldRollAgain, true);
      expect(e.players[0].consecutiveDoubles, 1);
    });

    test('Non-doubles does not grant another roll', () {
      final e = buildTestEngine();
      final result = e.movePlayer(3, 4);
      expect(result.shouldRollAgain, false);
      expect(e.players[0].consecutiveDoubles, 0);
    });

    test('3rd consecutive doubles sends player to jail without moving', () {
      final e = buildTestEngine();
      e.movePlayer(2, 2);
      e.movePlayer(3, 3);
      final positionBeforeThird = e.players[0].position;
      final result = e.movePlayer(4, 4);
      expect(result.sentToJail, true);
      expect(e.players[0].inJail, true);
      // Player did NOT advance on the 3rd roll.
      expect(e.players[0].position, isNot(positionBeforeThird + 8));
    });

    test('consecutiveDoubles resets on nextTurn', () {
      final e = buildTestEngine();
      e.status = GameStatus.active;
      e.movePlayer(2, 2);
      e.nextTurn();
      expect(e.players[0].consecutiveDoubles, 0);
    });
  });

  group('Phase 2 — Auction on decline', () {
    test('auctionProperty awards to the highest bidder (multi-round terminates)',
        () {
      final e = buildTestEngine();
      final property = e.board[1].property!;
      e.players[0].balance = 500;
      e.players[1].balance = 500;
      // Player 2's bidStrategy would need subclassing; here default decideBid
      // suffices: both players keep bidding until balance headroom exhausts.
      e.auctionProperty(property);
      expect(property.owner, isNotNull);
      expect(property.owner!.balance, lessThan(500));
    });

    test('auctionProperty with no bidders leaves property unowned', () {
      // Default bid heuristic: bid if balance > currentHigh + price/10.
      // Brown 1 price 60 → threshold 6. Balance=5 keeps both players silent.
      final e = buildTestEngine(balance: 5);
      final property = e.board[1].property!;
      e.auctionProperty(property);
      expect(property.owner, isNull);
    });
  });

  group('Phase 2 — Per-property rent table', () {
    test('getHouseRent uses the explicit rentTable', () {
      final prop = Property(
        name: 'Custom',
        price: 200,
        baseRent: 14,
        colorGroup: 3,
        houseCost: 100,
        rentTable: [14, 70, 200, 550, 750, 950],
      );
      expect(prop.getHouseRent(0), 14);
      expect(prop.getHouseRent(3), 550);
      expect(prop.getHouseRent(5), 950); // hotel
    });

    test('Property without rentTable falls back to flat multipliers', () {
      final prop = Property(
        name: 'Legacy',
        price: 60,
        baseRent: 2,
        colorGroup: 0,
        houseCost: 50,
      );
      expect(prop.getHouseRent(1), 2 * 5);
    });
  });

  group('Phase 2 — Full-group ownership + even building', () {
    test('cannot build without owning the full color group', () {
      final e = buildTestEngine();
      final brown1 = e.board[1].property!;
      final p1 = e.players[0];
      brown1.owner = p1;
      p1.ownedProperties.add(brown1);
      // Brown 2 still unowned: cannot build on Brown 1.
      expect(e.canUpgradeProperty(brown1, p1), false);
    });

    test('can build once full group is owned', () {
      final e = buildTestEngine();
      final brown1 = e.board[1].property!;
      final brown2 = e.board[3].property!;
      final p1 = e.players[0];
      brown1.owner = p1;
      brown2.owner = p1;
      p1.ownedProperties.addAll([brown1, brown2]);
      expect(e.canUpgradeProperty(brown1, p1), true);
    });

    test('even-building: cannot build a 2nd house until group has 1 each', () {
      final e = buildTestEngine();
      final brown1 = e.board[1].property!;
      final brown2 = e.board[3].property!;
      final p1 = e.players[0];
      brown1.owner = p1;
      brown2.owner = p1;
      p1.ownedProperties.addAll([brown1, brown2]);
      // Build 1 house on brown1 — now brown1=1, brown2=0.
      e.upgradeProperty(brown1, p1, enforceGroupRules: true);
      // Attempting to build 2nd house on brown1 violates even-building.
      expect(e.canUpgradeProperty(brown1, p1), false);
      // But brown2 can catch up.
      expect(e.canUpgradeProperty(brown2, p1), true);
    });

    test('cannot build if any property in the group is mortgaged', () {
      final e = buildTestEngine();
      final brown1 = e.board[1].property!;
      final brown2 = e.board[3].property!;
      final p1 = e.players[0];
      brown1.owner = p1;
      brown2.owner = p1;
      p1.ownedProperties.addAll([brown1, brown2]);
      brown2.isMortgaged = true;
      expect(e.canUpgradeProperty(brown1, p1), false);
    });
  });

  group('Phase 2 — Bankruptcy to creditor', () {
    test('creditor receives cash + properties + GOOJF cards', () {
      final e = buildTestEngine();
      final debtor = e.players[0];
      final creditor = e.players[1];
      final brown1 = e.board[1].property!;
      final brown2 = e.board[3].property!;
      brown1.owner = debtor;
      brown2.owner = debtor;
      debtor.ownedProperties.addAll([brown1, brown2]);
      debtor.balance = 100;
      debtor.goojfCards.add(DeckOrigin.chance);

      // Rent that debtor cannot afford.
      e.payRent(debtor, creditor, 999);

      expect(debtor.isBankrupt, true);
      expect(debtor.balance, 0);
      expect(debtor.ownedProperties, isEmpty);
      expect(debtor.goojfCards, isEmpty);
      expect(creditor.ownedProperties.contains(brown1), true);
      expect(creditor.ownedProperties.contains(brown2), true);
      expect(brown1.owner, creditor);
      expect(creditor.goojfCards.length, 1);
    });
  });

  group('Phase 2 — Bankruptcy to bank', () {
    test('bank bankruptcy auctions recovered properties', () {
      final e = buildTestEngine();
      final debtor = e.players[0];
      final other = e.players[1];
      other.balance = 500; // Can bid in the auction.
      final brown1 = e.board[1].property!;
      brown1.owner = debtor;
      debtor.ownedProperties.add(brown1);
      debtor.balance = 10;

      e.handleBankruptcy(debtor); // No creditor → to bank.

      expect(debtor.isBankrupt, true);
      expect(debtor.ownedProperties, isEmpty);
      // Property ended up auctioned to the other player.
      expect(brown1.owner, other);
    });
  });

  group('Phase 2 — Downgrade refund', () {
    test('downgradeProperty refunds half houseCost and returns house to bank',
        () {
      final e = buildTestEngine();
      final brown1 = e.board[1].property!;
      final brown2 = e.board[3].property!;
      final p1 = e.players[0];
      brown1.owner = p1;
      brown2.owner = p1;
      p1.ownedProperties.addAll([brown1, brown2]);
      // Build 1 house on each to stay even.
      e.upgradeProperty(brown1, p1, enforceGroupRules: true);
      e.upgradeProperty(brown2, p1, enforceGroupRules: true);
      final bankHousesBefore = e.bank.availableHouses;
      final balanceBefore = p1.balance;

      e.downgradeProperty(brown1, p1);

      expect(brown1.houses, 0);
      expect(e.bank.availableHouses, bankHousesBefore + 1);
      expect(p1.balance, balanceBefore + brown1.houseCost ~/ 2);
    });
  });

  group('Phase 2 — Pass-GO in card movement', () {
    test('moveTo card past GO awards the GO reward', () {
      final e = buildTestEngine();
      final p = e.players[0];
      p.position = 35; // Near end of the board.
      final before = p.balance;
      // Teleport to position 1 (Brown 1). Wraps through GO.
      e.handleDeck(Card(
        description: 'Advance to Brown 1',
        type: CardType.moveTo,
        targetTileIndex: 1,
      ));
      expect(p.position, 1);
      expect(p.balance, before + e.config.goReward);
    });

    test('Go Back N does NOT award the GO reward (no wrapping semantics)', () {
      final e = buildTestEngine();
      final p = e.players[0];
      p.position = 2;
      final before = p.balance;
      e.handleDeck(Card(
        description: 'Go back 3 spaces',
        type: CardType.moveTo,
        steps: -3,
      ));
      expect(p.position, 39); // 2 - 3 = -1 → 39
      expect(p.balance, before); // No GO reward even though index decreased.
    });
  });

  group('Phase 2 — Mortgaged railroad / utility rent', () {
    test('No rent on mortgaged railroad', () {
      final e = buildTestEngine();
      final rr = e.board[5].property!;
      rr.owner = e.players[1];
      e.players[1].ownedProperties.add(rr);
      rr.isMortgaged = true;
      expect(rr.calculateRent(false, 3, 4), 0);
    });

    test('No rent on mortgaged utility', () {
      final e = buildTestEngine();
      final util = e.board[11].property!;
      util.owner = e.players[1];
      e.players[1].ownedProperties.add(util);
      util.isMortgaged = true;
      expect(util.calculateRent(false, 3, 4), 0);
    });
  });

  group('Phase 2 — GOOJF return to deck', () {
    test('Using a GOOJF card returns it to the bottom of its deck', () {
      final e = buildTestEngine();
      final p = e.players[0];
      p.inJail = true;
      p.goojfCards.add(DeckOrigin.chance);
      // Chance deck currently empty; after use, the card should be in it.
      expect(e.chanceDeck, isEmpty);
      e.useGoojfToLeaveJail(p);
      expect(p.inJail, false);
      expect(p.goojfCards, isEmpty);
      expect(e.chanceDeck.length, 1);
      expect(e.chanceDeck.first.type, CardType.getOutOfJail);
      expect(e.chanceDeck.first.origin, DeckOrigin.chance);
    });
  });

  group('Phase 2 — Nearest utility / railway', () {
    test('advanceToNearestUtility moves forward to the next utility', () {
      final e = buildTestEngine();
      final p = e.players[0];
      p.position = 5; // Just past railroad A; next utility is at 11.
      e.handleDeck(Card(
        description: 'Nearest utility',
        type: CardType.advanceToNearestUtility,
      ));
      expect(p.position, 11);
    });

    test('advanceToNearestRailroad wraps and awards GO if passed', () {
      final e = buildTestEngine();
      final p = e.players[0];
      p.position = 37; // Past railroad B (36); must wrap → RR A at 5.
      final before = p.balance;
      e.handleDeck(Card(
        description: 'Nearest railway',
        type: CardType.advanceToNearestRailroad,
      ));
      expect(p.position, 5);
      expect(p.balance, before + e.config.goReward);
    });
  });

  group('Phase 2 — Mortgage transfer fee on trade', () {
    test('Receiving a mortgaged property charges the 10% fee', () {
      final e = buildTestEngine();
      final p1 = e.players[0];
      final p2 = e.players[1];
      final brown1 = e.board[1].property!;
      brown1.owner = p1;
      p1.ownedProperties.add(brown1);
      brown1.isMortgaged = true;
      final fee = brown1.mortgageTransferFee;
      final p2BalanceBefore = p2.balance;

      e.processTrade(Trade(
        fromPlayer: p1,
        toPlayer: p2,
        offeredProperties: [brown1],
      ));

      expect(brown1.owner, p2);
      expect(p2.balance, p2BalanceBefore - fee);
    });
  });
}
