// Enums for the Monopoly game logic

/// Represents the current status of the game.
enum GameStatus {
  pending,
  active,
  completed,
}

/// Represents the type of a board tile.
enum TileType {
  property,
  tax,
  jail,
  chance,
  communityChest,
  go,
  freeParking,
  goToJail,
}

/// Represents the type of a property.
enum PropertyType {
  street,
  railroad,
  utility,
}

/// Enum representing the types of cards in the Monopoly game.
enum CardType {
  moveTo,
  pay,
  receive,
  getOutOfJail,
  goToJail,
  propertyRepairs,
  payOtherPlayers,
  collectFromOtherPlayers,
}

/// Represents the status of a trade.
enum TradeStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}