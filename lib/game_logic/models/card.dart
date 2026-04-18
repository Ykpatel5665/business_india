import 'enums.dart';
import '../models/player.dart';
import '../engine/game_engine.dart';

/// Represents a Chance or Community Chest card.
///
/// `origin` is tagged by the engine at draw time (or by board authors) so
/// Get-Out-of-Jail-Free cards can be returned to the correct deck when used.
class Card {
  final String description;
  final CardType type;
  final int? targetTileIndex;
  final int? amount;
  final int? amount2;
  final int? steps;

  /// Which deck this card belongs to. Set at draw time by the engine if not
  /// provided at construction. Defaults to `DeckOrigin.chance` when a Card
  /// is applied outside a draw (e.g. in isolated unit tests).
  DeckOrigin? origin;

  Card({
    required this.description,
    required this.type,
    this.targetTileIndex,
    this.amount,
    this.amount2,
    this.steps,
    this.origin,
  });

  bool get isGoToJailCard => type == CardType.goToJail;
  bool get isGetOutOfJailCard => type == CardType.getOutOfJail;
  bool get isReceiveCard => type == CardType.receive;
  bool get isPayCard => type == CardType.pay;
  bool get isPropertyRepairsCard => type == CardType.propertyRepairs;
  bool get isPayOtherPlayersCard => type == CardType.payOtherPlayers;
  bool get isCollectFromOtherPlayersCard =>
      type == CardType.collectFromOtherPlayers;

  void applyEffect(Player player, GameEngine gameEngine) {
    switch (type) {
      case CardType.goToJail:
        gameEngine.sendToJail(player);
        break;
      case CardType.getOutOfJail:
        player.goojfCards.add(origin ?? DeckOrigin.chance);
        break;
      case CardType.receive:
        player.receive(amount!);
        break;
      case CardType.pay:
        gameEngine.chargePlayer(player, amount!);
        break;
      case CardType.propertyRepairs:
        _applyPropertyRepairs(player, gameEngine);
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

  void _applyPropertyRepairs(Player player, GameEngine gameEngine) {
    int houseCount = 0;
    int hotelCount = 0;
    for (final property in player.ownedProperties) {
      houseCount += property.houses;
      if (property.hasHotel) hotelCount++;
    }
    final int total = houseCount * (amount ?? 0) + hotelCount * (amount2 ?? 0);
    if (total > 0) {
      gameEngine.chargePlayer(player, total);
    }
  }

  void _applyPayOtherPlayers(Player player, GameEngine gameEngine) {
    for (final other in gameEngine.players) {
      if (other != player && !other.isBankrupt) {
        final outcome = gameEngine.chargePlayer(player, amount!, creditor: other);
        if (outcome == PayOutcome.paid) {
          other.receive(amount!);
        }
        if (player.isBankrupt) break;
      }
    }
  }

  void _applyCollectFromOtherPlayers(Player player, GameEngine gameEngine) {
    for (final other in gameEngine.players) {
      if (other != player && !other.isBankrupt) {
        final outcome = gameEngine.chargePlayer(other, amount!, creditor: player);
        if (outcome == PayOutcome.paid) {
          player.receive(amount!);
        }
      }
    }
  }
}
