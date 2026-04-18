// Business India — Indian-themed Monopoly board and decks.
//
// All money values are integer rupees (₹). Scaled ×1000 from the classic US
// Monopoly values so prices sit in a recognisably "Indian lakh" range:
//   starting balance ₹15,00,000 (15 lakh) / cheapest ₹60,000 / priciest ₹4,00,000.
//
// Color groups follow the classic 10-group layout:
//   0 brown · 1 light-blue · 2 pink · 3 orange · 4 red · 5 yellow ·
//   6 green · 7 dark-blue · 8 railways · 9 utilities
import '../game_edition.dart';
import '../../models/board_tile.dart';
import '../../models/property.dart';
import '../../models/player.dart';
import '../../models/card.dart';
import '../../models/enums.dart';
import '../../models/game_config.dart';

/// Default config for the India edition. Scales starting balance and GO reward
/// ×1000 to match board pricing.
const GameConfig indiaDefaultConfig = GameConfig(
  startingBalance: 1500000,
  goReward: 200000,
  jailExitCost: 50000,
  taxAmount: 200000,
);

class IndiaMonopolyEdition extends MonopolyGameEdition {
  IndiaMonopolyEdition({
    required super.players,
    required super.config,
  });

  @override
  List<BoardTile> getBoard() => [
    BoardTile(position: 0, type: TileType.go, label: 'GO'),

    // Brown (cg 0)
    BoardTile(position: 1, type: TileType.property, label: 'Nashik',
        property: Property(name: 'Nashik', price: 60000, baseRent: 2000, colorGroup: 0, houseCost: 50000, rentTable: [2000, 10000, 30000, 90000, 160000, 250000])),
    BoardTile(position: 2, type: TileType.communityChest, label: 'Community Chest'),
    BoardTile(position: 3, type: TileType.property, label: 'Ranchi',
        property: Property(name: 'Ranchi', price: 60000, baseRent: 4000, colorGroup: 0, houseCost: 50000, rentTable: [4000, 20000, 60000, 180000, 320000, 450000])),

    BoardTile(position: 4, type: TileType.tax, label: 'Income Tax'),

    BoardTile(position: 5, type: TileType.property, label: 'Mumbai Central',
        property: Property(name: 'Mumbai Central', price: 200000, baseRent: 25000, colorGroup: 8, type: PropertyType.railroad)),

    // Light blue (cg 1)
    BoardTile(position: 6, type: TileType.property, label: 'Jaipur',
        property: Property(name: 'Jaipur', price: 100000, baseRent: 6000, colorGroup: 1, houseCost: 50000, rentTable: [6000, 30000, 90000, 270000, 400000, 550000])),
    BoardTile(position: 7, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 8, type: TileType.property, label: 'Lucknow',
        property: Property(name: 'Lucknow', price: 100000, baseRent: 6000, colorGroup: 1, houseCost: 50000, rentTable: [6000, 30000, 90000, 270000, 400000, 550000])),
    BoardTile(position: 9, type: TileType.property, label: 'Bhopal',
        property: Property(name: 'Bhopal', price: 120000, baseRent: 8000, colorGroup: 1, houseCost: 50000, rentTable: [8000, 40000, 100000, 300000, 450000, 600000])),

    BoardTile(position: 10, type: TileType.jail, label: 'Jail / Just Visiting'),

    // Pink (cg 2)
    BoardTile(position: 11, type: TileType.property, label: 'Chandigarh',
        property: Property(name: 'Chandigarh', price: 140000, baseRent: 10000, colorGroup: 2, houseCost: 100000, rentTable: [10000, 50000, 150000, 450000, 625000, 750000])),
    BoardTile(position: 12, type: TileType.property, label: 'Tata Power',
        property: Property(name: 'Tata Power', price: 150000, baseRent: 4000, colorGroup: 9, type: PropertyType.utility)),
    BoardTile(position: 13, type: TileType.property, label: 'Indore',
        property: Property(name: 'Indore', price: 140000, baseRent: 10000, colorGroup: 2, houseCost: 100000, rentTable: [10000, 50000, 150000, 450000, 625000, 750000])),
    BoardTile(position: 14, type: TileType.property, label: 'Nagpur',
        property: Property(name: 'Nagpur', price: 160000, baseRent: 12000, colorGroup: 2, houseCost: 100000, rentTable: [12000, 60000, 180000, 500000, 700000, 900000])),

    BoardTile(position: 15, type: TileType.property, label: 'Howrah Junction',
        property: Property(name: 'Howrah Junction', price: 200000, baseRent: 25000, colorGroup: 8, type: PropertyType.railroad)),

    // Orange (cg 3)
    BoardTile(position: 16, type: TileType.property, label: 'Kochi',
        property: Property(name: 'Kochi', price: 180000, baseRent: 14000, colorGroup: 3, houseCost: 100000, rentTable: [14000, 70000, 200000, 550000, 750000, 950000])),
    BoardTile(position: 17, type: TileType.communityChest, label: 'Community Chest'),
    BoardTile(position: 18, type: TileType.property, label: 'Coimbatore',
        property: Property(name: 'Coimbatore', price: 180000, baseRent: 14000, colorGroup: 3, houseCost: 100000, rentTable: [14000, 70000, 200000, 550000, 750000, 950000])),
    BoardTile(position: 19, type: TileType.property, label: 'Vishakhapatnam',
        property: Property(name: 'Vishakhapatnam', price: 200000, baseRent: 16000, colorGroup: 3, houseCost: 100000, rentTable: [16000, 80000, 220000, 600000, 800000, 1000000])),

    BoardTile(position: 20, type: TileType.freeParking, label: 'Free Parking'),

    // Red (cg 4)
    BoardTile(position: 21, type: TileType.property, label: 'Ahmedabad',
        property: Property(name: 'Ahmedabad', price: 220000, baseRent: 18000, colorGroup: 4, houseCost: 150000, rentTable: [18000, 90000, 250000, 700000, 875000, 1050000])),
    BoardTile(position: 22, type: TileType.chance, label: 'Chance'),
    BoardTile(position: 23, type: TileType.property, label: 'Pune',
        property: Property(name: 'Pune', price: 220000, baseRent: 18000, colorGroup: 4, houseCost: 150000, rentTable: [18000, 90000, 250000, 700000, 875000, 1050000])),
    BoardTile(position: 24, type: TileType.property, label: 'Surat',
        property: Property(name: 'Surat', price: 240000, baseRent: 20000, colorGroup: 4, houseCost: 150000, rentTable: [20000, 100000, 300000, 750000, 925000, 1100000])),

    BoardTile(position: 25, type: TileType.property, label: 'Chennai Central',
        property: Property(name: 'Chennai Central', price: 200000, baseRent: 25000, colorGroup: 8, type: PropertyType.railroad)),

    // Yellow (cg 5)
    BoardTile(position: 26, type: TileType.property, label: 'Hyderabad',
        property: Property(name: 'Hyderabad', price: 260000, baseRent: 22000, colorGroup: 5, houseCost: 150000, rentTable: [22000, 110000, 330000, 800000, 975000, 1150000])),
    BoardTile(position: 27, type: TileType.property, label: 'Bangalore',
        property: Property(name: 'Bangalore', price: 260000, baseRent: 22000, colorGroup: 5, houseCost: 150000, rentTable: [22000, 110000, 330000, 800000, 975000, 1150000])),
    BoardTile(position: 28, type: TileType.property, label: 'Indian Oil',
        property: Property(name: 'Indian Oil', price: 150000, baseRent: 4000, colorGroup: 9, type: PropertyType.utility)),
    BoardTile(position: 29, type: TileType.property, label: 'Chennai',
        property: Property(name: 'Chennai', price: 280000, baseRent: 24000, colorGroup: 5, houseCost: 150000, rentTable: [24000, 120000, 360000, 850000, 1025000, 1200000])),

    BoardTile(position: 30, type: TileType.goToJail, label: 'Go to Jail'),

    // Green (cg 6)
    BoardTile(position: 31, type: TileType.property, label: 'Kolkata',
        property: Property(name: 'Kolkata', price: 300000, baseRent: 26000, colorGroup: 6, houseCost: 200000, rentTable: [26000, 130000, 390000, 900000, 1100000, 1275000])),
    BoardTile(position: 32, type: TileType.property, label: 'Delhi',
        property: Property(name: 'Delhi', price: 300000, baseRent: 26000, colorGroup: 6, houseCost: 200000, rentTable: [26000, 130000, 390000, 900000, 1100000, 1275000])),
    BoardTile(position: 33, type: TileType.communityChest, label: 'Community Chest'),
    BoardTile(position: 34, type: TileType.property, label: 'Mumbai Suburbs',
        property: Property(name: 'Mumbai Suburbs', price: 320000, baseRent: 28000, colorGroup: 6, houseCost: 200000, rentTable: [28000, 150000, 450000, 1000000, 1200000, 1400000])),

    BoardTile(position: 35, type: TileType.property, label: 'New Delhi',
        property: Property(name: 'New Delhi', price: 200000, baseRent: 25000, colorGroup: 8, type: PropertyType.railroad)),

    BoardTile(position: 36, type: TileType.chance, label: 'Chance'),

    // Dark blue (cg 7)
    BoardTile(position: 37, type: TileType.property, label: 'Mumbai South',
        property: Property(name: 'Mumbai South', price: 350000, baseRent: 35000, colorGroup: 7, houseCost: 200000, rentTable: [35000, 175000, 500000, 1100000, 1300000, 1500000])),
    BoardTile(position: 38, type: TileType.tax, label: 'Luxury Tax', taxAmount: 100000),
    BoardTile(position: 39, type: TileType.property, label: 'Mumbai Bandra',
        property: Property(name: 'Mumbai Bandra', price: 400000, baseRent: 50000, colorGroup: 7, houseCost: 200000, rentTable: [50000, 200000, 600000, 1400000, 1700000, 2000000])),
  ];

