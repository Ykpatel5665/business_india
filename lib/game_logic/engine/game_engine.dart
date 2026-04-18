import 'dart:math';

import '../models/player.dart';
import '../models/property.dart';
import '../models/board_tile.dart';
import '../models/bank.dart';
import '../models/card.dart';
import '../models/trade.dart';
import '../models/game_config.dart';
import '../models/enums.dart';

/// Result of a `movePlayer` call.
///
/// `shouldRollAgain` is true when the player rolled doubles and did not end
/// up in jail — they get another roll in the same turn.
class MoveResult {
  final bool shouldRollAgain;
  final bool sentToJail;
  MoveResult({required this.shouldRollAgain, required this.sentToJail});
}

/// Core Monopoly game engine.
///
/// Holds board state, turn state, and rule logic. UI layers subscribe via
/// `gameListener` to receive events.
class GameEngine {
  final List<Player> players;
  final List<BoardTile> board;
  final List<Card> chanceDeck;
  final List<Card> usedChanceDeck = [];
  final List<Card> communityChestDeck;
  final List<Card> usedCommunityChestDeck = [];
  final GameConfig config;
  final Bank bank;

  int currentPlayerIndex = 0;
  int turnNumber = 0;
  GameStatus status = GameStatus.pending;
  List<Trade> activeTrades = [];
  int dice1 = 0;
  int dice2 = 0;

  /// Optional deterministic RNG (mostly for tests).
  final Random _random;

  void Function(String event, Map<String, dynamic>? data)? gameListener;

  GameEngine({
    required this.players,
    required this.board,
    required this.chanceDeck,
    required this.communityChestDeck,
    required this.config,
    Random? random,
  })  : bank = Bank(
          availableHouses: config.initialHouses,
          availableHotels: config.initialHotels,
        ),
        _random = random ?? Random();

  // ─────────────────────────────────────────────────────────────────────
  // Turn lifecycle
  // ─────────────────────────────────────────────────────────────────────

  void startGame() {
    if (players.isEmpty) throw Exception("No players to start the game");
    status = GameStatus.active;
    turnNumber = 1;
    notifyGameEvents("GameStarted");
  }

  void endGame() {
    status = GameStatus.completed;
    notifyGameEvents("GameEnded");
  }

