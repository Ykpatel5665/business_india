import 'player.dart';
import 'bank.dart';
import 'enums.dart';
import 'dart:math';

List<int> multipliers = [1, 5, 15, 45, 65, 75];

/// Represents a property in the Monopoly game.
class Property {
  final String name;
  final double price;
  final double baseRent;
  final int colorGroup;
  final PropertyType type;
  Player? _owner;
  bool isMortgaged;
  int houses;
  bool hasHotel;
  final int houseCost;

  Property({
    required this.name,
    required this.price,
    required this.baseRent,
    required this.colorGroup,
    this.type = PropertyType.street,
    Player? owner,
    this.isMortgaged = false,
    this.houses = 0,
    this.hasHotel = false,
    this.houseCost = 100, // Default, should be set per property
  }) : _owner = owner;

  double get mortgageValue => price * 0.5;

  double calculateRent(bool isMonopoly, int dice1, int dice2) {
    if (type == PropertyType.utility) {
      // Utility rent is based on dice roll
      return (dice1 + dice2) * (isMonopoly ? 10 : 4);
    }
    if (type == PropertyType.railroad) {
      // Railroad rent is based on the number of railroads owned
      int ownedRailroads = _owner?.ownedProperties.where((p) => p.type == PropertyType.railroad).length ?? 0;
      if (ownedRailroads == 0) return baseRent; // No rent if no railroads owned
      return baseRent * pow(2, ownedRailroads - 1);
    }
    if (isMortgaged) return 0.0;
    if (hasHotel) return baseRent * multipliers[5]; // Rent with hotel
    if (isMonopoly && houses == 0) return baseRent * 2; // Double rent for monopoly

    return (baseRent * multipliers[houses]);
  }

  void mortgage() {
    if (isMortgaged) {
      throw Exception("Property is already mortgaged");
    }
    if (_owner == null) {
      throw Exception("Property must have an owner to mortgage");
    }
    if (houses > 0 || hasHotel) {
      throw Exception("Cannot mortgage a property with houses or a hotel");
    }
    if (_owner!.isBankrupt) {
      throw Exception("Cannot mortgage property owned by a bankrupt player");
    }
    isMortgaged = true;
  }

  void unmortgage() {
    if (!isMortgaged) {
      throw Exception("Property is not mortgaged");
    }
    isMortgaged = false;
  }

  void upgrade(Bank? bank) {
    if (_owner == null) {
      throw Exception("Property must have an owner to upgrade");
    }
    if (isMortgaged) {
      throw Exception("Cannot upgrade a mortgaged property");
    }
    if (hasHotel) {
      throw Exception("Property already has a hotel");
    }
    if (houses < 4) {
      if (bank != null && bank.availableHouses <= 0) {
        throw Exception("No houses available in the bank");
      }
      houses++;
      if (bank != null) bank.giveHouse();
    } else {
      if (bank != null && bank.availableHotels <= 0) {
        throw Exception("No hotels available in the bank");
      }
      houses = 0;
      hasHotel = true;
      if (bank != null) {
        bank.giveHotel();
        for (int i = 0; i < 4; i++) bank.takeHouse();
      }
    }
  }

  void downgrade() {
    if (hasHotel) {
      hasHotel = false;
      houses = 4;
    } else if (houses > 0) {
      houses--;
    } else {
      throw Exception("Property has no houses or hotels to downgrade");
    }
  }

  /// Returns the rent for a property based on the number of houses.
  List<int> get houseRent => [50, 100, 150, 200, 250];

  Player? get owner => _owner;

  set owner(Player? newOwner) {
    _owner = newOwner;
  }
}