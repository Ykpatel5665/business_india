import 'enums.dart';
import 'player.dart';
import 'property.dart';

/// Adds a containsAll method for List<Property>.
extension PropertyListExtensions on List<Property> {
  bool containsAll(List<Property> other) {
    for (var property in other) {
      if (!this.contains(property)) {
        return false;
      }
    }
    return true;
  }
}

/// Represents a trade offer between players in the Monopoly game.
class Trade {
  final Player fromPlayer;
  final Player toPlayer;
  final List<Property> offeredProperties;
  final List<Property> requestedProperties;
  final double offeredCash;
  final double requestedCash;
  TradeStatus status;

  Trade({
    required this.fromPlayer,
    required this.toPlayer,
    this.offeredProperties = const [],
    this.requestedProperties = const [],
    this.offeredCash = 0.0,
    this.requestedCash = 0.0,
    this.status = TradeStatus.pending,
  });

  void accept() {
    if (status != TradeStatus.pending) {
      throw Exception("Trade is not in a pending state");
    }
    status = TradeStatus.accepted;
    _executeTrade();
  }

  void reject() {
    if (status != TradeStatus.pending) {
      throw Exception("Trade is not in a pending state");
    }
    status = TradeStatus.rejected;
  }

  void cancel() {
    if (status != TradeStatus.pending) {
      throw Exception("Trade is not in a pending state");
    }
    status = TradeStatus.cancelled;
  }

  /// Validates the trade to ensure it can be executed.
  bool isValid() {
    if (status != TradeStatus.pending) return false;
    if (offeredCash < 0 || requestedCash < 0) return false;
    if (!fromPlayer.ownedProperties.containsAll(offeredProperties)) return false;
    if (!toPlayer.ownedProperties.containsAll(requestedProperties)) return false;
    return true;
  }

  /// Executes the trade if it is valid.
  void execute() {
    if (!isValid()) {
      throw Exception("Trade is not valid and cannot be executed");
    }
    _executeTrade();
  }

  void _executeTrade() {
    for (var property in offeredProperties) {
      if (!fromPlayer.ownedProperties.contains(property)) {
        throw Exception("Property not owned by the offering player");
      }
      fromPlayer.ownedProperties.remove(property);
      toPlayer.ownedProperties.add(property);
      property.owner = toPlayer;
    }

    for (var property in requestedProperties) {
      if (!toPlayer.ownedProperties.contains(property)) {
        throw Exception("Property not owned by the receiving player");
      }
      toPlayer.ownedProperties.remove(property);
      fromPlayer.ownedProperties.add(property);
      property.owner = fromPlayer;
    }

    if (offeredCash > 0) {
      fromPlayer.pay(offeredCash);
      toPlayer.receive(offeredCash);
    }

    if (requestedCash > 0) {
      toPlayer.pay(requestedCash);
      fromPlayer.receive(requestedCash);
    }
  }
}