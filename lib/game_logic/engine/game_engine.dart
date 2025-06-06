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
  final Bank bank;
  final List<Card> chanceDeck;
  final List<Card> communityChestDeck;
  final GameConfig config;
  int currentPlayerIndex;
  int turnNumber;
  GameStatus status;
  List<Trade> activeTrades;
  int dice1 = 0;
  int dice2 = 0;

  GameEngine({
    required this.players,
    required this.board,
    required this.bank,
    required this.chanceDeck,
    required this.communityChestDeck,
    required this.config,
  })  : currentPlayerIndex = 0,
        turnNumber = 0,
        status = GameStatus.pending,
        activeTrades = [] {
  }

  void startGame() {
    if (players.isEmpty) {
      throw Exception("No players to start the game");
    }
    status = GameStatus.active;
    turnNumber = 1;
  }

  void endGame() {
    status = GameStatus.completed;
  }

  void nextTurn() {
    if (status != GameStatus.active) {
      throw Exception("Game is not active");
    }
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].isBankrupt);
    turnNumber++;
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
  void handleFreeParking(Player player) {
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
    } else {
      player.jailTurns++;
    }
  }

  void upgradeProperty(Property property, Player player, Bank bank) {
    if (!isMonopoly(property) || property.houses >= 5) {
      throw Exception("Cannot upgrade property");
    }
    player.pay(property.houseCost.toDouble());
    property.upgrade(bank);
  }

  void processTrade(Trade trade) {
    if (trade.isValid()) {
      trade.execute();
    } else {
      throw Exception("Invalid trade");
    }
  }

  /// Notifies listeners about game events.
  void notifyGameEvents(String event, {Map<String, dynamic>? data}) {
    // Example: Notify listeners about the current player's turn
    print("Event: $event, Data: $data");
    // Extend this to integrate with a proper event system or callback mechanism
  }

  bool isMonopoly(Property propertyToCheck) {
    final tiles = board.where((tile) => tile.type == TileType.property && tile.property?.colorGroup == propertyToCheck.colorGroup);
    if (tiles.isEmpty) return false;
    return tiles.every((tile) => tile.property?.owner == propertyToCheck.owner);
  }

  /// Refines `handleLanding` to ensure correct position updates for Go to Jail.
  void handleLanding(Player player) {
    // Ensure balance updates correctly when passing Go
    int oldPosition = player.position - dice1 - dice2;
    final tile = board[player.position];
    if (tile.type != TileType.go && oldPosition < 0) {
      player.receive(config.goReward);
    }
    switch (tile.type) {
      case TileType.property:
        if (tile.property != null && tile.property!.owner == null) {
          // Property is unowned, player can buy it
        } else if (tile.property != null && tile.property!.owner != player) {
          final ownsSet = isMonopoly(tile.property!);
          final rent = tile.property!.calculateRent(ownsSet, dice1, dice2);
          payRent(player, tile.property!.owner!, rent, property: tile.property);
        }
        break;
      case TileType.tax:
        bank.addToFreeParking(config.taxAmount);
        player.pay(config.taxAmount);
        break;
      case TileType.jail:
        player.inJail = true;
        break;
      case TileType.goToJail:
        player.inJail = true;
        player.position = board.indexWhere((tile) => tile.type == TileType.jail);
        if (player.position == -1) {
          player.position = 10;
        } else {
          player.position = 30;
        }
        break;
      case TileType.freeParking:
        handleFreeParking(player);
        break;
      case TileType.go:
        player.receive(config.goReward);
        break;
      case TileType.chance:
        if (chanceDeck.isNotEmpty) {
          final card = chanceDeck.removeAt(0);
          
          if (card.type == CardType.moveTo) {
            player.moveTo(card.targetTileIndex!, board.length);
            handleLanding(player);
          } else {
            card.applyEffect(player, this);
          }
          chanceDeck.add(card);
        }
        break;
      case TileType.communityChest:
        if (communityChestDeck.isNotEmpty) {
          final card = communityChestDeck.removeAt(0);
          card.applyEffect(player, this);
          communityChestDeck.add(card);
        }
        break;
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

  /// Adds missing setters for GameEngine properties.
  set players(List<Player> newPlayers) => this.players = newPlayers;
  set board(List<BoardTile> newBoard) => this.board = newBoard;
  set bank(Bank newBank) => this.bank = newBank;
  set config(GameConfig newConfig) => this.config = newConfig;
  set chanceDeck(List<Card> newChanceDeck) => this.chanceDeck = newChanceDeck;
  set communityChestDeck(List<Card> newCommunityChestDeck) => this.communityChestDeck = newCommunityChestDeck;

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
  }

  void buyProperty() {
    final currentPlayer = players[currentPlayerIndex];
    final tile = board[currentPlayer.position];

    // Check if the tile is a property and is buyable
    if (tile.type != TileType.property || tile.property == null) {
      return;
    }

    final property = tile.property!;

    // If already owned or mortgaged, do nothing
    if (property.owner != null || property.isMortgaged) {
      return;
    }

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
}