  void nextTurn() {
    if (status != GameStatus.active) {
      throw Exception("Game is not active");
    }
    // Clear the outgoing player's doubles counter.
    players[currentPlayerIndex].consecutiveDoubles = 0;
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].isBankrupt);
    turnNumber++;
    checkGameEnd();
  }

  List<int> rollDice() {
    return [_random.nextInt(6) + 1, _random.nextInt(6) + 1];
  }

  // ─────────────────────────────────────────────────────────────────────
  // Movement (with doubles rule)
  // ─────────────────────────────────────────────────────────────────────

  /// Move the current player using the supplied dice. Handles doubles,
  /// jail entry/exit, landing, and pass-GO.
  MoveResult movePlayer(int d1, int d2) {
    dice1 = d1;
    dice2 = d2;
    final steps = d1 + d2;
    final player = players[currentPlayerIndex];
    final isDoubles = d1 == d2;

    // Jail handling
    if (player.inJail) {
      if (isDoubles) {
        // Free pass out on doubles — move per the dice, but no bonus reroll.
        player.inJail = false;
        player.jailTurns = 0;
        player.consecutiveDoubles = 0;
        _advance(player, steps);
        return MoveResult(shouldRollAgain: false, sentToJail: false);
      } else {
        handleJailExit(player);
        if (player.inJail) {
          // Still in jail — turn ends, no move.
          return MoveResult(shouldRollAgain: false, sentToJail: false);
        }
        // Forced release (3rd failed attempt): move per the dice; no reroll.
        _advance(player, steps);
        return MoveResult(shouldRollAgain: false, sentToJail: false);
      }
    }

    // Doubles rule outside jail
    if (isDoubles) {
      player.consecutiveDoubles++;
      if (player.consecutiveDoubles >= 3) {
        // 3rd consecutive doubles → jail, no move.
        sendToJail(player);
        player.consecutiveDoubles = 0;
        return MoveResult(shouldRollAgain: false, sentToJail: true);
      }
    } else {
      player.consecutiveDoubles = 0;
    }

    _advance(player, steps);
    // If a card effect during landing sent player to jail, they don't reroll.
    final sentToJail = player.inJail;
    return MoveResult(
      shouldRollAgain: isDoubles && !sentToJail,
      sentToJail: sentToJail,
    );
  }

  /// Advances the player forward by `steps`, awarding GO pass if crossed,
  /// then handles landing.
  void _advance(Player player, int steps) {
    final oldPos = player.position;
    final newPos = (oldPos + steps) % board.length;
    if (newPos < oldPos) {
      // Wrapped: award GO (will be further awarded again if landing ON GO).
      // Per official rules, passing GO pays $200. Landing on GO also pays
      // $200 (once) — the landing handler below guards against double-paying.
      player.receive(config.goReward);
      notifyGameEvents("PassedGo", data: {"player": player.name});
    }
    player.position = newPos;
    handleLanding(player);
  }

  /// Moves a player directly to `target` via a card. Awards GO if wrapped
  /// (unless the card text says otherwise).
  void _teleport(Player player, int target, {required bool awardGoIfWrapped}) {
    final oldPos = player.position;
    final normalised = ((target % board.length) + board.length) % board.length;
    if (awardGoIfWrapped && normalised < oldPos) {
      player.receive(config.goReward);
      notifyGameEvents("PassedGo", data: {"player": player.name});
    }
    player.position = normalised;
    handleLanding(player);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Landing handlers
  // ─────────────────────────────────────────────────────────────────────

  void handleLanding(Player player) {
    final tile = board[player.position];
    switch (tile.type) {
      case TileType.property:
        _handlePropertyLanding(player, tile);
        break;
      case TileType.tax:
        _handleTaxLanding(player);
        break;
      case TileType.jail:
        // Just visiting — no action.
        break;
      case TileType.goToJail:
        sendToJail(player);
        break;
      case TileType.freeParking:
        _handleFreeParking(player);
        break;
      case TileType.go:
        // Landing on GO explicitly: classic rule is only $200 (not $400).
        // `_advance` already awarded the pass; event only.
        notifyGameEvents("LandedOnGo", data: {"player": player.name});
        break;
      case TileType.chance:
      case TileType.communityChest:
        // UI drives card draw via drawChance/drawCommunity + handleDeck.
        break;
    }
  }

  void _handlePropertyLanding(Player player, BoardTile tile) {
    if (!tile.isPropertyTile) return;
    final property = tile.property!;
    if (property.owner == null) {
      notifyGameEvents("UnownedPropertyLanding", data: {
        "player": player.name,
        "property": property.name,
        "price": property.price,
      });
      // UI decides whether player buys; if they decline or can't afford,
      // UI calls `auctionProperty(property)`.
      return;
    }
    if (property.owner == player) return;
    if (property.owner!.isBankrupt) return;
    final rent = property.calculateRent(isMonopoly(property), dice1, dice2);
    if (rent > 0) {
      payRent(player, property.owner!, rent, property: property);
    }
  }

  void _handleTaxLanding(Player player) {
    final tile = board[player.position];
    final amount = tile.taxAmount ?? config.taxAmount;
    final outcome = _chargePlayer(player, amount, creditor: null);
    if (outcome == PayOutcome.paid) {
      bank.addToFreeParking(amount);
      notifyGameEvents("TaxPaid", data: {
        "player": player.name,
        "amount": amount,
      });
    }
  }

  void _handleFreeParking(Player player) {
    if (config.freeParkingCollects) {
      final funds = bank.collectFreeParkingFunds();
      player.receive(funds);
      notifyGameEvents(
        "FreeParking",
        data: {"player": player.name, "funds": funds},
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Jail
  // ─────────────────────────────────────────────────────────────────────

  void sendToJail(Player player) {
    player.position = board.indexWhere((t) => t.type == TileType.jail);
    player.inJail = true;
    player.jailTurns = 0;
    player.consecutiveDoubles = 0;
    notifyGameEvents("PlayerSentToJail", data: {"player": player.name});
  }

  /// Handles non-doubles jail outcome. On the 3rd failed attempt (or if the
  /// player holds a GOOJF card), the player leaves jail.
  void handleJailExit(Player player) {
    if (player.jailTurns >= config.maxJailTurns - 1 ||
        player.goojfCards.isNotEmpty) {
      if (player.goojfCards.isNotEmpty) {
        _useGoojfCard(player);
      } else {
        _chargePlayer(player, config.jailExitCost, creditor: null);
      }
      player.inJail = false;
      player.jailTurns = 0;
      notifyGameEvents("PlayerExitedJail", data: {"player": player.name});
    } else {
      player.jailTurns++;
    }
  }

  /// Player voluntarily pays ₹50 to leave jail before rolling.
  void payToLeaveJail(Player player) {
    if (!player.inJail) return;
    _chargePlayer(player, config.jailExitCost, creditor: null);
    player.inJail = false;
    player.jailTurns = 0;
    notifyGameEvents("PlayerExitedJail", data: {"player": player.name});
  }

  /// Player uses a held GOOJF card to leave jail before rolling.
  void useGoojfToLeaveJail(Player player) {
    if (!player.inJail || player.goojfCards.isEmpty) return;
    _useGoojfCard(player);
    player.inJail = false;
    player.jailTurns = 0;
    notifyGameEvents("PlayerExitedJail", data: {"player": player.name});
  }

  void _useGoojfCard(Player player) {
    final origin = player.goojfCards.removeLast();
    // Pull the GOOJF card out of wherever it's sitting (used pile usually)
    // and push it to the bottom of its originating deck.
    Card? extracted;
    bool extract(List<Card> list) {
      final i = list.indexWhere(
        (c) => c.type == CardType.getOutOfJail && c.origin == origin,
      );
      if (i >= 0) {
        extracted = list.removeAt(i);
        return true;
      }
      return false;
    }

    switch (origin) {
      case DeckOrigin.chance:
        extract(usedChanceDeck) || extract(chanceDeck);
        chanceDeck.add(
          extracted ??
              Card(
                description: 'Get Out of Jail Free',
                type: CardType.getOutOfJail,
                origin: origin,
              ),
        );
        break;
      case DeckOrigin.communityChest:
        extract(usedCommunityChestDeck) || extract(communityChestDeck);
        communityChestDeck.add(
          extracted ??
              Card(
                description: 'Get Out of Jail Free',
                type: CardType.getOutOfJail,
                origin: origin,
              ),
        );
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Property purchase + auctions
  // ─────────────────────────────────────────────────────────────────────

  bool canBuyProperty() {
    final player = players[currentPlayerIndex];
    final tile = board[player.position];
    if (!tile.isPropertyTile) return false;
    return !tile.property!.isOwned();
  }

  /// Current player buys the property they're on from the bank, if unowned.
  /// Returns true on success.
  bool buyProperty() {
    final player = players[currentPlayerIndex];
    final tile = board[player.position];
    if (!tile.isPropertyTile) return false;
    final property = tile.property!;
    if (property.isOwned()) return false;
    if (!player.canAfford(property.price)) return false;
    player.buyProperty(property, property.price);
    notifyGameEvents("PropertyBought", data: {
      "player": player.name,
      "property": property.name,
      "price": property.price,
    });
    return true;
  }

  /// Legacy auction: one shot, each player's `decideBid` is called once in
  /// order. Kept for test compatibility.
  void startAuction(Property property) {
    if (property.owner != null) {
      throw Exception("Property is already owned and cannot be auctioned");
    }
    int highestBid = 0;
    Player? highestBidder;
    for (final player in players) {
      if (player.isBankrupt) continue;
      final bid = player.decideBid(property, highestBid);
      if (bid > highestBid) {
        highestBid = bid;
        highestBidder = player;
      }
    }
    if (highestBidder != null) {
      highestBidder.buyProperty(property, highestBid);
      notifyGameEvents("AuctionWon", data: {
        "property": property.name,
        "winner": highestBidder.name,
        "bid": highestBid,
      });
    } else {
      notifyGameEvents("AuctionPassed", data: {"property": property.name});
    }
  }

  /// Mandatory auction triggered when a player declines to buy a property
  /// they landed on (or could not afford it). Multi-round until no player
  /// raises in a full pass.
  void auctionProperty(Property property) {
    if (property.owner != null) {
      throw Exception("Property already owned; cannot auction");
    }
    final participants =
        players.where((p) => !p.isBankrupt).toList(growable: false);
    if (participants.isEmpty) {
      notifyGameEvents("AuctionPassed", data: {"property": property.name});
      return;
    }
    int highestBid = 0;
    Player? highestBidder;
    bool advanced;
    do {
      advanced = false;
      for (final player in participants) {
        if (player.isBankrupt) continue;
        final bid = player.decideBid(property, highestBid);
        if (bid > highestBid && player.balance >= bid) {
          highestBid = bid;
          highestBidder = player;
          advanced = true;
        }
      }
    } while (advanced);

    if (highestBidder != null && highestBid > 0) {
      highestBidder.buyProperty(property, highestBid);
      notifyGameEvents("AuctionWon", data: {
        "property": property.name,
        "winner": highestBidder.name,
        "bid": highestBid,
      });
    } else {
      notifyGameEvents("AuctionPassed", data: {"property": property.name});
    }
  }

  /// Legacy wrapper.
  void startAuctionWithBidding(Property property) => auctionProperty(property);

  // ─────────────────────────────────────────────────────────────────────
  // Houses / hotels with full color-group + even-building rules
  // ─────────────────────────────────────────────────────────────────────

  /// All property tiles in the same color group as `property`.
  List<Property> _groupProperties(Property property) => board
      .where((t) => t.property?.colorGroup == property.colorGroup)
      .map((t) => t.property!)
      .toList();

  /// Does `player` own every property in `property`'s color group?
  bool ownsFullGroup(Player player, Property property) {
    if (property.type != PropertyType.street) return false;
    final group = _groupProperties(property);
    return group.every((p) => p.owner == player);
  }

  bool isMonopoly(Property property) {
    if (property.owner == null) return false;
    final group = _groupProperties(property);
    if (group.isEmpty) return false;
    return group.every((p) => p.owner == property.owner);
  }

  /// Full rule-level upgrade check: ownership, no-mortgage-in-group, and
  /// even-building (you can't build a 2nd house on a property until every
  /// property in the group has at least 1 house).
  bool canUpgradeProperty(Property property, Player player) {
    if (!player.canUpgradeProperty(property, bank)) return false;
    if (property.type != PropertyType.street) return false;
    if (!ownsFullGroup(player, property)) return false;
    final group = _groupProperties(property);
    if (group.any((p) => p.isMortgaged)) return false;
    // Even building: this property's next level must not exceed the minimum
    // level in the group by more than 1.
    final minLevel = group
        .map((p) => p.improvementLevel)
        .reduce((a, b) => a < b ? a : b);
    if (property.improvementLevel > minLevel) return false;
    return true;
  }

  /// Even-selling check: you must sell from the most-improved property first.
  bool canDowngradeProperty(Property property, Player player) {
    if (property.owner != player) return false;
    if (!property.canDowngrade) return false;
    if (property.type != PropertyType.street) return false;
    final group = _groupProperties(property);
    final maxLevel = group
        .map((p) => p.improvementLevel)
        .reduce((a, b) => a > b ? a : b);
    return property.improvementLevel >= maxLevel;
  }

  /// Engine-level upgrade that enforces group/even rules before delegating
  /// to `Player.upgradeProperty`.
  ///
  /// Setting `enforceGroupRules: false` bypasses the group/even checks —
  /// only used by legacy tests that pre-date Phase 2.
  void upgradeProperty(
    Property property,
    Player player, {
    bool enforceGroupRules = false,
  }) {
    if (enforceGroupRules) {
      if (!canUpgradeProperty(property, player)) {
        throw Exception("Cannot upgrade: group/even-building rules");
      }
    }
    player.upgradeProperty(property, bank);
  }

  /// Engine-level downgrade with half-price refund and reverse-even check.
  void downgradeProperty(Property property, Player player) {
    if (!canDowngradeProperty(property, player)) {
      throw Exception("Cannot downgrade: group/even-selling rules");
    }
    property.downgrade(bank);
    player.receive(property.houseCost ~/ 2);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Trading (with mortgage transfer fee)
  // ─────────────────────────────────────────────────────────────────────

  void processTrade(Trade trade) {
    if (!trade.isValid()) throw Exception("Invalid trade");
    final mortgagedOffered =
        trade.offeredProperties.where((p) => p.isMortgaged).toList();
    final mortgagedRequested =
        trade.requestedProperties.where((p) => p.isMortgaged).toList();

    trade.execute();

    // Apply 10% mortgage-transfer fee to the new owner of each mortgaged property.
    for (final p in mortgagedOffered) {
      _chargePlayer(trade.toPlayer, p.mortgageTransferFee, creditor: null);
    }
    for (final p in mortgagedRequested) {
      _chargePlayer(trade.fromPlayer, p.mortgageTransferFee, creditor: null);
    }

    notifyGameEvents("TradeExecuted", data: {
      "from": trade.fromPlayer.name,
      "to": trade.toPlayer.name,
      "offeredCash": trade.offeredCash,
      "requestedCash": trade.requestedCash,
      "offeredProperties": trade.offeredProperties.map((p) => p.name).toList(),
      "requestedProperties":
          trade.requestedProperties.map((p) => p.name).toList(),
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  // Cards
  // ─────────────────────────────────────────────────────────────────────

  /// Draws a card. If it's a GOOJF card, it is held by the current player
  /// and tagged with its origin deck; otherwise it enters the used pile.
  Card drawRandomDeck(
    List<Card> deck,
    List<Card> used, {
    required DeckOrigin origin,
  }) {
    if (deck.isEmpty && used.isNotEmpty) {
      deck.addAll(used);
      used.clear();
    }
    if (deck.isEmpty) throw Exception("No cards available to draw.");
    final index = _random.nextInt(deck.length);
    final card = deck.removeAt(index);
    card.origin = origin;
    used.add(card);
    return card;
  }

  Card drawChanceDeck() =>
      drawRandomDeck(chanceDeck, usedChanceDeck, origin: DeckOrigin.chance);

  Card drawCommunityDeck() => drawRandomDeck(
        communityChestDeck,
        usedCommunityChestDeck,
        origin: DeckOrigin.communityChest,
      );

  /// Applies a drawn card's effect.
  void handleDeck(Card card) {
    final player = players[currentPlayerIndex];
    switch (card.type) {
      case CardType.moveTo:
        if (card.targetTileIndex != null) {
          _teleport(player, card.targetTileIndex!, awardGoIfWrapped: true);
        } else if (card.steps != null) {
          // "Go Back N" — no GO pass per official rules.
          final newPos = (player.position + card.steps!) % board.length;
          player.position = newPos < 0 ? newPos + board.length : newPos;
          handleLanding(player);
        } else {
          notifyGameEvents("CardSkipped", data: {
            "player": player.name,
            "card": card.description,
          });
        }
        break;
      case CardType.advanceToNearestUtility:
        _advanceToNearest(player, PropertyType.utility);
        break;
      case CardType.advanceToNearestRailroad:
        _advanceToNearest(player, PropertyType.railroad);
        break;
      default:
        card.applyEffect(player, this);
    }
  }

  void _advanceToNearest(Player player, PropertyType target) {
    final start = player.position;
    int? foundIndex;
    for (var i = 1; i <= board.length; i++) {
      final idx = (start + i) % board.length;
      final p = board[idx].property;
      if (p != null && p.type == target) {
        foundIndex = idx;
        break;
      }
    }
    if (foundIndex != null) {
      _teleport(player, foundIndex, awardGoIfWrapped: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Payments + bankruptcy
  // ─────────────────────────────────────────────────────────────────────

  /// Canonical rent payment path. On success: transfers cash + emits event.
  /// On insufficient funds: declares the tenant bankrupt to the owner.
  void payRent(
    Player tenant,
    Player owner,
    int rent, {
    Property? property,
  }) {
    final outcome = _chargePlayer(tenant, rent, creditor: owner);
    if (outcome == PayOutcome.paid) {
      owner.receive(rent);
    }
    notifyGameEvents("RentPaid", data: {
      "tenant": tenant.name,
      "owner": owner.name,
      "amount": rent,
      "property": property?.name,
      "bankrupt": outcome == PayOutcome.bankrupted,
    });
  }

  /// Charges `player` for `amount`. If they can't pay, triggers bankruptcy
  /// (to `creditor` if given, else to the bank). Returns the outcome.
  PayOutcome _chargePlayer(Player player, int amount, {Player? creditor}) {
    if (player.canAfford(amount)) {
      player.pay(amount);
      return PayOutcome.paid;
    }
    // Bankruptcy: creditor gets everything the player has (cash + props).
    if (creditor != null) {
      _bankruptToCreditor(player, creditor);
    } else {
      _bankruptToBank(player);
    }
    return PayOutcome.bankrupted;
  }

  void _bankruptToCreditor(Player debtor, Player creditor) {
    // Cash
    if (debtor.balance > 0) {
      creditor.receive(debtor.balance);
      debtor.balance = 0;
    }
    // GOOJF cards
    creditor.goojfCards.addAll(debtor.goojfCards);
    debtor.goojfCards.clear();
    // Properties (including mortgaged — new owner can unmortgage or pay 10% fee)
    for (final p in List<Property>.from(debtor.ownedProperties)) {
      p.owner = creditor;
      creditor.ownedProperties.add(p);
      if (p.isMortgaged) {
        // Apply 10% transfer fee to the creditor (from their just-received cash).
        _chargePlayer(creditor, p.mortgageTransferFee, creditor: null);
      }
    }
    debtor.ownedProperties.clear();
    debtor.isBankrupt = true;
    notifyGameEvents("PlayerBankrupt", data: {
      "player": debtor.name,
      "creditor": creditor.name,
    });
    checkGameEnd();
  }

  void _bankruptToBank(Player debtor) {
    debtor.balance = 0;
    debtor.goojfCards.clear();
    // Sell all houses/hotels back to the bank at half price (refund to... no one,
    // since debtor is bankrupt — this is purely to return supply to the bank).
    final propertiesToAuction = List<Property>.from(debtor.ownedProperties);
    for (final p in propertiesToAuction) {
      while (p.hasHotel || p.houses > 0) {
        p.downgrade(bank);
      }
      p.owner = null;
      p.isMortgaged = false;
    }
    debtor.ownedProperties.clear();
    debtor.isBankrupt = true;
    notifyGameEvents("PlayerBankrupt", data: {
      "player": debtor.name,
      "creditor": null,
    });
    // Auction recovered properties one by one.
    for (final p in propertiesToAuction) {
      auctionProperty(p);
    }
    checkGameEnd();
  }

  /// Public helper: force a bankruptcy resolution (used by UI when a player
  /// chooses to concede rather than liquidate).
  void handleBankruptcy(Player player, {Player? creditor}) {
    if (creditor != null) {
      _bankruptToCreditor(player, creditor);
    } else {
      _bankruptToBank(player);
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Win condition
  // ─────────────────────────────────────────────────────────────────────

  void checkGameEnd() {
    final active = players.where((p) => !p.isBankrupt).toList();
    if (active.length == 1 && status == GameStatus.active) {
      notifyGameEvents("GameWon", data: {"winner": active.first.name});
      endGame();
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Misc
  // ─────────────────────────────────────────────────────────────────────

  void notifyGameEvents(String event, {Map<String, dynamic>? data}) {
    gameListener?.call(event, data);
  }

  void shuffleDeck(List<Card> deck) => deck.shuffle();

  /// Pauses (persistence deferred; see BUILD_ROADMAP.md Phase 7).
  void pauseGame() {
    if (status != GameStatus.active) {
      throw Exception("Game is not active and cannot be paused");
    }
    status = GameStatus.pending;
  }

  /// Resumes (persistence deferred; see BUILD_ROADMAP.md Phase 7).
  Future<void> resumeGame() async {
    if (status == GameStatus.pending) {
      throw Exception("No saved game state to resume");
    }
  }

  void resetGame() {
    for (final p in players) {
      p.position = 0;
      p.balance = config.startingBalance;
      p.inJail = false;
      p.jailTurns = 0;
      p.consecutiveDoubles = 0;
      p.goojfCards.clear();
      p.ownedProperties.clear();
      p.isBankrupt = false;
    }
    for (final t in board) {
      final prop = t.property;
      if (prop != null) {
        prop.owner = null;
        prop.isMortgaged = false;
        prop.houses = 0;
        prop.hasHotel = false;
      }
    }
    bank.availableHouses = config.initialHouses;
    bank.availableHotels = config.initialHotels;
    bank.freeParkingPot = 0;
    chanceDeck.clear();
    usedChanceDeck.clear();
    communityChestDeck.clear();
    usedCommunityChestDeck.clear();
    activeTrades.clear();
    turnNumber = 0;
    currentPlayerIndex = 0;
    status = GameStatus.pending;
  }

  void validateLoadedState() {
    if (players.isEmpty ||
        board.isEmpty ||
        bank.availableHouses < 0 ||
        bank.availableHotels < 0) {
      throw Exception("Loaded game state is inconsistent or incomplete");
    }
  }
}
