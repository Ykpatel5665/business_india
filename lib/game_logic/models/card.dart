import 'enums.dart';
import '../models/player.dart';
import '../engine/game_engine.dart';

/// Represents a card in the Monopoly game.
class Card {
  final String description;
  final CardType type;
  final void Function() effect;
  final int? targetTileIndex;
  final double? amount;

  Card({
    required this.description,
    required this.type,
    required this.effect,
    this.targetTileIndex,
    this.amount,
  });

  /// Applies the effect of the card to the player.
  void applyEffect(Player player, GameEngine gameEngine) {
    switch (type) {
      case CardType.goToJail:
        // Send player to jail
        player.inJail = true;
        player.position = gameEngine.board.indexWhere((tile) => tile.type == TileType.jail);
        player.jailTurns = 0;
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
        final costPerHouse = amount ?? 0;
        // TODO : Check hotel cost if different from house cost
        final total = (houseCount + hotelCount) * costPerHouse;
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