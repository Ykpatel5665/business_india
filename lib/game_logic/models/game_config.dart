/// Represents all configurable settings and rules for the Monopoly game.
///
/// Money values are integer rupees (or integer currency units for test boards).
/// Multipliers/rates remain `double` because they're ratios, not money.
class GameConfig {
  // Game settings
  final int startingBalance;
  final bool enableAuctions;
  final bool limitedBankResources;
  final bool jailRules;
  final bool freeParkingRules;
  final List<String> customBoardLayout;

  // Game rules
  final int goReward;
  final int jailExitCost;
  final int maxJailTurns;
  final int taxAmount;
  final bool freeParkingCollects;
  final int freeParkingStart;
  final int initialHouses;
  final int initialHotels;
  final double monopolyRentMultiplier;
  final double mortgageInterestRate;

  const GameConfig({
    this.startingBalance = 1500,
    this.enableAuctions = true,
    this.limitedBankResources = true,
    this.jailRules = true,
    this.freeParkingRules = false,
    this.customBoardLayout = const [],
    this.goReward = 200,
    this.jailExitCost = 50,
    this.maxJailTurns = 3,
    this.taxAmount = 200,
    this.freeParkingCollects = false,
    this.freeParkingStart = 0,
    this.initialHouses = 32,
    this.initialHotels = 12,
    this.monopolyRentMultiplier = 2.0,
    this.mortgageInterestRate = 0.1,
  });
}
