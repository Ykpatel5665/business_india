import 'package:flutter/foundation.dart';

import '../../game_logic/engine/editions/board_india.dart';
import '../../game_logic/engine/game_engine.dart';
import '../../game_logic/engine/game_factory.dart';
import '../../game_logic/models/card.dart';
import '../../game_logic/models/enums.dart';
import '../../game_logic/models/player.dart';
import '../../game_logic/models/property.dart';
import '../../game_logic/models/trade.dart';
import 'sound_manager.dart';

/// A seat on the setup screen.
class PlayerSlot {
  String name;
  int colorIndex;
  int avatarIndex;
  bool isBot;
  PlayerSlot({
    required this.name,
    required this.colorIndex,
    required this.avatarIndex,
    this.isBot = false,
  });
}

class GameLogEntry {
  final String message;
  final DateTime at;
  GameLogEntry(this.message) : at = DateTime.now();
}

/// Full turn-phase state machine for the UI.
enum TurnPhase {
  idle,               // current player's turn started — awaiting roll
  jailChoice,         // current player in jail; pre-roll decision
  rolling,            // dice animation in progress
  moving,             // token stepping along tiles
  landedBuy,          // landed on unowned property — buy / auction
  auction,            // auction modal in progress
  rentDue,            // rent auto-resolving; brief notice
  cardDrawn,          // Chance / Community Chest reveal
  taxNotice,          // tax deduction notice
  goToJailNotice,     // landed on GoToJail — brief dramatic slide
  postMove,           // landing resolved; may roll again or end turn
  gameOver,
}

class GameController extends ChangeNotifier {
  GameEngine? _engine;
  TurnPhase _phase = TurnPhase.idle;

  final List<GameLogEntry> _log = [];
  final List<int> _colorIndexByToken = [];
  final List<int> _avatarIndexByToken = [];
  final List<bool> _isBotByToken = [];

  int lastDice1 = 0;
  int lastDice2 = 0;

  // Pending transient state shown by the UI.
  Property? pendingProperty;
  Card? pendingCard;
  DeckOrigin? pendingCardOrigin;
  String? toastMessage;
  int? toastAmount;      // positive = gain, negative = loss
  Player? toastPlayer;

  // Active auction state
  AuctionSession? auction;

  // Stored move result for doubles tracking across async UI interactions.
  MoveResult? _pendingMoveResult;

  // ─── Getters ───
  GameEngine get engine {
    final e = _engine;
    if (e == null) {
      throw StateError('GameController.engine accessed before startGame()');
    }
    return e;
  }

  bool get isReady => _engine != null;
  TurnPhase get phase => _phase;
  List<GameLogEntry> get log => List.unmodifiable(_log);

  Player get currentPlayer => engine.players[engine.currentPlayerIndex];
  int colorIndexFor(Player p) => _colorIndexByToken[p.tokenId - 1];
  int avatarIndexFor(Player p) => _avatarIndexByToken[p.tokenId - 1];
  bool isBot(Player p) => _isBotByToken[p.tokenId - 1];

  // ─── Lifecycle ───

  void startGame(List<PlayerSlot> slots) {
    _colorIndexByToken
      ..clear()
      ..addAll(slots.map((s) => s.colorIndex));
    _avatarIndexByToken
      ..clear()
      ..addAll(slots.map((s) => s.avatarIndex));
    _isBotByToken
      ..clear()
      ..addAll(slots.map((s) => s.isBot));

    final players = [
      for (var i = 0; i < slots.length; i++)
        Player(
          name: slots[i].name.trim().isEmpty
              ? 'Player ${i + 1}'
              : slots[i].name.trim(),
          tokenId: i + 1,
          balance: indiaDefaultConfig.startingBalance,
        ),
    ];

    _engine = MonopolyGameEngineBuilder(
      players: players,
      config: indiaDefaultConfig,
    ).create('india');

    _engine!.gameListener = _onEngineEvent;
    _engine!.status = GameStatus.active;
    _log
      ..clear()
      ..add(GameLogEntry('Game started • ${players.length} players'));

    _resetPendingState();
    _phase = currentPlayer.inJail ? TurnPhase.jailChoice : TurnPhase.idle;
    notifyListeners();
  }

