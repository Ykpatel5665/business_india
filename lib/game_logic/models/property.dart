import 'player.dart';
import 'bank.dart';
import 'enums.dart';

/// Legacy fallback rent multipliers used when a property has no explicit
/// `rentTable`: [unimproved, 1h, 2h, 3h, 4h, hotel].
///
/// Real Monopoly uses per-property rent schedules (see board_india.dart).
/// This fallback exists to keep legacy tests running.
const List<int> _legacyRentMultipliers = [1, 5, 15, 45, 65, 75];

/// Represents a property in the Monopoly game.
///
/// All money values are integer currency units.
class Property {
  final String name;
  final int price;
  final int baseRent;
  final int colorGroup;
  final PropertyType type;
  Player? owner;
  bool isMortgaged;
  int houses;
  bool hasHotel;
  final int houseCost;

  /// Rent schedule for streets: `[base, 1h, 2h, 3h, 4h, hotel]`.
  /// When null, falls back to `baseRent * _legacyRentMultipliers[level]`.
  final List<int>? rentTable;

  Property({
    required this.name,
    required this.price,
    required this.baseRent,
    required this.colorGroup,
    this.type = PropertyType.street,
    this.owner,
    this.isMortgaged = false,
    this.houses = 0,
    this.hasHotel = false,
    this.houseCost = 100,
    this.rentTable,
  });

  int get mortgageValue => price ~/ 2;

  /// Unmortgage cost = mortgage value + 10% interest (rounded up).
  int get unmortgageValue => (mortgageValue * 11 + 9) ~/ 10;

  /// 10% fee applied when a mortgaged property is transferred in a trade.
  int get mortgageTransferFee => (mortgageValue + 9) ~/ 10;

  int calculateRent(bool isMonopoly, int dice1, int dice2) {
    if (isMortgaged) return 0;
    if (type == PropertyType.utility) {
      return _calculateUtilityRent(isMonopoly, dice1, dice2);
    }
    if (type == PropertyType.railroad) {
      return _calculateRailroadRent();
    }
    if (hasHotel) return getHouseRent(5);
    if (isMonopoly && houses == 0) return baseRent * 2;
    return getHouseRent(houses);
  }

  int _calculateUtilityRent(bool isMonopoly, int dice1, int dice2) {
    return (dice1 + dice2) * (isMonopoly ? 10 : 4);
  }

  int _calculateRailroadRent() {
    final ownedRailroads = owner?.ownedProperties
            .where((p) => p.type == PropertyType.railroad && !p.isMortgaged)
            .length ??
        0;
    return getRailRoadRent(ownedRailroads);
  }

  int getRailRoadRent(int count) {
    if (count == 0) return baseRent;
    return baseRent * (1 << (count - 1));
  }

  int getHouseRent(int level) {
    if (rentTable != null && level < rentTable!.length) {
      return rentTable![level];
    }
    return baseRent * _legacyRentMultipliers[level];
  }

  void mortgage() {
    if (!canMortgage) {
      throw Exception(_mortgageErrorMessage());
    }
    isMortgaged = true;
  }

  String _mortgageErrorMessage() {
    if (isMortgaged) return "Property is already mortgaged";
    if (owner == null) return "Property must have an owner to mortgage";
    if (houses > 0 || hasHotel) {
      return "Cannot mortgage a property with houses or a hotel";
    }
    if (owner!.isBankrupt) {
      return "Cannot mortgage property owned by a bankrupt player";
    }
    return "Cannot mortgage property";
  }

  void unmortgage() {
    if (!canUnmortgage) {
      throw Exception("Property is not mortgaged");
    }
    isMortgaged = false;
  }

  /// Upgrade this property by one level. Auto-promotes 4 houses → hotel when
  /// the bank has a hotel available, returning the 4 houses to the bank.
  ///
  /// NOTE: Rule-level checks (full color-group ownership, even building) live
  /// in the engine's `upgradeProperty`. This method only enforces the
  /// per-property invariants.
  void upgrade(Bank? bank, {bool buildHotel = false}) {
    if (!canUpgrade) {
      throw Exception(_upgradeErrorMessage(bank));
    }
    if (houses == 4) {
      if (bank != null) {
        if (!bank.canGiveHotel) {
          throw Exception("No hotels available in the bank");
        }
        bank.giveHotel();
        for (var i = 0; i < 4; i++) {
          bank.takeHouse();
        }
      }
      houses = 0;
      hasHotel = true;
    } else if (houses < 4) {
      if (bank != null) {
        if (!bank.canGiveHouse) {
          throw Exception("No houses available in the bank");
        }
        bank.giveHouse();
      }
      houses++;
    } else {
      throw Exception("Cannot upgrade further");
    }
  }

  String _upgradeErrorMessage(Bank? bank) {
    if (owner == null) return "Property must have an owner to upgrade";
    if (isMortgaged) return "Cannot upgrade a mortgaged property";
    if (hasHotel) return "Property already has a hotel";
    if (houses < 4 && bank != null && bank.availableHouses <= 0) {
      return "No houses available in the bank";
    }
    if (houses == 4 && bank != null && bank.availableHotels <= 0) {
      return "No hotels available in the bank";
    }
    return "Cannot upgrade property";
  }

  /// Downgrade this property by one level. Returns the house/hotel to the bank.
  /// Does not handle the refund — engine handles that at `downgradeProperty`.
  void downgrade(Bank? bank) {
    if (!canDowngrade) {
      throw Exception("Property has no houses or hotels to downgrade");
    }
    if (hasHotel) {
      // Hotel → 4 houses: take 4 houses from bank and return hotel.
      if (bank != null) {
        if (bank.availableHouses < 4) {
          throw Exception("Not enough houses in bank to break down hotel");
        }
        for (var i = 0; i < 4; i++) {
          bank.giveHouse();
        }
        bank.takeHotel();
      }
      hasHotel = false;
      houses = 4;
    } else {
      if (bank != null) bank.takeHouse();
      houses--;
    }
  }

  bool get canMortgage =>
      !isMortgaged &&
      owner != null &&
      houses == 0 &&
      !hasHotel &&
      !(owner?.isBankrupt ?? false);

  bool get canUnmortgage => isMortgaged;

  bool get canUpgrade {
    if (owner == null || isMortgaged || hasHotel) return false;
    return true;
  }

  bool get canDowngrade => hasHotel || houses > 0;

  bool get canConstruct => type == PropertyType.street;

  bool isOwned() => owner != null;

  /// Improvement level, 0–5 (0 = unimproved, 5 = hotel).
  int get improvementLevel => hasHotel ? 5 : houses;
}
