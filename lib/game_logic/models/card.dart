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
        // Collect money from the bank
        player.receive(amount!);
        break;
      case CardType.pay:
        // Pay money to the bank
        player.pay(amount!);
        break;
      case CardType.propertyRepairs:
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
        break;
      case CardType.payOtherPlayers:
        // Pay each other player a fixed amount
        for (final other in gameEngine.players) {
          if (other != player && !other.isBankrupt) {
            player.pay(amount!);
            other.receive(amount!);
          }
        }
        break;
      case CardType.collectFromOtherPlayers:
        // Collect a fixed amount from each other player
        for (final other in gameEngine.players) {
          if (other != player && !other.isBankrupt) {
            other.pay(amount!, true);
            player.receive(amount!);
          }
        }
        break;
      default:
        throw Exception("Unhandled card type: $type");
    }
  }
}