/// Represents the bank in the Monopoly game.
class Bank {
  int availableHouses;
  int availableHotels;
  double freeParkingPot = 0.0;

  Bank({
    this.availableHouses = 32,
    this.availableHotels = 12,
  });

  bool get canGiveHouse => availableHouses > 0;
  bool get canGiveHotel => availableHotels > 0;

  void giveHouse() {
    if (!canGiveHouse) {
      throw Exception("No houses available in the bank");
    }
    availableHouses--;
  }

  void takeHouse() {
    availableHouses++;
  }

  void giveHotel() {
    if (!canGiveHotel) {
      throw Exception("No hotels available in the bank");
    }
    availableHotels--;
  }

  void takeHotel() {
    availableHotels++;
  }

  void addToFreeParking(double amount) {
    freeParkingPot += amount;
  }

  /// Collects funds from Free Parking (example implementation).
  double collectFreeParkingFunds() {
    final funds = freeParkingPot;
    freeParkingPot = 0;
    return funds;
  }

  void copyFrom(Bank other) {
    availableHouses = other.availableHouses;
    availableHotels = other.availableHotels;
    freeParkingPot = other.freeParkingPot;
  }
}