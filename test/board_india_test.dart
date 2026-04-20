import 'package:flutter_test/flutter_test.dart';
import 'package:business_india/game_logic/engine/game_factory.dart';
import 'package:business_india/game_logic/engine/editions/board_india.dart';
import 'package:business_india/game_logic/models/player.dart';
import 'package:business_india/game_logic/models/enums.dart';
import 'package:business_india/utils/rupee_formatter.dart';

void main() {
  group('India Edition — board, factory, formatting', () {
    test('Factory builds a valid India engine', () {
      final engine = MonopolyGameEngineBuilder(
        players: [
          Player(name: 'Aarav', tokenId: 1, balance: indiaDefaultConfig.startingBalance),
          Player(name: 'Priya', tokenId: 2, balance: indiaDefaultConfig.startingBalance),
        ],
        config: indiaDefaultConfig,
      ).create('india');

      expect(engine.board, hasLength(40));
      expect(engine.chanceDeck, hasLength(16));
      expect(engine.communityChestDeck, hasLength(16));
      expect(engine.players, hasLength(2));
      expect(engine.players.first.balance, 1500000);
    });

    test('Board has correct tile types at fixed positions', () {
      final engine = MonopolyGameEngineBuilder(
        players: [Player(name: 'P1', tokenId: 1), Player(name: 'P2', tokenId: 2)],
        config: indiaDefaultConfig,
      ).create('india');

      expect(engine.board[0].type, TileType.go);
      expect(engine.board[10].type, TileType.jail);
      expect(engine.board[20].type, TileType.freeParking);
      expect(engine.board[30].type, TileType.goToJail);

      // Railways at 5, 15, 25, 35
      for (final i in [5, 15, 25, 35]) {
        expect(engine.board[i].property?.type, PropertyType.railroad,
            reason: 'expected railroad at position $i');
      }
      // Utilities at 12 and 28
      for (final i in [12, 28]) {
        expect(engine.board[i].property?.type, PropertyType.utility,
            reason: 'expected utility at position $i');
      }
    });

    test('Most-expensive property is Mumbai Bandra at ₹4,00,000', () {
      final engine = MonopolyGameEngineBuilder(
        players: [Player(name: 'P1', tokenId: 1), Player(name: 'P2', tokenId: 2)],
        config: indiaDefaultConfig,
      ).create('india');

      final bandra = engine.board[39].property!;
      expect(bandra.name, 'Mumbai Bandra');
      expect(bandra.price, 400000);
      expect(bandra.baseRent, 50000);
    });

    test('Cheapest property is Nashik at ₹60,000', () {
      final engine = MonopolyGameEngineBuilder(
        players: [Player(name: 'P1', tokenId: 1), Player(name: 'P2', tokenId: 2)],
        config: indiaDefaultConfig,
      ).create('india');

      final nashik = engine.board[1].property!;
      expect(nashik.name, 'Nashik');
      expect(nashik.price, 60000);
    });

    test('Unknown edition throws ArgumentError', () {
      expect(
        () => MonopolyGameEngineBuilder(
          players: [Player(name: 'P1', tokenId: 1)],
          config: indiaDefaultConfig,
        ).create('martian'),
        throwsArgumentError,
      );
    });
  });

  group('RupeeFormatter', () {
    test('format uses Indian grouping', () {
      expect(RupeeFormatter.format(1500), '₹1,500');
      expect(RupeeFormatter.format(1500000), '₹15,00,000');
      expect(RupeeFormatter.format(12345678), '₹1,23,45,678');
    });

    test('format without symbol', () {
      expect(RupeeFormatter.format(1500000, symbol: ''), '15,00,000');
    });

    test('compact form for tight UI', () {
      expect(RupeeFormatter.compact(500), '₹500');
      expect(RupeeFormatter.compact(2000), '₹2K');
      expect(RupeeFormatter.compact(150000), '₹1.5L');
      expect(RupeeFormatter.compact(12500000), '₹1.25Cr');
    });
  });
}
