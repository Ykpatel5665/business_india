import 'dart:math';

import '../models/player.dart';
import '../models/property.dart';
import '../models/board_tile.dart';
import '../models/bank.dart';
import '../models/card.dart';
import '../models/trade.dart';
import '../models/game_config.dart';
import '../models/enums.dart';
import '../models/game_config.dart';
import '../persistence/hive_persistence.dart';

/// Represents the core game engine for the Monopoly game.
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

  GameEngine({
    required this.players,
    required this.board,
    required this.chanceDeck,
    required this.communityChestDeck,
    required this.config,
  }) : bank = Bank(availableHouses: config.initialHouses, availableHotels: config.initialHotels) {}

  void startGame() {
    if (players.isEmpty) {
      throw Exception("No players to start the game");
    }
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
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].isBankrupt);
    turnNumber++;
    checkGameEnd();
  }

  /// Rolls two dice and returns their values.
  List<int> rollDice() {
    final random = Random();
    final dice1 = random.nextInt(6) + 1;
    final dice2 = random.nextInt(6) + 1;
    return [dice1, dice2];
  }

  /// Refines `rollDiceWithRules` to ensure correct balance updates.
  List<int> rollDiceWithRules() {
    final dice = rollDice();
    final currentPlayer = players[currentPlayerIndex];

    movePlayer(dice[0], dice[1]);
    return dice;
  }

  void startAuction(Property property) {
    if (property.owner != null) {
      throw Exception("Property is already owned and cannot be auctioned");
    }

    // Auction logic: Players bid for the property
    int highestBid = 0;
    Player? highestBidder;

    for (var player in players) {
      if (player.isBankrupt) continue;

      // Simulate a bid (replace with actual bidding logic if needed)
      int bid = player.decideBid(property, highestBid);
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
        "bid": highestBid
      });
    }
  }

  /// Starts an auction for a property with bidding logic.
  void startAuctionWithBidding(Property property) {
    if (property.owner != null) {
      throw Exception("Property is already owned and cannot be auctioned");
    }

    int highestBid = 0;
    Player? highestBidder;
    final activePlayers = players.where((player) => !player.isBankrupt).toList();

    while (activePlayers.isNotEmpty) {
      for (var player in activePlayers) {
        final bid = player.decideBid(property, highestBid);
        if (bid > highestBid) {
          highestBid = bid;
          highestBidder = player;
        }
      }

      if (highestBidder != null) {
        highestBidder.buyProperty(property, highestBid);
        break;
      }
    }
  }

  /// Fixes type mismatches and method calls.
  void _handleFreeParking(Player player) {
    if (config.freeParkingCollects) {
      final collectedFunds = bank.collectFreeParkingFunds().toDouble();
      player.receive(collectedFunds);
      notifyGameEvents("FreeParking", data: {"player": player.name, "funds": collectedFunds});
    }
  }

  /// Fixes the `payRent` method call and adds `handleJailExit`.
  void handleJailExit(Player player) {
    if (player.jailTurns >= config.maxJailTurns - 1 || player.getOutOfJailCards > 0) {
      if (player.getOutOfJailCards > 0) {
        player.getOutOfJailCards--;
      } else {
        player.pay(config.jailExitCost);
      }
      player.inJail = false;
      player.jailTurns = 0;
      notifyGameEvents("PlayerExitedJail", data: {"player": player.name});
    } else {
      player.jailTurns++;
    }
  }

  void upgradeProperty(Property property, Player player) {
    player.upgradeProperty(property, bank);
  }

  void processTrade(Trade trade) {
    if (trade.isValid()) {
      trade.execute();
      notifyGameEvents("TradeExecuted", data: {
        "from": trade.fromPlayer.name,
        "to": trade.toPlayer.name,
        "offeredCash": trade.offeredCash,
        "requestedCash": trade.requestedCash,
        "offeredProperties": trade.offeredProperties.map((p) => p.name).toList(),
        "requestedProperties": trade.requestedProperties.map((p) => p.name).toList(),
      });
    } else {
      throw Exception("Invalid trade");
    }
  }

  /// Notifies listeners about game events.
  void notifyGameEvents(String event, {Map<String, dynamic>? data}) {
    // Example: Notify listeners about the current player's turn
    print("Event: $event, Data: $data");
    // Forward to UI if available
    if (gameListener != null) {
      gameListener!(event, data);
    }
  }

  // Add a listener for UI notifications
  void Function(String event, Map<String, dynamic>? data)? gameListener;

  bool isMonopoly(Property propertyToCheck) {
    final tiles = board.where((tile) => tile.type == TileType.property && tile.property?.colorGroup == propertyToCheck.colorGroup);
    if (tiles.isEmpty) return false;
    return tiles.every((tile) => tile.property?.owner == propertyToCheck.owner);
  }

  /// Handles the landing logic for a player.
  void handleLanding(Player player) {
    int oldPosition = player.position - dice1 - dice2;
    final tile = board[player.position];
    if (tile.type != TileType.go && oldPosition < 0) {
      player.receive(config.goReward);
      notifyGameEvents("PassedGo", data: {"player": player.name});
    }
    switch (tile.type) {
      case TileType.property:
        _handlePropertyLanding(player, tile);
        break;
      case TileType.tax:
        _handleTaxLanding(player);
        break;
      case TileType.jail:
        _handleJailLanding(player);
        break;
      case TileType.goToJail:
        sendToJail(player);
        break;
      case TileType.freeParking:
        _handleFreeParking(player);
        break;
      case TileType.go:
        player.receive(config.goReward);
        notifyGameEvents("LandedOnGo", data: {"player": player.name});
        break;
      case TileType.chance:
      case TileType.communityChest:
        break;
    }
  }

  bool canBuyProperty() {
    final player = players[currentPlayerIndex];
    final tile = board[player.position];
    if (!tile.isPropertyTile) return false;
    final property = tile.property!;
    // Use player and property utility methods
    return !property.isOwned();
  }

  void _handlePropertyLanding(Player player, BoardTile tile) {
    if (!tile.isPropertyTile) return;
    final property = tile.property!;
    if (property.owner == null) {
      // Property is unowned, player can buy it
    } else if (property.owner != player) {
      final monopoly = isMonopoly(property);
      final rent = property.calculateRent(monopoly, dice1, dice2);
      payRent(player, property.owner!, rent, property: property);
    }
  }

  void _handleTaxLanding(Player player) {
    bank.addToFreeParking(config.taxAmount);
    player.pay(config.taxAmount);
  }

  void _handleJailLanding(Player player) {
    player.inJail = true;
    player.jailTurns = 0;
    notifyGameEvents("PlayerSentToJail", data: {"player": player.name});
  }
  
  void sendToJail(Player player) {
    player.position = board.indexWhere((tile) => tile.type == TileType.jail);
    _handleJailLanding(player);
  }

  /// Draws and returns a random card from the deck, moves it to the used pile, refills from used if deck is empty.
  Card drawRandomDeck(List<Card> deck, List<Card> used) {
    if (deck.isEmpty && used.isNotEmpty) {
      deck.addAll(used);
      used.clear();
    }
    if (deck.isEmpty) {
      throw Exception("No cards available to draw.");
    }
    final random = Random();
    final index = random.nextInt(deck.length);
    final card = deck.removeAt(index);
    used.add(card);
    return card;
  }

  Card drawChanceDeck() {
    return drawRandomDeck(chanceDeck, usedChanceDeck);
  }

  Card drawCommunityDeck() {
    return drawRandomDeck(communityChestDeck, usedCommunityChestDeck);
  }

  void handleDeck(Card card) {
    Player player = players[currentPlayerIndex];
    if (card.type == CardType.moveTo) {
      // TODO : Should acutal move
      if (card.targetTileIndex != null) {
        player.moveTo(card.targetTileIndex!, board.length);
      } else if (card.steps != null && card.steps! > 0) {
        player.move(card.steps!, board.length);
      } else {
        throw Exception("Invalid card: must specify target tile index or steps");
      }
      handleLanding(player);
    } else {
      card.applyEffect(player, this);
    }
  }

  /// Pauses the game by saving the current state.
  void pauseGame() {
    if (status != GameStatus.active) {
      throw Exception("Game is not active and cannot be paused");
    }
    HivePersistence().saveGameState(this);
    status = GameStatus.pending;
  }

  /// Resets the game to its initial state.
  void resetGame() {
    players.forEach((player) {
      player.position = 0;
      player.balance = config.startingBalance;
      player.inJail = false;
      player.jailTurns = 0;
      player.getOutOfJailCards = 0;
      player.ownedProperties.clear();
      player.isBankrupt = false;
    });
    board.forEach((tile) {
      if (tile.property != null) {
        tile.property!.owner = null;
        tile.property!.isMortgaged = false;
        tile.property!.houses = 0;
        tile.property!.hasHotel = false;
      }
    });
    bank.availableHouses = config.initialHouses;
    bank.availableHotels = config.initialHotels;
    chanceDeck.clear();
    communityChestDeck.clear();
    activeTrades.clear();
    turnNumber = 0;
    currentPlayerIndex = 0;
    status = GameStatus.pending;
  }

  /// Resumes the game from a saved state if available.
  Future<void> resumeGame() async {
    final persistence = HivePersistence();
    await persistence.loadGameState(this);
    if (status == GameStatus.pending) {
      throw Exception("No saved game state to resume");
    }
  }

  /// Validates the loaded game state to ensure consistency.
  void validateLoadedState() {
    if (players.isEmpty || board.isEmpty || bank.availableHouses < 0 || bank.availableHotels < 0) {
      throw Exception("Loaded game state is inconsistent or incomplete");
    }
  }

  /// Shuffles a deck of cards.
  void shuffleDeck(List<Card> deck) {
    deck.shuffle();
  }

  /// Removed duplicate method declarations.
  void movePlayer(int dice1, int dice2) {
    this.dice1 = dice1;
    this.dice2 = dice2;
    final steps = dice1 + dice2;
    final currentPlayer = players[currentPlayerIndex];

    if (currentPlayer.inJail) {
      // If doubles, release from jail immediately
      if (dice1 == dice2) {
        currentPlayer.inJail = false;
        currentPlayer.jailTurns = 0;
      } else {
        handleJailExit(currentPlayer);
        if (currentPlayer.inJail) {
          return; // Player remains in jail
        }
      }
    }

    final oldPosition = currentPlayer.position;
    currentPlayer.move(steps, board.length);

    handleLanding(currentPlayer);
  }

  void payRent(Player tenant, Player owner, double rent, {Property? property}) {
    tenant.pay(rent);
    owner.receive(rent);
    notifyGameEvents("RentPaid", data: {
      "tenant": tenant.name,
      "owner": owner.name,
      "amount": rent,
      "property": property?.name
    });
  }

  void buyProperty() {
    final currentPlayer = players[currentPlayerIndex];
    final tile = board[currentPlayer.position];
    if (!tile.isPropertyTile) return;
    final property = tile.property!;
    if (property.isOwned()) return;

    // If player can't afford, do nothing
    if (currentPlayer.balance < property.price) {
      return;
    }

    // Buy the property
    currentPlayer.buyProperty(property, property.price);
    notifyGameEvents("PropertyBought", data: {
      "player": currentPlayer.name,
      "property": property.name,
      "price": property.price,
    });
  }

  void checkGameEnd() {
    final activePlayers = players.where((p) => !p.isBankrupt).toList();
    if (activePlayers.length == 1 && status == GameStatus.active) {
      notifyGameEvents("GameWon", data: {"winner": activePlayers.first.name});
      endGame();
    }
  }

  // Add a helper to call after bankruptcy
  void handleBankruptcy(Player player) {
    player.declareBankruptcy();
    notifyGameEvents("PlayerBankrupt", data: {"player": player.name});
    checkGameEnd();
  }

  // Add a stub for buildProperty to resolve missing method errors
  void buildProperty(Property property, Player player) {
    // TODO: Implement property building logic
  }
}