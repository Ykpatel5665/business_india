/// Represents the bank in the Monopoly game.
class Bank {
  int availableHouses;
  int availableHotels;
  double freeParkingPot = 0.0;

  Bank({
    this.availableHouses = 32,
    this.availableHotels = 12,
  });

  void giveHouse() {
    if (availableHouses <= 0) {
      throw Exception("No houses available in the bank");
    }
    availableHouses--;
  }

  void takeHouse() {
    availableHouses++;
  }

  void giveHotel() {
    if (availableHotels <= 0) {
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
}