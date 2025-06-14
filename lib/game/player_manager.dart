import '../game_logic/models/player.dart';
import '../game_logic/models/property.dart';
import '../game_logic/models/board_tile.dart';
import '../game_logic/models/tile_type.dart';
import 'monopoly_flame_game.dart';
import 'property_purchase_dialog.dart';
import 'build_dialog.dart';
import 'property_dialog.dart';
import 'card_dialog.dart';
import 'overlay_manager.dart';

class PlayerManager {
  final MonopolyFlameGame game;
  PlayerManager(this.game);

  Future<void> handleTurn(Player player, int d1, int d2) async {
    final oldTile = player.position;
    game.engine.movePlayer(d1, d2);
    final newTile = player.position;
    await game.tokens[game.engine.currentPlayerIndex].moveToTile(newTile, game.boardManager.tileToPosition(newTile));
    // Show property or card dialog if landed on special tile
    final tile = game.engine.board[newTile];
    if (tile.type == TileType.property && tile.property != null) {
      // If property is unowned, show purchase dialog
      if (tile.property!.owner == null) {
        game.overlays.add('PropertyPurchaseDialog');
        game.overlayManager.addWidget(
          'PropertyPurchaseDialog',
          PropertyPurchaseDialog(
            property: tile.property!,
            player: player,
            onBuy: () {
              game.engine.buyProperty();
              game.overlays.remove('PropertyPurchaseDialog');
            },
            onAuction: () {
              game.overlays.remove('PropertyPurchaseDialog');
              game.auctionManager.startAdvancedAuction(tile.property!);
            },
            onClose: () => game.overlays.remove('PropertyPurchaseDialog'),
          ),
        );
      } else {
        // If owned by current player, allow building
        if (tile.property!.owner == player) {
          game.overlays.add('BuildDialog');
          game.overlayManager.addWidget(
            'BuildDialog',
            BuildDialog(
              propertyName: tile.property!.name,
              currentHouses: tile.property!.houses,
              canBuildHouse: tile.property!.canBuildHouse(game.engine.bank),
              canBuildHotel: tile.property!.canBuildHotel(game.engine.bank),
              onBuildHouse: () {
                tile.property!.upgrade(game.engine.bank);
                game.overlays.remove('BuildDialog');
              },
              onBuildHotel: () {
                tile.property!.upgrade(game.engine.bank, buildHotel: true);
                game.overlays.remove('BuildDialog');
              },
              onClose: () => game.overlays.remove('BuildDialog'),
            ),
          );
        } else {
          game.overlays.add('PropertyDialog');
          game.overlayManager.addWidget(
            'PropertyDialog',
            PropertyDialog(
              property: tile.property!,
              player: player,
              onClose: () => game.overlays.remove('PropertyDialog'),
              onMortgage: () {
                player.mortgageProperty(tile.property!);
                game.overlays.remove('PropertyDialog');
              },
              onUnmortgage: () {
                player.unmortgageProperty(tile.property!);
                game.overlays.remove('PropertyDialog');
              },
            ),
          );
        }
      }
    } else if (tile.type == TileType.chance || tile.type == TileType.communityChest) {
      // Draw and apply card
      final card = tile.type == TileType.chance
          ? game.engine.drawChanceDeck()
          : game.engine.drawCommunityDeck();
      game.overlays.add('CardDialog');
      game.overlayManager.addWidget(
        'CardDialog',
        CardDialog(
          title: tile.type == TileType.chance ? 'Chance' : 'Community Chest',
          description: card.description,
          onAcknowledge: () {
            game.overlays.remove('CardDialog');
            card.applyEffect(player, game.engine);
          },
        ),
      );
    } else if (tile.type == TileType.buildingSite) {
      game.overlays.add('BuildDialog');
      game.overlayManager.addWidget(
        'BuildDialog',
        BuildDialog(
          propertyName: tile.property?.name ?? 'Unknown',
          currentHouses: tile.property?.houses ?? 0,
          canBuildHouse: tile.property?.canBuildHouse(game.engine.bank) ?? false,
          canBuildHotel: tile.property?.canBuildHotel(game.engine.bank) ?? false,
          onBuildHouse: () {
            // Dummy callback for now
            game.overlays.remove('BuildDialog');
          },
          onBuildHotel: () {
            // Dummy callback for now
            game.overlays.remove('BuildDialog');
          },
          onClose: () => game.overlays.remove('BuildDialog'),
        ),
      );
    }
  }
}

// If Property does not have canBuildHouse/canBuildHotel, add stubs in the Property class. If not possible, add fallback logic here.
// If TileType does not have 'buildingSite', add it as a value in the enum.
