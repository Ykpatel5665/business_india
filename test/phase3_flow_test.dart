import 'package:flutter_test/flutter_test.dart';
import 'package:business_india/game_logic/engine/game_factory.dart';
import 'package:business_india/game_logic/models/player.dart';
import 'package:business_india/game_logic/models/enums.dart';
import 'package:business_india/game_logic/engine/editions/board_india.dart';

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
}
