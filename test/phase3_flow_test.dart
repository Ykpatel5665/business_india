import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:business_india/app/controllers/game_controller.dart';
import 'package:business_india/game_logic/engine/game_engine.dart';
import 'package:business_india/game_logic/engine/game_factory.dart';
import 'package:business_india/game_logic/models/player.dart';
import 'package:business_india/game_logic/models/property.dart';
import 'package:business_india/game_logic/models/board_tile.dart';
import 'package:business_india/game_logic/models/card.dart' as game_card;
import 'package:business_india/game_logic/models/game_config.dart';
import 'package:business_india/game_logic/models/enums.dart';
import 'package:business_india/game_logic/engine/editions/board_india.dart';

GameEngine buildTestEngine({int balance = 1500, Random? random}) {
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

void main() {
  group('Task 1 — Nearest Utility/Railroad Chance cards', () {
    test('India Chance deck contains advanceToNearestUtility card type', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final deck = edition.getChanceDeck();
      final utilityCards = deck.where((c) => c.type == CardType.advanceToNearestUtility);
      expect(utilityCards.length, 1);
    });

    test('India Chance deck contains advanceToNearestRailroad card type', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final deck = edition.getChanceDeck();
      final rrCards = deck.where((c) => c.type == CardType.advanceToNearestRailroad);
      expect(rrCards.length, 1);
    });
  });

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
        expect(p.rentTable, isNotNull, reason: '${p.name} must have an explicit rentTable');
        expect(p.rentTable!.length, 6, reason: '${p.name} rentTable must have 6 entries');
        expect(p.rentTable![0], p.baseRent, reason: '${p.name} rentTable[0] must equal baseRent');
      }
    });

    test('Nashik hotel rent is 250000', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final board = edition.getBoard();
      final nashik = board[1].property!;
      expect(nashik.getHouseRent(5), 250000);
    });

    test('Mumbai Bandra hotel rent is 2000000', () {
      final edition = IndiaMonopolyEdition(
        players: [Player(name: 'P1', tokenId: 1, balance: 1500000)],
        config: indiaDefaultConfig,
      );
      final board = edition.getBoard();
      final bandra = board[39].property!;
      expect(bandra.getHouseRent(5), 2000000);
    });
  });

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

      final p1 = engine.players[0];
      final balanceBefore1 = p1.balance;
      p1.position = 4;
      engine.handleLanding(p1);
      expect(p1.balance, balanceBefore1 - 200000, reason: 'Income Tax should charge 200000');

      final balanceBefore2 = p1.balance;
      p1.position = 38;
      engine.handleLanding(p1);
      expect(p1.balance, balanceBefore2 - 100000, reason: 'Luxury Tax should charge 100000');
    });
  });

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
      expect(() => card.applyEffect(p1, engine), returnsNormally);
      expect(p1.isBankrupt, true);
    });

    test('propertyRepairs card with insufficient funds triggers bankruptcy', () {
      final engine = buildTestEngine(balance: 10);
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      final prop = engine.board[1].property!;
      prop.owner = p1;
      p1.ownedProperties.add(prop);
      prop.houses = 3;
      final card = game_card.Card(
        description: 'Repairs',
        type: CardType.propertyRepairs,
        amount: 25,
        amount2: 100,
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
      expect(p2.balance, greaterThanOrEqualTo(0));
      expect(p2.isBankrupt, true);
    });

    test('payOtherPlayers bankrupts payer if they cannot afford', () {
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

  group('Task 5 — GOOJF card is not auto-used', () {
    test('player with GOOJF who fails jail roll on turn 1 keeps the card', () {
      final engine = buildTestEngine();
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      p1.inJail = true;
      p1.jailTurns = 0;
      p1.position = 10;
      p1.goojfCards.add(DeckOrigin.chance);

      engine.movePlayer(3, 4); // non-doubles

      expect(p1.inJail, true, reason: 'Should remain in jail');
      expect(p1.goojfCards.length, 1, reason: 'GOOJF card should NOT be auto-used');
      expect(p1.jailTurns, 1);
    });

    test('player forced to pay on 3rd failed jail roll, keeps GOOJF card', () {
      final engine = buildTestEngine();
      engine.status = GameStatus.active;
      final p1 = engine.players[0];
      p1.inJail = true;
      p1.jailTurns = 2; // 3rd attempt
      p1.position = 10;
      p1.goojfCards.add(DeckOrigin.chance);
      final balanceBefore = p1.balance;

      engine.movePlayer(3, 4); // non-doubles

      expect(p1.inJail, false);
      expect(p1.goojfCards.length, 1, reason: 'GOOJF card preserved');
      expect(p1.balance, balanceBefore - engine.config.jailExitCost);
    });
  });

  group('Task 6 — Doubles preserved across async UI', () {
    test('doubles preserved after buying a property', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

      // Simulate: rolled doubles, landed on unowned property.
      final p1 = controller.currentPlayer;
      p1.position = 1; // Nashik (unowned)
      controller.pendingProperty = controller.engine.board[1].property!;
      controller.storeMoveResult(MoveResult(shouldRollAgain: true, sentToJail: false));

      controller.buyPendingProperty();

      expect(controller.phase, TurnPhase.idle,
          reason: 'After buying with doubles, player should roll again');
    });

    test('doubles preserved after non-moving card', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

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

    test('no doubles after Go To Jail card', () {
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

      expect(controller.phase, isNot(TurnPhase.idle),
          reason: 'Go To Jail card cancels doubles');
    });
  });

  group('Task 7 — Trade wired through controller', () {
    test('executeTrade updates log and notifies', () {
      final controller = GameController();
      controller.startGame([
        PlayerSlot(name: 'P1', colorIndex: 0, avatarIndex: 0),
        PlayerSlot(name: 'P2', colorIndex: 1, avatarIndex: 1),
      ]);

      final prop = controller.engine.board[1].property!;
      final p1 = controller.currentPlayer;
      final p2 = controller.engine.players[1];
      prop.owner = p1;
      p1.ownedProperties.add(prop);

      final logCountBefore = controller.log.length;

      final result = controller.executeTrade(
        partner: p2,
        offeredProperties: [prop],
        requestedProperties: [],
        offeredCash: 0,
        requestedCash: 0,
      );

      expect(result, true);
      expect(prop.owner, p2);
      expect(controller.log.length, greaterThan(logCountBefore));
    });
  });
}