  void resetToMenu() {
    _engine?.gameListener = null;
    _engine = null;
    _resetPendingState();
    _phase = TurnPhase.idle;
    _log.clear();
    notifyListeners();
  }

  void storeMoveResult(MoveResult result) {
    _pendingMoveResult = result;
  }

  void _resolvePostAction() {
    final result = _pendingMoveResult;
    _pendingMoveResult = null;
    if (_phase == TurnPhase.gameOver) return;
    if (currentPlayer.isBankrupt) {
      endTurn();
      return;
    }
    if (result != null && result.shouldRollAgain && !currentPlayer.inJail) {
      _phase = TurnPhase.idle;
    } else {
      _phase = TurnPhase.postMove;
    }
    _clearToast();
    notifyListeners();
  }

  void _resetPendingState() {
    pendingProperty = null;
    pendingCard = null;
    pendingCardOrigin = null;
    toastMessage = null;
    toastAmount = null;
    toastPlayer = null;
    auction = null;
    _pendingMoveResult = null;
  }

  // ─── Roll & move ───

  Future<void> rollDice() async {
    if (_engine == null) return;
    if (_phase != TurnPhase.idle && _phase != TurnPhase.jailChoice) return;

    SoundManager.instance.dice();
    _phase = TurnPhase.rolling;
    notifyListeners();

    // Roll immediately (engine settles state), then animate
    final roll = engine.rollDice();
    lastDice1 = roll[0];
    lastDice2 = roll[1];

    // Let dice tumble before resolving movement
    await Future.delayed(const Duration(milliseconds: 1300));

    final before = currentPlayer.position;
    final wasInJail = currentPlayer.inJail;
    final result = engine.movePlayer(roll[0], roll[1]);
    _pendingMoveResult = result;

    _log.add(GameLogEntry(
        '${currentPlayer.name} rolled ${roll[0]} + ${roll[1]} = ${roll[0] + roll[1]}'));

    // Transition to moving phase
    if (currentPlayer.position != before) {
      _phase = TurnPhase.moving;
      notifyListeners();
      // The token widget will animate. Give it time.
      final steps = (currentPlayer.position - before + 40) % 40;
      await Future.delayed(Duration(milliseconds: 220 * steps));
    }

    if (currentPlayer.inJail && !wasInJail) {
      _phase = TurnPhase.goToJailNotice;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 900));
    }

    // Resolve what we landed on
    await _resolveLanding(result);
  }

  Future<void> _resolveLanding(MoveResult moveResult) async {
    final tile = engine.board[currentPlayer.position];
    switch (tile.type) {
      case TileType.property:
        final p = tile.property!;
        if (p.owner == null) {
          pendingProperty = p;
          _phase = TurnPhase.landedBuy;
          notifyListeners();
        } else if (p.owner != currentPlayer && !p.owner!.isBankrupt) {
          // rent already charged by engine; show a transient notice
          _phase = TurnPhase.rentDue;
          final rent = p.calculateRent(
              engine.isMonopoly(p), lastDice1, lastDice2);
          toastMessage = '${currentPlayer.name} paid ₹$rent rent to ${p.owner!.name}';
          toastAmount = -rent;
          toastPlayer = currentPlayer;
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 1200));
          _afterLanding(moveResult);
        } else {
          _afterLanding(moveResult);
        }
        break;
      case TileType.chance:
        pendingCard = engine.drawChanceDeck();
        pendingCardOrigin = DeckOrigin.chance;
        _phase = TurnPhase.cardDrawn;
        notifyListeners();
        break;
      case TileType.communityChest:
        pendingCard = engine.drawCommunityDeck();
        pendingCardOrigin = DeckOrigin.communityChest;
        _phase = TurnPhase.cardDrawn;
        notifyListeners();
        break;
      case TileType.tax:
        final taxTile = engine.board[currentPlayer.position];
        final taxAmt = taxTile.taxAmount ?? engine.config.taxAmount;
        _phase = TurnPhase.taxNotice;
        toastMessage = '${currentPlayer.name} paid ₹$taxAmt tax';
        toastAmount = -taxAmt;
        toastPlayer = currentPlayer;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 1200));
        _afterLanding(moveResult);
        break;
      case TileType.goToJail:
      case TileType.jail:
      case TileType.freeParking:
      case TileType.go:
        _afterLanding(moveResult);
        break;
    }
  }

  void _afterLanding([MoveResult? _]) {
    _resolvePostAction();
  }

  void _clearToast() {
    toastMessage = null;
    toastAmount = null;
    toastPlayer = null;
  }

  // ─── Property purchase ───

  void buyPendingProperty() {
    final p = pendingProperty;
    if (p == null) return;
    final ok = engine.buyProperty();
    if (!ok) {
      _startAuction(p);
      return;
    }
    SoundManager.instance.play(GameSound.buyProperty);
    pendingProperty = null;
    _resolvePostAction();
  }

  void declineAndAuction() {
    final p = pendingProperty;
    if (p == null) return;
    _startAuction(p);
  }

  void _startAuction(Property p) {
    pendingProperty = null;
    auction = AuctionSession(
      property: p,
      participants: engine.players.where((pl) => !pl.isBankrupt).toList(),
    );
    _phase = TurnPhase.auction;
    notifyListeners();
  }

  void placeBid(int amount) {
    final a = auction;
    if (a == null) return;
    final bidder = a.current;
    if (bidder.balance < amount) return;
    if (amount <= a.highestBid) return;
    a.highestBid = amount;
    a.highestBidder = bidder;
    a.passesThisRound = 0;
    a.advance();
    notifyListeners();
  }

  void passBid() {
    final a = auction;
    if (a == null) return;
    a.pass();
    if (a.resolved) _resolveAuction();
    notifyListeners();
  }

  void _resolveAuction() {
    final a = auction!;
    if (a.highestBidder != null && a.highestBid > 0) {
      a.highestBidder!.buyProperty(a.property, a.highestBid);
      _log.add(GameLogEntry(
          '${a.highestBidder!.name} won auction for ${a.property.name} at ₹${a.highestBid}'));
      SoundManager.instance.play(GameSound.auctionBid);
    } else {
      _log.add(GameLogEntry('${a.property.name}: no bids'));
    }
    auction = null;
    _resolvePostAction();
  }

  // ─── Cards ───

  void acknowledgeCard() {
    if (pendingCard == null) return;
    final before = currentPlayer.position;
    engine.handleDeck(pendingCard!);
    SoundManager.instance.play(GameSound.cardFlip);
    _log.add(GameLogEntry(
        '${currentPlayer.name}: ${pendingCard!.description}'));
    pendingCard = null;
    pendingCardOrigin = null;

    // A card may have teleported / re-landed the player
    if (currentPlayer.position != before) {
      _phase = TurnPhase.moving;
      notifyListeners();
      Future.delayed(
        Duration(milliseconds: 220 * ((currentPlayer.position - before + 40) % 40)),
        () => _resolveLanding(MoveResult(shouldRollAgain: false, sentToJail: false)),
      );
      return;
    }
    // Card didn't move us (e.g. pay/receive)
    if (currentPlayer.inJail) {
      _pendingMoveResult = null; // No doubles after going to jail.
      _phase = TurnPhase.goToJailNotice;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 900), () {
        _phase = TurnPhase.postMove;
        notifyListeners();
      });
    } else {
      _resolvePostAction();
    }
  }

  // ─── Jail ───

  void payToLeaveJail() {
    engine.payToLeaveJail(currentPlayer);
    _log.add(GameLogEntry('${currentPlayer.name} paid ₹50,000 bail'));
    _phase = TurnPhase.idle;
    notifyListeners();
  }

  void useGoojfToLeaveJail() {
    engine.useGoojfToLeaveJail(currentPlayer);
    _log.add(GameLogEntry(
        '${currentPlayer.name} used a Get-Out-of-Jail-Free card'));
    _phase = TurnPhase.idle;
    notifyListeners();
  }

  // ─── End turn ───

  void endTurn() {
    if (_engine == null) return;
    if (_phase == TurnPhase.gameOver) return;
    engine.nextTurn();
    _clearToast();
    _phase = currentPlayer.inJail ? TurnPhase.jailChoice : TurnPhase.idle;
    notifyListeners();
  }

  // ─── Property management ───

  bool tryBuildHouse(Property property) {
    if (!engine.canUpgradeProperty(property, currentPlayer)) return false;
    engine.upgradeProperty(property, currentPlayer, enforceGroupRules: true);
    SoundManager.instance.play(GameSound.buildHouse);
    _log.add(GameLogEntry('${currentPlayer.name} built on ${property.name}'));
    notifyListeners();
    return true;
  }

  bool trySellHouse(Property property) {
    if (!engine.canDowngradeProperty(property, currentPlayer)) return false;
    engine.downgradeProperty(property, currentPlayer);
    _log.add(GameLogEntry(
        '${currentPlayer.name} sold improvement on ${property.name}'));
    notifyListeners();
    return true;
  }

  bool tryMortgage(Property property) {
    if (!currentPlayer.canMortgageProperty(property)) return false;
    currentPlayer.mortgageProperty(property);
    SoundManager.instance.play(GameSound.mortgage);
    _log.add(GameLogEntry(
        '${currentPlayer.name} mortgaged ${property.name} (+₹${property.mortgageValue})'));
    notifyListeners();
    return true;
  }

  bool tryUnmortgage(Property property) {
    if (!currentPlayer.canUnmortgageProperty(property)) return false;
    currentPlayer.unmortgageProperty(property);
    _log.add(GameLogEntry(
        '${currentPlayer.name} unmortgaged ${property.name} (-₹${property.unmortgageValue})'));
    notifyListeners();
    return true;
  }

  // ─── Trading ───

  bool executeTrade({
    required Player partner,
    required List<Property> offeredProperties,
    required List<Property> requestedProperties,
    required int offeredCash,
    required int requestedCash,
  }) {
    final trade = Trade(
      fromPlayer: currentPlayer,
      toPlayer: partner,
      offeredProperties: offeredProperties,
      requestedProperties: requestedProperties,
      offeredCash: offeredCash,
      requestedCash: requestedCash,
    );
    if (!trade.isValid()) return false;
    try {
      engine.processTrade(trade);
    } catch (_) {
      return false;
    }
    _log.add(GameLogEntry(
        '${currentPlayer.name} traded with ${partner.name}'));
    notifyListeners();
    return true;
  }

  // ─── Engine event subscription ───

  void _onEngineEvent(String event, Map<String, dynamic>? data) {
    switch (event) {
      case 'PassedGo':
        _log.add(GameLogEntry('${data?["player"]} passed GO (+₹2,00,000)'));
        SoundManager.instance.play(GameSound.passGo);
        break;
      case 'PlayerSentToJail':
        _log.add(GameLogEntry('${data?["player"]} sent to Jail'));
        SoundManager.instance.play(GameSound.jail);
        break;
      case 'PlayerExitedJail':
        _log.add(GameLogEntry('${data?["player"]} left Jail'));
        break;
      case 'RentPaid':
        SoundManager.instance.play(GameSound.rentPaid);
        break;
      case 'PropertyBought':
        _log.add(GameLogEntry(
            '${data?["player"]} bought ${data?["property"]} for ₹${data?["price"]}'));
        break;
      case 'TaxPaid':
        _log.add(GameLogEntry(
            '${data?["player"]} paid ₹${data?["amount"]} tax'));
        break;
      case 'PlayerBankrupt':
        _log.add(GameLogEntry(
            '${data?["player"]} went bankrupt${data?["creditor"] != null ? " to ${data?["creditor"]}" : ""}'));
        SoundManager.instance.play(GameSound.bankrupt);
        break;
      case 'GameWon':
        _log.add(GameLogEntry('${data?["winner"]} wins!'));
        SoundManager.instance.play(GameSound.win);
        _phase = TurnPhase.gameOver;
        break;
    }
  }
}

/// Tracks an in-progress auction.
class AuctionSession {
  final Property property;
  final List<Player> participants;
  int currentIndex = 0;
  int highestBid = 0;
  Player? highestBidder;
  int passesThisRound = 0;
  bool resolved = false;

  AuctionSession({required this.property, required this.participants});

  Player get current => participants[currentIndex];

  void advance() {
    currentIndex = (currentIndex + 1) % participants.length;
  }

  void pass() {
    passesThisRound++;
    advance();
    // Everyone passed since last raise → resolved
    if (passesThisRound >= participants.length) {
      resolved = true;
    }
  }
}
