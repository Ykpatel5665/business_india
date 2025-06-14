/// Represents all configurable settings and rules for the Monopoly game.
class GameConfig {
  // Game settings
  final double startingBalance;
  final bool enableAuctions;
  final bool limitedBankResources;
  final bool jailRules;
  final bool freeParkingRules;
  final List<String> customBoardLayout;

  // Game rules
  final double goReward;
  final double jailExitCost;
  final int maxJailTurns;
  final double taxAmount;
  final bool freeParkingCollects;
  final double freeParkingStart;
  final int initialHouses;
  final int initialHotels;
  final double monopolyRentMultiplier;
  final double mortgageInterestRate;

  const GameConfig({
    // Settings
    this.startingBalance = 1500.0,
    this.enableAuctions = true,
    this.limitedBankResources = true,
    this.jailRules = true,
    this.freeParkingRules = false,
    this.customBoardLayout = const [],
    // Rules
    this.goReward = 200.0,
    this.jailExitCost = 50.0,
    this.maxJailTurns = 3,
    this.taxAmount = 200.0,
    this.freeParkingCollects = false,
    this.freeParkingStart = 0.0,
    this.initialHouses = 32,
    this.initialHotels = 12,
    this.monopolyRentMultiplier = 2.0,
    this.mortgageInterestRate = 0.1,
  });

  void copyFrom(GameConfig other) {
    // This method cannot mutate final fields, but is required for persistence compatibility.
    // You should replace the instance in the caller, or refactor to use a new instance.
    throw UnimplementedError('GameConfig is immutable. Replace the instance instead.');
  }
}