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
  // int color;

  Player({
    required this.name,
    required this.tokenId,
    // required this.color,
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

  bool ownsProperty(Property property) => ownedProperties.contains(property);

  bool canMortgageProperty(Property property) {
    return ownsProperty(property) && property.canMortgage;
  }

  bool canUnmortgageProperty(Property property) {
    return ownsProperty(property) && property.canUnmortgage && balance >= property.unmortgageValue;
  }

  bool canUpgradeProperty(Property property, [Bank? bank]) {
    if (!ownsProperty(property) || !property.canUpgrade) return false;
    if (bank != null) {
      if (property.houses < 4 && bank.availableHouses <= 0) return false;
      if (property.houses == 4 && bank.availableHotels <= 0) return false;
    }
    return balance >= property.houseCost;
  }

  bool canTrade(Property property, Player toPlayer, double cashAmount) {
    return toPlayer != this && ownsProperty(property) && !toPlayer.isBankrupt && toPlayer.balance >= cashAmount;
  }

  void mortgageProperty(Property property) {
    if (!canMortgageProperty(property)) {
      throw Exception("Cannot mortgage this property");
    }
    property.mortgage();
    receive(property.mortgageValue);
  }

  void unmortgageProperty(Property property) {
    if (!canUnmortgageProperty(property)) {
      throw Exception("Cannot unmortgage this property");
    }
    pay(property.unmortgageValue);
    property.unmortgage();
  }

  void upgradeProperty(Property property, [Bank? bank]) {
    if (!canUpgradeProperty(property, bank)) {
      throw Exception("Cannot upgrade this property");
    }
    property.upgrade(bank);
    pay(property.houseCost.toDouble());
  }

  void declareBankruptcy() {
    isBankrupt = true;
    for (var property in ownedProperties) {
      property.owner = null;
    }
    ownedProperties.clear();
  }

  void trade(Property property, Player toPlayer, double cashAmount) {
    if (!canTrade(property, toPlayer, cashAmount)) {
      throw Exception("Cannot trade this property");
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