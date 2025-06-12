import 'enums.dart';
import '../models/player.dart';
import '../engine/game_engine.dart';

/// Represents a card in the Monopoly game.
class Card {
  final String description;
  final CardType type;
  final int? targetTileIndex;
  final double? amount;
  final double? amount2;
  final int? steps;

  Card({
    required this.description,
    required this.type,
    this.targetTileIndex,
    this.amount,
    this.amount2,
    this.steps,
  });

  bool get isGoToJailCard => type == CardType.goToJail;
  bool get isGetOutOfJailCard => type == CardType.getOutOfJail;
  bool get isReceiveCard => type == CardType.receive;
  bool get isPayCard => type == CardType.pay;
  bool get isPropertyRepairsCard => type == CardType.propertyRepairs;
  bool get isPayOtherPlayersCard => type == CardType.payOtherPlayers;
  bool get isCollectFromOtherPlayersCard => type == CardType.collectFromOtherPlayers;

  /// Applies the effect of the card to the player.
  void applyEffect(Player player, GameEngine gameEngine) {
    switch (type) {
      case CardType.goToJail:
        gameEngine.sendToJail(player);
        break;
      case CardType.getOutOfJail:
        // Give player a Get Out of Jail Free card
        player.getOutOfJailCards++;
        break;
      case CardType.receive:
        _applyReceive(player);
        break;
      case CardType.pay:
        _applyPay(player);
        break;
      case CardType.propertyRepairs:
        _applyPropertyRepairs(player);
        break;
      case CardType.payOtherPlayers:
        _applyPayOtherPlayers(player, gameEngine);
        break;
      case CardType.collectFromOtherPlayers:
        _applyCollectFromOtherPlayers(player, gameEngine);
        break;
      default:
        throw Exception("Unhandled card type: $type");
    }
  }

  void _applyReceive(Player player) {
    // Collect money from the bank
    player.receive(amount!);
  }

  void _applyPay(Player player) {
    // Pay money to the bank
    player.pay(amount!);
  }

  void _applyPropertyRepairs(Player player) {
    // Pay for property repairs: amount is cost per house/hotel
    int houseCount = 0;
    int hotelCount = 0;
    for (final property in player.ownedProperties) {
      houseCount += property.houses;
      if (property.hasHotel) hotelCount++;
    }
    final double houseCost = houseCount * (amount ?? 0);
    final double hotelCost = hotelCount * (amount2 ?? 0);
    final double total = houseCost + hotelCost;
    player.pay(total);
  }

  void _applyPayOtherPlayers(Player player, GameEngine gameEngine) {
    // Pay each other player a fixed amount
    for (final other in gameEngine.players) {
      if (other != player && !other.isBankrupt) {
        player.pay(amount!);
        other.receive(amount!);
      }
    }
  }

  void _applyCollectFromOtherPlayers(Player player, GameEngine gameEngine) {
    // Collect a fixed amount from each other player
    for (final other in gameEngine.players) {
      if (other != player && !other.isBankrupt) {
        other.pay(amount!, true);
        player.receive(amount!);
      }
    }
  }
}