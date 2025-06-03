# Monopoly Game Logic & Architecture Guide

This document outlines the complete backend logic, architecture, and persistence requirements for a Monopoly game implemented in Dart (for Flutter), with a strict separation between UI and game logic. Use this as a reference for all business logic, rules, and data structures.

---

## 1. Project Structure

- All game logic is in `lib/game_logic/` (or `lib/monopoly_logic/`)
- Subfolders:
  - `models/` — Data classes, enums, and business logic
  - `engine/` — Game engine, turn management, event system
  - `persistence/` — Hive adapters, save/load logic
  - `utils/` — Helper functions
- No UI code in this layer. UI interacts via public APIs and event callbacks.

---

## 2. Enums

- `GameStatus`: `pending`, `active`, `completed`
- `TileType`: `property`, `tax`, `jail`, `chance`, `community`, `go`, `freeParking`, `goToJail`
- `PropertyType`: `street`, `railroad`, `utility`
- `CardType`: `chance`, `communityChest`
- `TradeStatus`: `pending`, `accepted`, `rejected`, `cancelled`

---

## 3. Data Models & Business Logic

### Player
- Fields: `name`, `tokenId`, `position`, `balance`, `inJail`, `jailTurns`, `getOutOfJailCards`, `ownedProperties`, `isBankrupt`
- Methods: `move`, `pay`, `receive`, `buyProperty`, `payRent`, `mortgageProperty`, `unmortgageProperty`, `upgradeProperty`, `declareBankruptcy`, `trade`

### Property
- Rent calculation (monopoly bonus, houses/hotels)
- Mortgage/unmortgage
- House/hotel upgrades (even building, bank limits)
- Ownership tracking

### BoardTile
- Represents board position, tile type, property, and labels

### Bank
- Manages house/hotel inventory
- Methods to give/take houses/hotels

### Card
- Chance/Community Chest, with effect functions
- Deck reshuffling after depletion

### Trade
- Tracks offers, properties/cash, status

### GameSettings
- Configurable: starting balance, auctions, bank resources, jail rules, Free Parking, custom boards, auction rules

---

## 4. Game Engine

- Fields: players, board, bank, decks, current player, turn, status, settings, trades
- Methods:
  - `startGame`, `endGame`, `nextTurn`, `rollDiceAndMove`, `handleLanding`, `applyCardEffect`, `checkBankruptcy`, `resetGame`, `startAuction`, `processTrade`, `notifyGameEvents`

---

## 5. Gameplay Logic

- Dice rolling, doubles, jail logic
- Property buying/auction fallback
- Rent payment (monopoly, houses/hotels)
- House/hotel building (even building, bank limits)
- Jail rules (pay, roll, cards)
- Bankruptcy (asset liquidation, player removal)
- Game end (last solvent player wins)
- Card decks (reshuffle after depletion)
- Free Parking (optional rules)
- Player tokens (unique)
- Trades (cash/property, offer lifecycle)
- Multiple board layouts (configurable)
- Full serialization/deserialization for save/load

---

## 6. Persistence (Hive)

- Hive adapters for all models
- Save/load entire game state atomically
- Integrate save/load in engine lifecycle (after each turn, trade, auction, move, purchase)
- All fields needed to resume game are serialized
- Only Hive and Dart core libs (no network)

---

## 7. Usage Examples

- Initialize engine with settings/board
- Add players
- Start game
- Roll dice/process turns
- Buy/build
- Trades/auctions
- Subscribe to events
- Save/load state

---

## 8. Coding Style & Best Practices

- Dart null safety, strong typing
- Modular, clear separation of concerns
- In-code comments for rules/logic
- No UI dependencies
- Error handling/validation
- Scalable, maintainable

---

## 9. Additional Notes

- Event/notification system for UI
- Save/load for pausing/resuming
- Support for different board configs
- Comments on jail, auctions, trades, Free Parking, deck reshuffling, persistence

---

_Refer to this document as the single source of truth for Monopoly game logic and architecture in this project._
