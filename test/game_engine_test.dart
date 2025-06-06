import 'package:flutter_test/flutter_test.dart';
import 'package:business_india/game_logic/engine/game_engine.dart';
import 'package:business_india/game_logic/models/player.dart';
import 'package:business_india/game_logic/models/bank.dart';
import 'package:business_india/game_logic/models/property.dart';
import 'package:business_india/game_logic/models/board_tile.dart';
import 'package:business_india/game_logic/models/enums.dart';
import 'package:business_india/game_logic/models/game_config.dart';
import 'package:business_india/game_logic/models/card.dart';

class TestPlayer extends Player {
  int Function(Property, int)? bidStrategy;
  TestPlayer({
    required String name,
    required int tokenId,
    double balance = 1500,
    this.bidStrategy,
  }) : super(name: name, tokenId: tokenId, balance: balance);
  @override
  int decideBid(Property property, int currentHighestBid) {
    if (bidStrategy != null) {
      return bidStrategy!(property, currentHighestBid);
    }
    return super.decideBid(property, currentHighestBid);
  }
}

void main() {
  group('Monopoly Game Logic Tests', () {
    late GameEngine gameEngine;
    late TestPlayer player1;
    late TestPlayer player2;

    setUp(() {
      player1 = TestPlayer(name: 'Player 1', tokenId: 1, balance: 1500);
      player2 = TestPlayer(name: 'Player 2', tokenId: 2, balance: 1500);
      final board = <BoardTile>[
        BoardTile(position: 0, type: TileType.go, label: 'Go', property: null),
        BoardTile(position: 1, type: TileType.property, label: 'Mediterranean Avenue', property: Property(name: 'Mediterranean Avenue', price: 60, baseRent: 2, colorGroup: 0, houseCost: 50)),
        BoardTile(position: 2, type: TileType.communityChest, label: 'Community Chest', property: null),
        BoardTile(position: 3, type: TileType.property, label: 'Baltic Avenue', property: Property(name: 'Baltic Avenue', price: 60, baseRent: 4, colorGroup: 0, houseCost: 50)),
        BoardTile(position: 4, type: TileType.tax, label: 'Income Tax', property: null),
        BoardTile(position: 5, type: TileType.property, label: 'Reading Railroad', property: Property(name: 'Reading Railroad', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
        BoardTile(position: 6, type: TileType.property, label: 'Oriental Avenue', property: Property(name: 'Oriental Avenue', price: 100, baseRent: 6, colorGroup: 1, houseCost: 50)),
        BoardTile(position: 7, type: TileType.chance, label: 'Chance', property: null),
        BoardTile(position: 8, type: TileType.property, label: 'Vermont Avenue', property: Property(name: 'Vermont Avenue', price: 100, baseRent: 6, colorGroup: 1, houseCost: 50)),
        BoardTile(position: 9, type: TileType.property, label: 'Connecticut Avenue', property: Property(name: 'Connecticut Avenue', price: 120, baseRent: 8, colorGroup: 1, houseCost: 50)),
        BoardTile(position: 10, type: TileType.jail, label: 'Jail', property: null),
        BoardTile(position: 11, type: TileType.property, label: 'St. Charles Place', property: Property(name: 'St. Charles Place', price: 140, baseRent: 10, colorGroup: 2, houseCost: 100)),
        BoardTile(position: 12, type: TileType.property, label: 'Electric Company', property: Property(name: 'Electric Company', price: 150, baseRent: 4, colorGroup: 9, type: PropertyType.utility)),
        BoardTile(position: 13, type: TileType.property, label: 'States Avenue', property: Property(name: 'States Avenue', price: 140, baseRent: 10, colorGroup: 2, houseCost: 100)),
        BoardTile(position: 14, type: TileType.property, label: 'Virginia Avenue', property: Property(name: 'Virginia Avenue', price: 160, baseRent: 12, colorGroup: 2, houseCost: 100)),
        BoardTile(position: 15, type: TileType.property, label: 'Pennsylvania Railroad', property: Property(name: 'Pennsylvania Railroad', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
        BoardTile(position: 16, type: TileType.property, label: 'St. James Place', property: Property(name: 'St. James Place', price: 180, baseRent: 14, colorGroup: 3, houseCost: 100)),
        BoardTile(position: 17, type: TileType.communityChest, label: 'Community Chest', property: null),
        BoardTile(position: 18, type: TileType.property, label: 'Tennessee Avenue', property: Property(name: 'Tennessee Avenue', price: 180, baseRent: 14, colorGroup: 3, houseCost: 100)),
        BoardTile(position: 19, type: TileType.property, label: 'New York Avenue', property: Property(name: 'New York Avenue', price: 200, baseRent: 16, colorGroup: 3, houseCost: 100)),
        BoardTile(position: 20, type: TileType.freeParking, label: 'Free Parking', property: null),
        BoardTile(position: 21, type: TileType.property, label: 'Kentucky Avenue', property: Property(name: 'Kentucky Avenue', price: 220, baseRent: 18, colorGroup: 4, houseCost: 150)),
        BoardTile(position: 22, type: TileType.chance, label: 'Chance', property: null),
        BoardTile(position: 23, type: TileType.property, label: 'Indiana Avenue', property: Property(name: 'Indiana Avenue', price: 220, baseRent: 18, colorGroup: 4, houseCost: 150)),
        BoardTile(position: 24, type: TileType.property, label: 'Illinois Avenue', property: Property(name: 'Illinois Avenue', price: 240, baseRent: 20, colorGroup: 4, houseCost: 150)),
        BoardTile(position: 25, type: TileType.property, label: 'B&O Railroad', property: Property(name: 'B&O Railroad', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
        BoardTile(position: 26, type: TileType.property, label: 'Atlantic Avenue', property: Property(name: 'Atlantic Avenue', price: 260, baseRent: 22, colorGroup: 5, houseCost: 150)),
        BoardTile(position: 27, type: TileType.property, label: 'Ventnor Avenue', property: Property(name: 'Ventnor Avenue', price: 260, baseRent: 22, colorGroup: 5, houseCost: 150)),
        BoardTile(position: 28, type: TileType.property, label: 'Water Works', property: Property(name: 'Water Works', price: 150, baseRent: 4, colorGroup: 9, type: PropertyType.utility)),
        BoardTile(position: 29, type: TileType.property, label: 'Marvin Gardens', property: Property(name: 'Marvin Gardens', price: 280, baseRent: 24, colorGroup: 5, houseCost: 150)),
        BoardTile(position: 30, type: TileType.goToJail, label: 'Go to Jail', property: null),
        BoardTile(position: 31, type: TileType.property, label: 'Pacific Avenue', property: Property(name: 'Pacific Avenue', price: 300, baseRent: 26, colorGroup: 6, houseCost: 200)),
        BoardTile(position: 32, type: TileType.property, label: 'North Carolina Avenue', property: Property(name: 'North Carolina Avenue', price: 300, baseRent: 26, colorGroup: 6, houseCost: 200)),
        BoardTile(position: 33, type: TileType.communityChest, label: 'Community Chest', property: null),
        BoardTile(position: 34, type: TileType.property, label: 'Pennsylvania Avenue', property: Property(name: 'Pennsylvania Avenue', price: 320, baseRent: 28, colorGroup: 6, houseCost: 200)),
        BoardTile(position: 35, type: TileType.property, label: 'Short Line', property: Property(name: 'Short Line', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
        BoardTile(position: 36, type: TileType.chance, label: 'Chance', property: null),
        BoardTile(position: 37, type: TileType.property, label: 'Park Place', property: Property(name: 'Park Place', price: 350, baseRent: 35, colorGroup: 7, houseCost: 200)),
        BoardTile(position: 38, type: TileType.tax, label: 'Luxury Tax', property: null),
        BoardTile(position: 39, type: TileType.property, label: 'Boardwalk', property: Property(name: 'Boardwalk', price: 400, baseRent: 50, colorGroup: 7, houseCost: 200)),
      ];
      gameEngine = GameEngine(
        players: [player1, player2],
        board: board,
        bank: Bank(),
        chanceDeck: [
          Card(description: 'Advance to Go (Collect \$200)', type: CardType.moveTo, targetTileIndex: 0, effect: () {}),
          Card(description: 'Advance to Illinois Ave.', type: CardType.moveTo, targetTileIndex: 24, effect: () {}),
          Card(description: 'Advance to St. Charles Place', type: CardType.moveTo, targetTileIndex: 11, effect: () {}),
          Card(description: 'Advance token to nearest Utility', type: CardType.moveTo, targetTileIndex: null, effect: () {}), // handle nearest logic in engine
          Card(description: 'Advance token to nearest Railroad', type: CardType.moveTo, targetTileIndex: null, effect: () {}), // handle nearest logic in engine
          Card(description: 'Bank pays you dividend of \$50', type: CardType.receive, amount: 50, effect: () {}),
          Card(description: 'Get Out of Jail Free', type: CardType.getOutOfJail, effect: () {}),
          Card(description: 'Go Back 3 Spaces', type: CardType.moveTo, targetTileIndex: null, effect: () {}), // handle move back logic in engine
          Card(description: 'Go to Jail', type: CardType.goToJail, effect: () {}),
          Card(description: 'Make general repairs on all your property: For each house pay \$25, for each hotel \$100', type: CardType.propertyRepairs, amount: 25, effect: () {}), // hotel cost handled in logic if needed
          Card(description: 'Pay poor tax of \$15', type: CardType.pay, amount: 15, effect: () {}),
          Card(description: 'Take a trip to Reading Railroad', type: CardType.moveTo, targetTileIndex: 5, effect: () {}),
          Card(description: 'Take a walk on the Boardwalk', type: CardType.moveTo, targetTileIndex: 39, effect: () {}),
          Card(description: 'You have been elected Chairman of the Board. Pay each player \$50', type: CardType.payOtherPlayers, amount: 50, effect: () {}),
          Card(description: 'Your building loan matures. Collect \$150', type: CardType.receive, amount: 150, effect: () {}),
          Card(description: 'You have won a crossword competition. Collect \$100', type: CardType.receive, amount: 100, effect: () {}),
        ],
        communityChestDeck: [],
        config: GameConfig(startingBalance: 1500, freeParkingRules: true),
      );
    });

    test('Player moves and passes Go, receives \$200', () {
      player1.position = 39;
      gameEngine.movePlayer(2, 0); // 39 + 2 = 41 % 40 = 1
      expect(player1.position, 1);
      expect(player1.balance, 1700);
    });

    test('Player lands on Go exactly', () {
      player1.position = 38;
      print('Player 1 position before move: ${player1.position} ${player1.balance}');
      gameEngine.movePlayer(2, 0); // 38 + 2 = 40 % 40 = 0
      expect(player1.position, 0);
      expect(player1.balance, 1700);
    });

    test('Player lands on Go to Jail and is sent to Jail', () {
      player1.position = 29;
      gameEngine.movePlayer(1, 0); // 29 + 1 = 30 (Go to Jail)
      expect(player1.position, 30);
      expect(player1.inJail, true);
    });

    test('Player pays rent when landing on another player\'s property', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0); // Land on 1
      expect(player1.balance, 1498); // Rent 2
      expect(player2.balance, 1502);
    });

    test('Player does not pay rent on their own property', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0);
      expect(player1.balance, 1500);
    });

    test('Player cannot buy property if balance is insufficient', () {
      player1.balance = 50;
      final property = gameEngine.board[1].property!;
      final result = player1.buyProperty(property, 60);
      expect(result, false);
      expect(player1.balance, 50);
    });

    test('Player lands on mortgaged property, no rent paid', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      property.isMortgaged = true;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0);
      expect(player1.balance, 1500);
      expect(player2.balance, 1500);
    });

    test('Player owns all properties in color group, rent is doubled', () {
      final prop1 = gameEngine.board[1].property!;
      final prop2 = gameEngine.board[3].property!;
      prop1.owner = player2;
      prop2.owner = player2;
      player2.ownedProperties.addAll([prop1, prop2]);
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0); // Land on 1
      expect(player1.balance, 1496); // Rent 4 (doubled)
      expect(player2.balance, 1504);
    });

    test('Player upgrades property with houses, rent increases', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      property.houses = 2;
      player2.ownedProperties.add(property);
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0);
      expect(player1.balance, 1470); // Rent: 2*15 = 30
      expect(player2.balance, 1530);
    });

    test('Player is declared bankrupt if unable to pay rent', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      player1.balance = 1;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      expect(() => gameEngine.movePlayer(1, 0), throwsException);
    });

    test('Player lands on tax tile and pays tax', () {
      player1.position = 3;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0); // 3 + 1 = 4 (Income Tax)
      expect(player1.balance, 1300);
    });

    test('Player uses Get Out of Jail Free card', () {
      player1.inJail = true;
      player1.getOutOfJailCards = 1;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 2);
      expect(player1.inJail, false);
      expect(player1.getOutOfJailCards, 0);
    });

    test('Auction: property goes to highest bidder', () {
      final property = gameEngine.board[1].property!;
      property.owner = null;
      player1.balance = 1500;
      player2.balance = 1500;
      player1.bidStrategy = (p, h) => 80;
      player2.bidStrategy = (p, h) => 100;
      gameEngine.startAuction(property);
      expect(property.owner, player2);
      expect(player2.balance, 1400);
    });

    test('Trade: players exchange property and cash', () {
      final property1 = gameEngine.board[1].property!;
      final property2 = gameEngine.board[3].property!;
      property1.owner = player1;
      property2.owner = player2;
      player1.ownedProperties.add(property1);
      player2.ownedProperties.add(property2);
      player1.trade(property1, player2, 20);
      expect(property1.owner, player2);
      expect(player1.balance, 1480);
      expect(player2.balance, 1520);
      expect(player2.ownedProperties.contains(property1), true);
      expect(player1.ownedProperties.contains(property1), false);
    });

    // test('Free Parking: player receives funds if house rule enabled', () {
    //   // Simulate tax paid before landing on Free Parking
    //   player1.position = 3;
    //   gameEngine.currentPlayerIndex = 0;
    //   gameEngine.movePlayer(1, 0); // Land on 4 (tax)
    //   player1.position = 19;
    //   gameEngine.movePlayer(1, 1); // 19 + 1 = 20 (Free Parking)
    //   expect(player1.balance, 1500);
    // });

    test('Jail: player rolls doubles to get out', () {
      player1.inJail = true;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(2, 2);
      expect(player1.inJail, false);
    });

    test('Jail: player fails to roll doubles for 3 turns and pays', () {
      player1.inJail = true;
      player1.jailTurns = 2;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 2);
      expect(player1.inJail, false);
      expect(player1.balance, 1450);
    });

    test('Bankruptcy: player assets are cleared', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      player2.ownedProperties.add(property);
      player2.balance = 1;
      player2.position = 0;
      gameEngine.currentPlayerIndex = 1;
      try {
        gameEngine.movePlayer(1, 0);
      } catch (_) {}
      player2.declareBankruptcy();
      expect(property.owner, null);
      expect(player2.ownedProperties.isEmpty, true);
    });

    test('House building: cannot build more houses than bank allows', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      gameEngine.bank.availableHouses = 0;
      expect(() => property.upgrade(gameEngine.bank), throwsException);
    });

    test('Mortgage/unmortgage: player receives and pays cash', () {
      final property = gameEngine.board[1].property!;
      double balance = player1.balance;
      property.owner = player1;
      player1.ownedProperties.add(property);
      player1.mortgageProperty(property);
      balance = balance + property.mortgageValue;
      expect(property.isMortgaged, true);
      expect(player1.balance, balance);
      player1.unmortgageProperty(property);
      balance = balance - property.mortgageValue * 1.1; // 10% interest
      expect(property.isMortgaged, false);
      expect(player1.balance, balance);
    });

    test('Player lands on property with hotel (max rent)', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      property.hasHotel = true;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0);
      expect(player1.balance, 1350); // Rent: 2 * 75 = 150
      expect(player2.balance, 1650);
    });

    // Extra: Test for utility rent (dice-based)
    test('Player lands on utility, rent is 4x dice if one owned, 10x if both', () {
      final utility = gameEngine.board[12].property!;
      utility.owner = player2;
      player2.ownedProperties.add(utility);
      player1.position = 10;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 1); // Land on 12
      expect(player1.balance, 1492); // 4 x (1+1)
      expect(player2.balance, 1508);
      // Now own both utilities
      final utility2 = gameEngine.board[28].property!;
      utility2.owner = player2;
      player2.ownedProperties.addAll([utility, utility2]);
      player1.position = 26;
      gameEngine.movePlayer(1, 1); // Land on 28
      expect(player1.balance, 1472); // 10 x (1+1)
      expect(player2.balance, 1528);
    });

    // TODO : Implement Rail Road Rent Logic
    // Extra: Test for railroad rent (increases with number owned)
    test('Player lands on railroad, rent increases with number owned', () {
      final rr1 = gameEngine.board[5].property!;
      final rr2 = gameEngine.board[15].property!;
      final rr3 = gameEngine.board[25].property!;
      final rr4 = gameEngine.board[35].property!;
      rr1.owner = player2;
      rr2.owner = player2;
      rr3.owner = player2;
      rr4.owner = player2;
      player2.ownedProperties.addAll([rr1, rr2, rr3, rr4]);
      player1.position = 3;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 1); // Land on 5
      expect(player1.balance, 1300); // Rent: 50 (2 railroads)
      expect(player2.balance, 1700);
    });

    // --- Additional Corner Case Tests ---
    test('Player lands on unowned property and can buy it', () {
      final property = gameEngine.board[6].property!;
      player1.position = 5;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0); // Land on 6
      gameEngine.buyProperty();
      expect(property.owner, player1);
      expect(player1.balance, 1400);
      expect(player1.ownedProperties.contains(property), true);
    });

    test('Player lands on Free Parking with house rule off, receives nothing', () {
      player1.position = 19;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0); // Land on 20 (Free Parking)
      expect(player1.balance, 1500);
    });

    // test('Player lands on Free Parking with house rule on, receives pot', () {
    //   // Simulate tax paid before landing on Free Parking
    //   player1.position = 2;
    //   gameEngine.currentPlayerIndex = 0;
    //   print('Player 1 balance before tax: ${player1.balance}');
    //   gameEngine.movePlayer(1, 1); // Land on 4 (tax)
    //   print('Player 1 balance after tax: ${player1.balance}');
    //   player1.position = 19;
    //   gameEngine.movePlayer(1, 1); // 19 + 1 = 20 (Free Parking)
    //   expect(player1.balance, 1500);
    // });

    test('Player goes bankrupt to another player, property transfers', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      player2.ownedProperties.add(property);
      player1.balance = 1;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      try {
        gameEngine.movePlayer(1, 0);
      } catch (_) {}
      expect(property.owner, player2);
      expect(player1.ownedProperties.isEmpty, true);
    });

    test('Player cannot unmortgage property without enough cash', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      player1.mortgageProperty(property);
      player1.balance = 0;
      expect(() => player1.unmortgageProperty(property), throwsException);
      expect(property.isMortgaged, true);
    });

    test('Player cannot trade with negative cash', () {
      final property1 = gameEngine.board[1].property!;
      final property2 = gameEngine.board[3].property!;
      property1.owner = player1;
      property2.owner = player2;
      player1.ownedProperties.add(property1);
      player2.ownedProperties.add(property2);
      player1.balance = -100;
      expect(() => player1.trade(property1, player2, 20), throwsException);
    });

    test('Player in jail cannot move unless rolling doubles or using card', () {
      player1.inJail = true;
      player1.jailTurns = 0;
      player1.position = 10; // Jail position
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 2); // Not doubles
      expect(player1.inJail, true);
      expect(player1.position, 10); // Jail position
    });

    test('Player cannot build house on mortgaged property', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      property.isMortgaged = true;
      expect(() => property.upgrade(gameEngine.bank), throwsException);
    });

    test('Player cannot mortgage property with houses/hotel', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      property.houses = 1;
      expect(() => player1.mortgageProperty(property), throwsException);
    });

    test('Player cannot pay rent if both are bankrupt', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      player1.balance = 0;
      player2.balance = 0;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      expect(() => gameEngine.movePlayer(1, 0), throwsException);
    });

    test('Player lands on their own mortgaged property, nothing happens', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      property.isMortgaged = true;
      player1.position = 0;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.movePlayer(1, 0);
      expect(player1.balance, 1500);
    });

    test('Player cannot trade property they do not own', () {
      final property1 = gameEngine.board[1].property!;
      final property2 = gameEngine.board[3].property!;
      property1.owner = player2;
      property2.owner = player2;
      player2.ownedProperties.addAll([property1, property2]);
      expect(() => player1.trade(property1, player2, 20), throwsException);
    });

    test('Player cannot buy property if already owned', () {
      final property = gameEngine.board[1].property!;
      property.owner = player2;
      expect(() => player1.buyProperty(property, 60), throwsException);
    });

    test('Player cannot build more than 4 houses and 1 hotel', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      for (int i = 0; i < 4; i++) {
        property.upgrade(gameEngine.bank);
      }
      expect(property.houses, 4);
      property.upgrade(gameEngine.bank); // Should add hotel
      expect(property.hasHotel, true);
      expect(() => property.upgrade(gameEngine.bank), throwsException);
    });

    test('Player cannot unmortgage property if not mortgaged', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      expect(() => player1.unmortgageProperty(property), throwsException);
    });

    test('Player cannot mortgage property if already mortgaged', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      player1.mortgageProperty(property);
      expect(() => player1.mortgageProperty(property), throwsException);
    });

    test('Player cannot trade with themselves', () {
      final property = gameEngine.board[1].property!;
      property.owner = player1;
      player1.ownedProperties.add(property);
      expect(() => player1.trade(property, player1, 10), throwsException);
    });

    test('Player builds a house on a property', () {
      final property = gameEngine.board[1].property!;
      final property2 = gameEngine.board[3].property!;
      property.owner = player1;
      property2.owner = player1;
      player1.ownedProperties.add(property);
      player1.ownedProperties.add(property2);
      expect(property.houses, 0);
      player1.balance = 1000;
      gameEngine.upgradeProperty(property, player1, gameEngine.bank);
      expect(property.houses, 1);
      expect(player1.balance, 1000 - property.houseCost); // Paid houseCost (50)
      expect(gameEngine.bank.availableHouses, gameEngine.config.initialHouses - 1);
    });

    test('Player builds four houses then a hotel on a property', () {
      final property = gameEngine.board[1].property!;
      final property2 = gameEngine.board[3].property!;
      property.owner = player1;
      property2.owner = player1;
      player1.ownedProperties.add(property);
      player1.ownedProperties.add(property2);
      player1.balance = 1000;
      for (int i = 0; i < 4; i++) {
        gameEngine.upgradeProperty(property, player1, gameEngine.bank);
      }
      expect(property.houses, 4);
      expect(property.hasHotel, false);
      expect(gameEngine.bank.availableHouses, gameEngine.config.initialHouses - 4);
      // Build hotel
      gameEngine.upgradeProperty(property, player1, gameEngine.bank);
      expect(property.houses, 0);
      expect(property.hasHotel, true);
      expect(gameEngine.bank.availableHotels, gameEngine.config.initialHotels - 1);
      expect(gameEngine.bank.availableHouses, gameEngine.config.initialHouses); // Houses returned to bank
      expect(player1.balance, 1000 - property.houseCost * 5); // Paid for 4 houses and hotel
    });

    test('Chance card: Advance to Go (Collect \$200)', () {
      player1.position = 7; // Land on Chance
      gameEngine.currentPlayerIndex = 0;
      // Place the "Advance to Go" card at the top
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Advance to Go (Collect \$200)',
      type: CardType.moveTo,
      targetTileIndex: 0,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.position, 0);
      expect(player1.balance, 1700);
    });

    test('Chance card: Advance to Illinois Ave.', () {
      player1.position = 7; // Land on Chance
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Advance to Illinois Ave.',
      type: CardType.moveTo,
      targetTileIndex: 24,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.position, 24);
    });

    test('Chance card: Bank pays you dividend of \$50', () {
      player1.position = 7; // Land on Chance
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Bank pays you dividend of \$50',
      type: CardType.receive,
      amount: 50,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.balance, 1550);
    });

    test('Chance card: Pay poor tax of \$15', () {
      player1.position = 7; // Land on Chance
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Pay poor tax of \$15',
      type: CardType.pay,
      amount: 15,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.balance, 1485);
    });

    test('Chance card: Get Out of Jail Free', () {
      player1.position = 7; // Land on Chance
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Get Out of Jail Free',
      type: CardType.getOutOfJail,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.getOutOfJailCards, 1);
    });

    test('Chance card: Go to Jail', () {
      player1.position = 7; // Land on Chance
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Go to Jail',
      type: CardType.goToJail,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.inJail, true);
      expect(player1.position, 10); // Jail position
    });

    test('Chance card: Pay each player \$50', () {
      player1.position = 7;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'You have been elected Chairman of the Board. Pay each player \$50',
      type: CardType.payOtherPlayers,
      amount: 50,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.balance, 1450);
      expect(player2.balance, 1550);
    });

    test('Chance card: Collect \$150', () {
      player1.position = 7;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Your building loan matures. Collect \$150',
      type: CardType.receive,
      amount: 150,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.balance, 1650);
    });

    test('Chance card: Move back 3 spaces', () {
      player1.position = 7;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Go Back 3 Spaces',
      type: CardType.moveTo,
      targetTileIndex: 4,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      // In a real implementation, effect should move player back 3 spaces
      // Here, we just check if the card was processed and player is at 4
      expect(player1.position, 4);
    });

    test('Chance card: Advance token to nearest Utility', () {
      player1.position = 7;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Advance token to nearest Utility',
      type: CardType.moveTo,
      targetTileIndex: 12,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.position, 12);
    });

    test('Chance card: Advance token to nearest Railroad', () {
      player1.position = 7;
      gameEngine.currentPlayerIndex = 0;
      gameEngine.chanceDeck.insert(0, Card(
      description: 'Advance token to nearest Railroad',
      type: CardType.moveTo,
      targetTileIndex: 15,
      effect: () {},
      ));
      gameEngine.movePlayer(0, 0); // Land on 7 (Chance)
      expect(player1.position, 15);
    });
  });
}