import 'property.dart';
import 'bank.dart';

/// Represents a player in the Monopoly game.
class Player {
  final String name;
  final int tokenId;
  int position;
  double balance;
  bool inJail;
  int jailTurns;
  int getOutOfJailCards;
  List<Property> ownedProperties;
  bool isBankrupt;

  Player({
    required this.name,
    required this.tokenId,
    this.position = 0,
    this.balance = 1500.0,
    this.inJail = false,
    this.jailTurns = 0,
    this.getOutOfJailCards = 0,
    List<Property>? ownedProperties,
    this.isBankrupt = false,
  }) : ownedProperties = ownedProperties ?? [];

  void move(int steps, int boardSize) {
    position = (position + steps) % boardSize;
  }

  /// Moves the player to a specific tile index.
  void moveTo(int targetTileIndex, int boardSize) {
    position = targetTileIndex % boardSize;
  }

  void pay(double amount, [bool bypassFundCheck = false]) {
    if (!bypassFundCheck && balance < amount) {
      throw Exception("Insufficient balance to pay");
    }
    balance -= amount;
  }

  void receive(double amount) {
    balance += amount;
  }

  /// Updates the `buyProperty` method to return a boolean.
  bool buyProperty(Property property, num? highestBid) {
    if (ownedProperties.contains(property)) {
      throw Exception("Property already owned by player");
    }
    if (property.isMortgaged) {
      throw Exception("Cannot buy a mortgaged property");
    }
    if (property.owner != null) {
      throw Exception("Property already has an owner");
    }
    if (isBankrupt) {
      return false; // Player is bankrupt and cannot buy properties
    }
    double priceToPay = (highestBid ?? property.price).toDouble();
    if (balance < priceToPay) {
      return false; // Purchase failed due to insufficient balance
    }
    pay(priceToPay);
    ownedProperties.add(property);
    property.owner = this;
    return true; // Purchase successful
  }

  void mortgageProperty(Property property) {
    if (!ownedProperties.contains(property)) {
      throw Exception("Property not owned by player");
    }
    property.mortgage();
    receive(property.mortgageValue);
  }

  void unmortgageProperty(Property property) {
    if (!ownedProperties.contains(property)) {
      throw Exception("Property not owned by player");
    }
    pay(property.mortgageValue * 1.1); // 10% interest
    property.unmortgage();
  }

  void upgradeProperty(Property property, [Bank? bank]) {
    if (!ownedProperties.contains(property)) {
      throw Exception("Property not owned by player");
    }
    property.upgrade(bank);
  }

  void declareBankruptcy() {
    isBankrupt = true;
    for (var property in ownedProperties) {
      property.owner = null;
    }
    ownedProperties.clear();
  }

  void trade(Property property, Player toPlayer, double cashAmount) {
    if (toPlayer == this) {
      throw Exception("Cannot trade with yourself");
    }
    if (!ownedProperties.contains(property)) {
      throw Exception("Property not owned by player");
    }
    if (toPlayer.isBankrupt) {
      throw Exception("Cannot trade with a bankrupt player");
    }
    if (toPlayer.balance < cashAmount) {
      throw Exception("Trading player does not have enough cash");
    }
    pay(cashAmount);
    toPlayer.receive(cashAmount);
    ownedProperties.remove(property);
    toPlayer.ownedProperties.add(property);
    property.owner = toPlayer;
  }

  /// Decides a bid for a property during an auction.
  int decideBid(Property property, int currentHighestBid) {
    if (balance > currentHighestBid + property.price * 0.1) {
      return currentHighestBid + 10; // Example bid increment
    }
    return 0; // Pass if unable to bid
  }
}