  // Rules-correct Chance deck adapted with Indian flavor (₹ and local references).
  @override
  List<Card> getChanceDeck() => [
    Card(description: 'Advance to GO (collect ₹2,00,000).',
        type: CardType.moveTo, targetTileIndex: 0),
    Card(description: 'Go to Jail. Do not pass GO, do not collect ₹2,00,000.',
        type: CardType.goToJail),
    Card(description: 'Advance to Chandigarh. If you pass GO, collect ₹2,00,000.',
        type: CardType.moveTo, targetTileIndex: 11),
    Card(description: 'Take a trip to Howrah Junction. If you pass GO, collect ₹2,00,000.',
        type: CardType.moveTo, targetTileIndex: 15),
    Card(description: 'Advance to Surat. If you pass GO, collect ₹2,00,000.',
        type: CardType.moveTo, targetTileIndex: 24),
    Card(description: 'Advance to Mumbai Bandra.',
        type: CardType.moveTo, targetTileIndex: 39),
    Card(description: 'Advance to nearest Utility. Throw dice and pay owner 10× if owned; else you may buy from bank.',
        type: CardType.advanceToNearestUtility),
    Card(description: 'Advance to nearest Railway. Pay owner double the usual rent; else you may buy from bank.',
        type: CardType.advanceToNearestRailroad),
    Card(description: 'Bank pays you a dividend of ₹50,000.',
        type: CardType.receive, amount: 50000),
    Card(description: 'Get Out of Jail Free. Keep this card until needed or sold.',
        type: CardType.getOutOfJail),
    Card(description: 'Go back 3 spaces.',
        type: CardType.moveTo, steps: -3),
    Card(description: 'General property repairs: ₹25,000 per house, ₹1,00,000 per hotel.',
        type: CardType.propertyRepairs, amount: 25000, amount2: 100000),
    Card(description: 'Pay poor tax of ₹15,000.',
        type: CardType.pay, amount: 15000),
    Card(description: 'You have been elected Chairman of the Board. Pay each player ₹50,000.',
        type: CardType.payOtherPlayers, amount: 50000),
    Card(description: 'Your building loan matures. Collect ₹1,50,000.',
        type: CardType.receive, amount: 150000),
    Card(description: 'You win a crossword competition. Collect ₹1,00,000.',
        type: CardType.receive, amount: 100000),
  ];

