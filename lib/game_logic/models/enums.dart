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

/// Represents the types of cards in the Monopoly game.
enum CardType {
  moveTo,
  advanceToNearestUtility,
  advanceToNearestRailroad,
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

/// Which deck a Get-Out-of-Jail-Free card came from, so it can be returned
/// to the correct deck when used.
enum DeckOrigin {
  chance,
  communityChest,
}

/// Outcome of a rent/tax payment attempt.
enum PayOutcome {
  paid,          // player had funds and paid in full
  bankrupted,    // player could not pay; has been declared bankrupt
}
