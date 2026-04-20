import 'enums.dart';
import 'player.dart';
import 'property.dart';

extension PropertyListExtensions on List<Property> {
  bool containsAll(List<Property> other) {
    for (final property in other) {
      if (!contains(property)) return false;
    }
    return true;
  }
}

/// A trade offer between two players.
///
/// Cash amounts are integer currency. Property lists transfer as-is.
/// NOTE: mortgaged-property transfer fees and GOOJF-card trading are Phase 2.
class Trade {
  final Player fromPlayer;
  final Player toPlayer;
  final List<Property> offeredProperties;
  final List<Property> requestedProperties;
  final int offeredCash;
  final int requestedCash;
  TradeStatus status;

  Trade({
    required this.fromPlayer,
    required this.toPlayer,
    this.offeredProperties = const [],
    this.requestedProperties = const [],
    this.offeredCash = 0,
    this.requestedCash = 0,
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

  bool get isPending => status == TradeStatus.pending;
  bool get isAccepted => status == TradeStatus.accepted;
  bool get isRejected => status == TradeStatus.rejected;
  bool get isCancelled => status == TradeStatus.cancelled;

  bool canOfferProperties() =>
      fromPlayer.ownedProperties.containsAll(offeredProperties);
  bool canRequestProperties() =>
      toPlayer.ownedProperties.containsAll(requestedProperties);
  bool canOfferCash() => fromPlayer.balance >= offeredCash;
  bool canRequestCash() => toPlayer.balance >= requestedCash;
  bool canExecute() =>
      isPending &&
      canOfferProperties() &&
      canRequestProperties() &&
      canOfferCash() &&
      canRequestCash();

  bool isValid() {
    if (!isPending) return false;
    if (offeredCash < 0 || requestedCash < 0) return false;
    if (!canOfferProperties()) return false;
    if (!canRequestProperties()) return false;
    if (!canOfferCash()) return false;
    if (!canRequestCash()) return false;
    return true;
  }

  void execute() {
    if (!isValid()) {
      throw Exception("Trade is not valid and cannot be executed");
    }
    _executeTrade();
  }

  void _transferProperties(List<Property> properties, Player from, Player to) {
    for (final property in properties) {
      if (!from.ownedProperties.contains(property)) {
        throw Exception("Property not owned by the transferring player");
      }
      from.ownedProperties.remove(property);
      to.ownedProperties.add(property);
      property.owner = to;
    }
  }

  void _transferCash(int amount, Player from, Player to) {
    if (amount > 0) {
      from.pay(amount);
      to.receive(amount);
    }
  }

  void _executeTrade() {
    _transferProperties(offeredProperties, fromPlayer, toPlayer);
    _transferProperties(requestedProperties, toPlayer, fromPlayer);
    _transferCash(offeredCash, fromPlayer, toPlayer);
    _transferCash(requestedCash, toPlayer, fromPlayer);
  }
}