  @override
  List<Card> getCommunityChestDeck() => [
    Card(description: 'Advance to GO (collect ₹2,00,000).',
        type: CardType.moveTo, targetTileIndex: 0),
    Card(description: 'Bank error in your favour. Collect ₹2,00,000.',
        type: CardType.receive, amount: 200000),
    Card(description: "Doctor's fees. Pay ₹50,000.",
        type: CardType.pay, amount: 50000),
    Card(description: 'From sale of stock you get ₹50,000.',
        type: CardType.receive, amount: 50000),
    Card(description: 'Get Out of Jail Free. Keep this card until needed or sold.',
        type: CardType.getOutOfJail),
    Card(description: 'Go to Jail. Do not pass GO, do not collect ₹2,00,000.',
        type: CardType.goToJail),
    Card(description: 'Holiday fund matures. Receive ₹1,00,000.',
        type: CardType.receive, amount: 100000),
    Card(description: 'Income tax refund. Collect ₹20,000.',
        type: CardType.receive, amount: 20000),
    Card(description: 'It is your birthday. Collect ₹10,000 from every player.',
        type: CardType.collectFromOtherPlayers, amount: 10000),
    Card(description: 'Life insurance matures. Collect ₹1,00,000.',
        type: CardType.receive, amount: 100000),
    Card(description: 'Pay hospital fees of ₹1,00,000.',
        type: CardType.pay, amount: 100000),
    Card(description: 'Pay school fees of ₹50,000.',
        type: CardType.pay, amount: 50000),
    Card(description: 'Receive ₹25,000 consultancy fee.',
        type: CardType.receive, amount: 25000),
    Card(description: 'Street repairs: ₹40,000 per house, ₹1,15,000 per hotel.',
        type: CardType.propertyRepairs, amount: 40000, amount2: 115000),
    Card(description: 'You win second prize in a beauty contest. Collect ₹10,000.',
        type: CardType.receive, amount: 10000),
    Card(description: 'You inherit ₹1,00,000.',
        type: CardType.receive, amount: 100000),
  ];
}
