import 'dart:math';

/// Rolls two six-sided dice and returns the result as a tuple.
List<int> rollDice() {
  final random = Random();
  final dice1 = random.nextInt(6) + 1;
  final dice2 = random.nextInt(6) + 1;
  return [dice1, dice2];
}

/// Shuffles a list of cards.
List<T> shuffleDeck<T>(List<T> deck) {
  final random = Random();
  deck.shuffle(random);
  return deck;
}

/// Initializes the Monopoly board with tiles and properties, supporting custom layouts.
List<BoardTile> initializeBoard({List<String>? customLayout}) {
  if (customLayout != null && customLayout.isNotEmpty) {
    // Parse custom layout to create board tiles
    return customLayout.map((label) {
      // Example logic: Map labels to tile types and properties
      if (label.startsWith("Property:")) {
        final parts = label.split(":");
        return BoardTile(
          position: customLayout.indexOf(label),
          type: TileType.property,
          label: parts[1],
          property: Property(
            name: parts[1],
            price: 100, // Example price
            baseRent: 10, // Example rent
            colorGroup: 1, // Example color group
          ),
        );
      } else {
        return BoardTile(
          position: customLayout.indexOf(label),
          type: TileType.go, // Default to 'Go' for non-property tiles
          label: label,
        );
      }
    }).toList();
  }

  // Default board layout
  return [
    BoardTile(position: 0, type: TileType.go, label: "Go"),
    BoardTile(position: 1, type: TileType.property, label: "Mediterranean Avenue", property: Property(name: "Mediterranean Avenue", price: 60, baseRent: 2, colorGroup: 1)),
    BoardTile(position: 2, type: TileType.communityChest, label: "Community Chest"),
    BoardTile(position: 3, type: TileType.property, label: "Baltic Avenue", property: Property(name: "Baltic Avenue", price: 60, baseRent: 4, colorGroup: 1)),
    BoardTile(position: 4, type: TileType.tax, label: "Income Tax"),
    BoardTile(position: 5, type: TileType.property, label: "Reading Railroad", property: Property(name: "Reading Railroad", price: 200, baseRent: 25, colorGroup: 2)),
    // Add more tiles as needed...
  ];
}