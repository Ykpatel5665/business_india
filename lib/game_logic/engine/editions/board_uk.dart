// UK Monopoly board and deck definitions for modular import
import '../game_edition.dart';
import '../../models/board_tile.dart';
import '../../models/property.dart';
import '../../models/card.dart';

class UKMonopolyEdition extends MonopolyGameEdition {
  @override
  List<BoardTile> getBoard() => [
    BoardTile(position: 0, type: TileType.go, label: 'Go'),
    BoardTile(position: 1, type: TileType.property, label: 'Old Kent Road', property: Property(name: 'Old Kent Road', price: 60, baseRent: 2, colorGroup: 0, houseCost: 50)),
    BoardTile(position: 2, type: TileType.communityChest, label: 'Community Chest'),
    BoardTile(position: 3, type: TileType.property, label: 'Whitechapel Road', property: Property(name: 'Whitechapel Road', price: 60, baseRent: 4, colorGroup: 0, houseCost: 50)),
    BoardTile(position: 4, type: TileType.tax, label: 'Income Tax'),
    BoardTile(position: 5, type: TileType.property, label: 'King’s Cross Station', property: Property(name: 'King’s Cross Station', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
    BoardTile(position: 6, type: TileType.property, label: 'The Angel Islington', property: Property(name: 'The Angel Islington', price: 100, baseRent: 6, colorGroup: 1, houseCost: 50)),
    BoardTile(position: 7, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 8, type: TileType.property, label: 'Euston Road', property: Property(name: 'Euston Road', price: 100, baseRent: 6, colorGroup: 1, houseCost: 50)),
    BoardTile(position: 9, type: TileType.property, label: 'Pentonville Road', property: Property(name: 'Pentonville Road', price: 120, baseRent: 8, colorGroup: 1, houseCost: 50)),
    BoardTile(position: 10, type: TileType.jail, label: 'Jail'),
    BoardTile(position: 11, type: TileType.property, label: 'Pall Mall', property: Property(name: 'Pall Mall', price: 140, baseRent: 10, colorGroup: 2, houseCost: 100)),
    BoardTile(position: 12, type: TileType.property, label: 'Electric Company', property: Property(name: 'Electric Company', price: 150, baseRent: 4, colorGroup: 9, type: PropertyType.utility)),
    BoardTile(position: 13, type: TileType.property, label: 'Whitehall', property: Property(name: 'Whitehall', price: 140, baseRent: 10, colorGroup: 2, houseCost: 100)),
    BoardTile(position: 14, type: TileType.property, label: 'Northumberland Avenue', property: Property(name: 'Northumberland Avenue', price: 160, baseRent: 12, colorGroup: 2, houseCost: 100)),
    BoardTile(position: 15, type: TileType.property, label: 'Marylebone Station', property: Property(name: 'Marylebone Station', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
    BoardTile(position: 16, type: TileType.property, label: 'Bow Street', property: Property(name: 'Bow Street', price: 180, baseRent: 14, colorGroup: 3, houseCost: 100)),
    BoardTile(position: 17, type: TileType.communityChest, label: 'Community Chest'),
    BoardTile(position: 18, type: TileType.property, label: 'Marlborough Street', property: Property(name: 'Marlborough Street', price: 180, baseRent: 14, colorGroup: 3, houseCost: 100)),
    BoardTile(position: 19, type: TileType.property, label: 'Vine Street', property: Property(name: 'Vine Street', price: 200, baseRent: 16, colorGroup: 3, houseCost: 100)),
    BoardTile(position: 20, type: TileType.freeParking, label: 'Free Parking'),
    BoardTile(position: 21, type: TileType.property, label: 'Strand', property: Property(name: 'Strand', price: 220, baseRent: 18, colorGroup: 4, houseCost: 150)),
    BoardTile(position: 22, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 23, type: TileType.property, label: 'Fleet Street', property: Property(name: 'Fleet Street', price: 220, baseRent: 18, colorGroup: 4, houseCost: 150)),
    BoardTile(position: 24, type: TileType.property, label: 'Trafalgar Square', property: Property(name: 'Trafalgar Square', price: 240, baseRent: 20, colorGroup: 4, houseCost: 150)),
    BoardTile(position: 25, type: TileType.property, label: 'Fenchurch St Station', property: Property(name: 'Fenchurch St Station', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
    BoardTile(position: 26, type: TileType.property, label: 'Leicester Square', property: Property(name: 'Leicester Square', price: 260, baseRent: 22, colorGroup: 5, houseCost: 150)),
    BoardTile(position: 27, type: TileType.property, label: 'Coventry Street', property: Property(name: 'Coventry Street', price: 260, baseRent: 22, colorGroup: 5, houseCost: 150)),
    BoardTile(position: 28, type: TileType.property, label: 'Water Works', property: Property(name: 'Water Works', price: 150, baseRent: 4, colorGroup: 9, type: PropertyType.utility)),
    BoardTile(position: 29, type: TileType.property, label: 'Piccadilly', property: Property(name: 'Piccadilly', price: 280, baseRent: 24, colorGroup: 5, houseCost: 150)),
    BoardTile(position: 30, type: TileType.goToJail, label: 'Go to Jail'),
    BoardTile(position: 31, type: TileType.property, label: 'Regent Street', property: Property(name: 'Regent Street', price: 300, baseRent: 26, colorGroup: 6, houseCost: 200)),
    BoardTile(position: 32, type: TileType.property, label: 'Oxford Street', property: Property(name: 'Oxford Street', price: 300, baseRent: 26, colorGroup: 6, houseCost: 200)),
    BoardTile(position: 33, type: TileType.communityChest, label: 'Community Chest'),
    BoardTile(position: 34, type: TileType.property, label: 'Bond Street', property: Property(name: 'Bond Street', price: 320, baseRent: 28, colorGroup: 6, houseCost: 200)),
    BoardTile(position: 35, type: TileType.property, label: 'Liverpool St Station', property: Property(name: 'Liverpool St Station', price: 200, baseRent: 25, colorGroup: 8, type: PropertyType.railroad)),
    BoardTile(position: 36, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 37, type: TileType.property, label: 'Park Lane', property: Property(name: 'Park Lane', price: 350, baseRent: 35, colorGroup: 7, houseCost: 200)),
    BoardTile(position: 38, type: TileType.tax, label: 'Super Tax'),
    BoardTile(position: 39, type: TileType.property, label: 'Mayfair', property: Property(name: 'Mayfair', price: 400, baseRent: 50, colorGroup: 7, houseCost: 200)),
  ];

  @override
  List<Card> getChanceDeck() => [
    Card(description: 'Advance to Go (Collect £200)', type: CardType.moveTo, targetTileIndex: 0),
    Card(description: 'Go to Jail. Go directly to Jail, do not pass Go, do not collect £200', type: CardType.goToJail),
    Card(description: 'Advance to Pall Mall. If you pass Go, collect £200', type: CardType.moveTo, targetTileIndex: 11),
    Card(description: 'Take a trip to Marylebone Station. If you pass Go, collect £200', type: CardType.moveTo, targetTileIndex: 15),
    Card(description: 'Advance to Trafalgar Square. If you pass Go, collect £200', type: CardType.moveTo, targetTileIndex: 24),
    Card(description: 'Advance to Mayfair', type: CardType.moveTo, targetTileIndex: 39),
    Card(description: 'Advance to nearest Utility. If unowned, you may buy it. If owned, throw dice and pay owner ten times the amount thrown.', type: CardType.moveTo, targetTileIndex: null),
    Card(description: 'Advance to nearest Station. Pay owner twice the rental to which they are otherwise entitled. If unowned, you may buy it.', type: CardType.moveTo, targetTileIndex: null),
    Card(description: 'Bank pays you dividend of £50', type: CardType.receive, amount: 50),
    Card(description: 'Get Out of Jail Free. This card may be kept until needed or sold.', type: CardType.getOutOfJail),
    Card(description: 'Go Back 3 Spaces', type: CardType.moveTo, targetTileIndex: null),
    Card(description: 'Make general repairs on all your property: For each house pay £25, for each hotel £100', type: CardType.propertyRepairs, amount: 25),
    Card(description: 'Pay poor tax of £15', type: CardType.pay, amount: 15),
    Card(description: 'You have been elected Chairman of the Board. Pay each player £50', type: CardType.payOtherPlayers, amount: 50),
    Card(description: 'Your building loan matures. Collect £150', type: CardType.receive, amount: 150),
    Card(description: 'You have won a crossword competition. Collect £100', type: CardType.receive, amount: 100),
  ];

  @override
  List<Card> getCommunityChestDeck() => [
    Card(description: 'Advance to Go (Collect £200)', type: CardType.moveTo, targetTileIndex: 0),
    Card(description: 'Bank error in your favour. Collect £200', type: CardType.receive, amount: 200),
    Card(description: 'Doctor’s fees. Pay £50', type: CardType.pay, amount: 50),
    Card(description: 'From sale of stock you get £50', type: CardType.receive, amount: 50),
    Card(description: 'Get Out of Jail Free. This card may be kept until needed or sold.', type: CardType.getOutOfJail),
    Card(description: 'Go to Jail. Go directly to jail, do not pass Go, do not collect £200', type: CardType.goToJail),
    Card(description: 'Holiday fund matures. Receive £100', type: CardType.receive, amount: 100),
    Card(description: 'Income tax refund. Collect £20', type: CardType.receive, amount: 20),
    Card(description: 'It is your birthday. Collect £10 from every player', type: CardType.collectFromOtherPlayers, amount: 10),
    Card(description: 'Life insurance matures. Collect £100', type: CardType.receive, amount: 100),
    Card(description: 'Pay hospital fees of £100', type: CardType.pay, amount: 100),
    Card(description: 'Pay school fees of £50', type: CardType.pay, amount: 50),
    Card(description: 'Receive £25 consultancy fee', type: CardType.receive, amount: 25),
    Card(description: 'You are assessed for street repairs: £40 per house, £115 per hotel', type: CardType.propertyRepairs, amount: 40),
    Card(description: 'You have won second prize in a beauty contest. Collect £10', type: CardType.receive, amount: 10),
    Card(description: 'You inherit £100', type: CardType.receive, amount: 100),
  ];
}
