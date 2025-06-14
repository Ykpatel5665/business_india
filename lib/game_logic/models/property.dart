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

  double get unmortgageValue => mortgageValue * 1.1; // 10% interest on unmortgage

  double calculateRent(bool isMonopoly, int dice1, int dice2) {
    if (type == PropertyType.utility) {
      return _calculateUtilityRent(isMonopoly, dice1, dice2);
    }
    if (type == PropertyType.railroad) {
      return _calculateRailroadRent();
    }
    if (isMortgaged) return 0.0;
    if (hasHotel) return getHouseRent(5); // Rent with hotel
    if (isMonopoly && houses == 0) return baseRent * 2; // Double rent for monopoly
    return getHouseRent(houses);
  }

  double _calculateUtilityRent(bool isMonopoly, int dice1, int dice2) {
    return (dice1 + dice2) * (isMonopoly ? 10 : 4);
  }

  double _calculateRailroadRent() {
    int ownedRailroads = _owner?.ownedProperties.where((p) => p.type == PropertyType.railroad).length ?? 0;
    return getRailRoadRent(ownedRailroads);
  }

  double getRailRoadRent(int houseCount) {
    if (houseCount == 0) return baseRent;
    return baseRent * pow(2, houseCount - 1);
  }

  double getHouseRent(int houseCount) {
    return baseRent * multipliers[houseCount];
  }

  void mortgage() {
    if (!canMortgage) {
      throw Exception(_mortgageErrorMessage());
    }
    isMortgaged = true;
  }

  String _mortgageErrorMessage() {
    if (isMortgaged) return "Property is already mortgaged";
    if (_owner == null) return "Property must have an owner to mortgage";
    if (houses > 0 || hasHotel) return "Cannot mortgage a property with houses or a hotel";
    if (_owner!.isBankrupt) return "Cannot mortgage property owned by a bankrupt player";
    return "Cannot mortgage property";
  }

  void unmortgage() {
    if (!canUnmortgage) {
      throw Exception("Property is not mortgaged");
    }
    isMortgaged = false;
  }

  void upgrade(Bank? bank, {bool buildHotel = false}) {
    if (!canUpgrade) {
      throw Exception(_upgradeErrorMessage(bank));
    }
    // TODO : Add even building rules for houses
    if (buildHotel) {
      if (houses == 4 && bank != null && bank.canGiveHotel) {
        bank.giveHotel();
        houses = 5;
      } else {
        throw Exception("Cannot build hotel: must have 4 houses and hotel available in bank");
      }
    } else if (houses < 4) {
      if (bank != null) bank.giveHouse();
      houses++;
    } else {
      throw Exception("Cannot build more than 4 houses unless building hotel");
    }
  }

  String _upgradeErrorMessage(Bank? bank) {
    if (_owner == null) return "Property must have an owner to upgrade";
    if (isMortgaged) return "Cannot upgrade a mortgaged property";
    if (hasHotel) return "Property already has a hotel";
    if (houses < 4 && bank != null && bank.availableHouses <= 0) return "No houses available in the bank";
    if (houses == 4 && bank != null && bank.availableHotels <= 0) return "No hotels available in the bank";
    return "Cannot upgrade property";
  }

  void downgrade() {
    if (!canDowngrade) {
      throw Exception("Property has no houses or hotels to downgrade");
    }
    if (hasHotel) {
      hasHotel = false;
      houses = 4;
    } else {
      houses--;
    }
  }

  Player? get owner => _owner;

  set owner(Player? newOwner) {
    _owner = newOwner;
  }

  bool get canMortgage {
    return !isMortgaged && _owner != null && houses == 0 && !hasHotel && !(_owner?.isBankrupt ?? false);
  }

  bool get canUnmortgage {
    return isMortgaged;
  }

  bool get canUpgrade {
    if (_owner == null || isMortgaged || hasHotel) return false;
    return true;
  }

  bool get canDowngrade {
    return hasHotel || houses > 0;
  }

  bool get canConstruct {
    return type == PropertyType.street;
  }

  bool isOwned() {
    return _owner != null;
  }

  bool canBuildHouse(dynamic bank) {
    // TODO: Implement actual logic
    return true;
  }

  bool canBuildHotel(dynamic bank) {
    // TODO: Implement actual logic
    return true;
  }
}