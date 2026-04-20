import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/art/wooden_table_painter.dart';
import '../../game/business_game.dart';
import '../../game_logic/models/player.dart';
import '../../utils/rupee_formatter.dart';
import '../controllers/game_controller.dart';
import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';
import '../widgets/cartoon_button.dart';
import '../widgets/cartoon_panel.dart';
import '../widgets/money_counter.dart';
import 'game_overlays.dart';
import 'menu_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  static const routeName = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BusinessGame? _game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= BusinessGame(controller: context.read<GameController>());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (controller.phase == TurnPhase.gameOver) {
      return Scaffold(
        body: Stack(
          children: [
            _BoardArea(game: _game),
            GameOverOverlay(
              controller: controller,
              onPlayAgain: () {
                controller.resetToMenu();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: GameColors.tableWood,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            // Fluid layout: on wide aspect ratios (landscape tablets, desktop),
            // move the HUD to the side so the board gets a more square space.
            // Below the threshold we stack vertically. This is a single
            // aspect-ratio check, not a per-device branch.
            final wide = c.maxWidth / math.max(c.maxHeight, 1) > 1.3;
            final board = Stack(
              children: [
                _BoardArea(game: _game),
                _DynamicOverlay(controller: controller),
              ],
            );
            if (wide) {
              return Row(
                children: [
                  SizedBox(
                    width: math.min(c.maxWidth * 0.26, 260),
                    child: Column(
                      children: [
                        Expanded(
                          child: _PlayerHUD(
                              controller: controller, vertical: true),
                        ),
                        _ActionBar(controller: controller, compact: true),
                      ],
                    ),
                  ),
                  Expanded(child: board),
                ],
              );
            }
            return Column(
              children: [
                _PlayerHUD(controller: controller),
                Expanded(child: board),
                _ActionBar(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Board area (Flame GameWidget on a wooden table backdrop)
// ─────────────────────────────────────────────────────────────────────

class _BoardArea extends StatelessWidget {
  const _BoardArea({required this.game});
  final BusinessGame? game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: WoodenTablePainter()),
        if (game != null)
          GameWidget(game: game!)
        else
          const Center(
            child: CircularProgressIndicator(color: GameColors.happyYellow),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Top HUD — horizontal player strip
// ─────────────────────────────────────────────────────────────────────

class _PlayerHUD extends StatelessWidget {
  const _PlayerHUD({required this.controller, this.vertical = false});
  final GameController controller;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    if (!controller.isReady) return const SizedBox.shrink();
    final players = controller.engine.players;
    final listView = ListView.separated(
      scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
      itemCount: players.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8, height: 8),
      itemBuilder: (_, i) => _PlayerCard(
        player: players[i],
        controller: controller,
        isCurrent: controller.currentPlayer == players[i],
        vertical: vertical,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(8),
      color: GameColors.tableDark,
      // Horizontal scroll direction requires a bounded CROSS axis (height).
      // Vertical mode is wrapped by Expanded in the parent layout, so here
      // we just fill the height given to us.
      child: vertical ? listView : SizedBox(height: 84, child: listView),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.controller,
    required this.isCurrent,
    this.vertical = false,
  });

  final Player player;
  final GameController controller;
  final bool isCurrent;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final seatColor =
        GameColors.playerColors[controller.colorIndexFor(player)];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: vertical ? double.infinity : (isCurrent ? 170 : 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: CartoonShape.cartoonBox(
        fill: player.isBankrupt ? Colors.grey.shade400 : GameColors.cream,
        border: isCurrent ? GameColors.happyYellow : GameColors.outline,
        borderWidth: isCurrent ? 4.5 : 3,
        offset: 4,
        radius: CartoonShape.radiusSmall,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: CartoonShape.pill(
                fill: seatColor, borderWidth: 3, offset: 2),
            child: isCurrent
                ? const Icon(Icons.star_rounded,
                    color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  overflow: TextOverflow.ellipsis,
                  style: GameFonts.bodyBold()
                      .copyWith(fontSize: 13, height: 1.0),
                ),
                const SizedBox(height: 2),
                MoneyCounter(
                  amount: player.balance,
                  size: 13,
                  compact: true,
                  color: GameColors.happyRed,
                ),
                if (player.inJail)
                  Text('IN JAIL',
                      style: GameFonts.nunito(
                          size: 10,
                          weight: FontWeight.w900,
                          color: GameColors.happyBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Bottom action bar
// ─────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.controller, this.compact = false});
  final GameController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phase = controller.phase;
    Widget body;
    switch (phase) {
      case TurnPhase.idle:
        body = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CartoonButton(
              label: 'ROLL DICE',
              icon: Icons.casino_rounded,
              color: GameColors.happyGreen,
              size: CartoonButtonSize.large,
              pulse: true,
              sparkle: true,
              onPressed: controller.rollDice,
            ),
          ],
        );
        break;
      case TurnPhase.jailChoice:
        body = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Jail choice — see dialog',
                style: GameFonts.bodyBold(color: Colors.white)),
          ],
        );
        break;
      case TurnPhase.rolling:
      case TurnPhase.moving:
      case TurnPhase.rentDue:
      case TurnPhase.taxNotice:
      case TurnPhase.goToJailNotice:
        final toast = controller.toastMessage;
        body = Center(
          child: Text(
            toast ?? '...',
            style: GameFonts.title(color: Colors.white),
          ),
        );
        break;
      case TurnPhase.landedBuy:
      case TurnPhase.auction:
      case TurnPhase.cardDrawn:
        body = Center(
          child: Text('Resolve the panel above',
              style: GameFonts.bodyBold(color: Colors.white)),
        );
        break;
      case TurnPhase.postMove:
        body = Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            CartoonButton(
              label: 'PROPERTIES',
              color: GameColors.happyGreen,
              icon: Icons.home_work_rounded,
              size: CartoonButtonSize.small,
              onPressed: () => _showPropertyManager(context),
            ),
            CartoonButton(
              label: 'TRADE',
              color: GameColors.happyPink,
              icon: Icons.handshake_rounded,
              size: CartoonButtonSize.small,
              onPressed: () => _showTrade(context),
            ),
            CartoonButton(
              label: 'END TURN',
              color: GameColors.happyRed,
              icon: Icons.check_rounded,
              size: CartoonButtonSize.medium,
              onPressed: controller.endTurn,
            ),
          ],
        );
        break;
      case TurnPhase.gameOver:
        body = const SizedBox.shrink();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: GameColors.tableDark,
        border: Border(
          top: BorderSide(color: GameColors.outline, width: 3),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: KeyedSubtree(key: ValueKey(phase), child: body),
      ),
    );
  }

  void _showPropertyManager(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: PropertyManagerOverlay(controller: controller),
      ),
    );
  }

  void _showTrade(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: TradeOverlay(controller: controller),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Dynamic phase overlay on top of the board area
// ─────────────────────────────────────────────────────────────────────

class _DynamicOverlay extends StatelessWidget {
  const _DynamicOverlay({required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final phase = controller.phase;
    Widget? overlay;
    switch (phase) {
      case TurnPhase.landedBuy:
        if (controller.pendingProperty != null) {
          overlay = PropertyLandingOverlay(
            controller: controller,
            property: controller.pendingProperty!,
          );
        }
        break;
      case TurnPhase.auction:
        overlay = AuctionOverlay(controller: controller);
        break;
      case TurnPhase.cardDrawn:
        if (controller.pendingCard != null &&
            controller.pendingCardOrigin != null) {
          overlay = CardRevealOverlay(
            controller: controller,
            card: controller.pendingCard!,
            origin: controller.pendingCardOrigin!,
          );
        }
        break;
      case TurnPhase.jailChoice:
        overlay = JailChoiceOverlay(controller: controller);
        break;
      case TurnPhase.rentDue:
      case TurnPhase.taxNotice:
        if (controller.toastMessage != null) {
          overlay = _ToastBanner(
            text: controller.toastMessage!,
            amount: controller.toastAmount,
          );
        }
        break;
      default:
        overlay = null;
    }
    if (overlay == null) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(phase), child: overlay),
    );
  }
}

class _ToastBanner extends StatelessWidget {
  const _ToastBanner({required this.text, this.amount});
  final String text;
  final int? amount;

  static const double _maxWidthCap = 380;
  static const double _sidePadding = 12;

  @override
  Widget build(BuildContext context) {
    final isGain = (amount ?? 0) >= 0;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth - _sidePadding * 2;
          final pillWidth = math.min(available, _maxWidthCap)
              .clamp(120.0, _maxWidthCap);
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: pillWidth),
                child: CartoonPanel(
                  fill: isGain ? GameColors.happyGreen : GameColors.happyRed,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  radius: CartoonShape.radiusMedium,
                  offset: CartoonShape.shadowMedium,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isGain ? Icons.add_circle : Icons.remove_circle,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GameFonts.buttonLabel(
                              color: Colors.white, size: 13),
                        ),
                      ),
                      if (amount != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${amount! >= 0 ? '+' : '−'}${RupeeFormatter.compact(amount!.abs())}',
                          style: GameFonts.buttonLabel(
                              color: Colors.white, size: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
