import 'property.dart';
import 'bank.dart';
import 'enums.dart';

/// Represents a player in the Monopoly game.
///
/// Money is integer currency (rupees for the India board; dimensionless
/// units for test boards).
class Player {
  final String name;
  final int tokenId;
  int position;
  int balance;
  bool inJail;
  int jailTurns;

  /// Get-Out-of-Jail-Free cards the player is holding, tagged by which deck
  /// each came from so it can be returned to the correct deck when used.
  final List<DeckOrigin> goojfCards;

  /// Count of consecutive doubles rolled this turn (reset when turn ends).
  int consecutiveDoubles;

  List<Property> ownedProperties;
  bool isBankrupt;

  Player({
    required this.name,
    required this.tokenId,
    this.position = 0,
    this.balance = 1500,
    this.inJail = false,
    this.jailTurns = 0,
    this.consecutiveDoubles = 0,
    List<DeckOrigin>? goojfCards,
    List<Property>? ownedProperties,
    this.isBankrupt = false,
  })  : goojfCards = goojfCards ?? [],
        ownedProperties = ownedProperties ?? [];

  /// Legacy compatibility: number of Get-Out-of-Jail-Free cards held.
  /// Setting it adds/removes cards of `DeckOrigin.chance` to match the count.
  int get getOutOfJailCards => goojfCards.length;
  set getOutOfJailCards(int count) {
    if (count < goojfCards.length) {
      goojfCards.removeRange(count, goojfCards.length);
    } else {
      while (goojfCards.length < count) {
        goojfCards.add(DeckOrigin.chance);
      }
    }
  }

  void move(int steps, int boardSize) {
    position = (position + steps) % boardSize;
    if (position < 0) position += boardSize;
  }

  void moveTo(int targetTileIndex, int boardSize) {
    position = targetTileIndex % boardSize;
  }

  void pay(int amount, [bool bypassFundCheck = false]) {
    if (!bypassFundCheck && balance < amount) {
      throw Exception("Insufficient balance to pay");
    }
    balance -= amount;
  }

  void receive(int amount) {
    balance += amount;
  }

  bool canAfford(int amount) => balance >= amount;

  /// Buys a property; returns true on success, false on failure (e.g. funds).
  bool buyProperty(Property property, int? highestBid) {
    if (ownedProperties.contains(property)) {
      throw Exception("Property already owned by player");
    }
    if (property.isMortgaged) {
      throw Exception("Cannot buy a mortgaged property");
    }
    if (property.owner != null) {
      throw Exception("Property already has an owner");
    }
    if (isBankrupt) return false;
    final priceToPay = highestBid ?? property.price;
    if (balance < priceToPay) return false;
    pay(priceToPay);
    ownedProperties.add(property);
    property.owner = this;
    return true;
  }

  bool ownsProperty(Property property) => ownedProperties.contains(property);

  bool canMortgageProperty(Property property) =>
      ownsProperty(property) && property.canMortgage;

  bool canUnmortgageProperty(Property property) =>
      ownsProperty(property) &&
      property.canUnmortgage &&
      balance >= property.unmortgageValue;

  /// Per-property upgrade check (ownership, mortgage, supply, funds).
  /// Full color-group and even-building rules live in the engine.
  bool canUpgradeProperty(Property property, [Bank? bank]) {
    if (!ownsProperty(property) || !property.canUpgrade) return false;
    if (bank != null) {
      if (property.houses < 4 && bank.availableHouses <= 0) return false;
      if (property.houses == 4 && bank.availableHotels <= 0) return false;
    }
    return balance >= property.houseCost;
  }

  bool canTrade(Property property, Player toPlayer, int cashAmount) =>
      toPlayer != this &&
      ownsProperty(property) &&
      !toPlayer.isBankrupt &&
      toPlayer.balance >= cashAmount;

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
    pay(property.houseCost);
  }

  /// Declare bankruptcy. By default, properties return to the bank (legacy
  /// behaviour used by pre-Phase-2 tests). The engine calls the parameterised
  /// `transferAssetsTo` form when a creditor is involved.
  void declareBankruptcy() {
    isBankrupt = true;
    for (final property in ownedProperties) {
      property.owner = null;
      property.houses = 0;
      property.hasHotel = false;
      property.isMortgaged = false;
    }
    ownedProperties.clear();
    goojfCards.clear();
  }

  void trade(Property property, Player toPlayer, int cashAmount) {
    if (!canTrade(property, toPlayer, cashAmount)) {
      throw Exception("Cannot trade this property");
    }
    pay(cashAmount);
    toPlayer.receive(cashAmount);
    ownedProperties.remove(property);
    toPlayer.ownedProperties.add(property);
    property.owner = toPlayer;
  }

  /// Simple default bid strategy, used in AI simulations and as a test default.
  int decideBid(Property property, int currentHighestBid) {
    if (balance > currentHighestBid + property.price ~/ 10) {
      return currentHighestBid + 10;
    }
    return 0;
  }
}
