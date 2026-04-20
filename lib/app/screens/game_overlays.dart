import 'package:flutter/material.dart';

import '../../game_logic/models/card.dart' as game_card;
import '../../game_logic/models/enums.dart';
import '../../game_logic/models/player.dart';
import '../../game_logic/models/property.dart';
import '../../utils/rupee_formatter.dart';
import '../controllers/game_controller.dart';
import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';
import '../widgets/cartoon_button.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/cartoon_panel.dart';

/// Bottom-sheet style overlay shown when the current player lands on an
/// unowned property. Offers BUY or AUCTION.
class PropertyLandingOverlay extends StatelessWidget {
  const PropertyLandingOverlay({
    super.key,
    required this.controller,
    required this.property,
  });

  final GameController controller;
  final Property property;

  @override
  Widget build(BuildContext context) {
    final p = property;
    final groupColor = GameColors.forGroup(p.colorGroup);
    final canAfford = controller.currentPlayer.balance >= p.price;
    return _BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
            color: groupColor,
            title: p.name,
            subtitle: 'Unowned',
          ),
          const SizedBox(height: 10),
          Text('PRICE', style: GameFonts.subtitle()),
          Text(RupeeFormatter.format(p.price),
              style: GameFonts.numberHuge(
                  color: GameColors.happyGreen,
                  outline: GameColors.outline)),
          const SizedBox(height: 10),
          if (p.rentTable != null && p.rentTable!.isNotEmpty)
            _RentTable(p: p),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CartoonButton(
                label: 'AUCTION',
                color: GameColors.happyOrange,
                icon: Icons.gavel_rounded,
                onPressed: controller.declineAndAuction,
              ),
              CartoonButton(
                label: canAfford
                    ? 'BUY'
                    : 'TOO EXPENSIVE',
                color: canAfford ? GameColors.happyGreen : Colors.grey.shade500,
                icon: Icons.shopping_bag_rounded,
                enabled: canAfford,
                onPressed: canAfford ? controller.buyPendingProperty : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RentTable extends StatelessWidget {
  const _RentTable({required this.p});
  final Property p;

  @override
  Widget build(BuildContext context) {
    final rows = <({String label, int amt})>[
      (label: 'Base', amt: p.rentTable![0]),
      (label: '1 House', amt: p.rentTable![1]),
      (label: '2 Houses', amt: p.rentTable![2]),
      (label: '3 Houses', amt: p.rentTable![3]),
      (label: '4 Houses', amt: p.rentTable![4]),
      (label: 'HOTEL', amt: p.rentTable![5]),
    ];
    return CartoonPanel(
      fill: GameColors.parchment,
      padding: const EdgeInsets.all(10),
      radius: CartoonShape.radiusSmall,
      offset: 3,
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(r.label, style: GameFonts.bodyBold())),
                  Text(RupeeFormatter.compact(r.amt),
                      style: GameFonts.bodyBold(color: GameColors.happyRed)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Chance / Community Chest card reveal with a flip animation.
class CardRevealOverlay extends StatefulWidget {
  const CardRevealOverlay({
    super.key,
    required this.controller,
    required this.card,
    required this.origin,
  });
  final GameController controller;
  final game_card.Card card;
  final DeckOrigin origin;

  @override
  State<CardRevealOverlay> createState() => _CardRevealOverlayState();
}

class _CardRevealOverlayState extends State<CardRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChance = widget.origin == DeckOrigin.chance;
    final color = isChance ? GameColors.happyOrange : GameColors.happyYellow;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _flip,
        builder: (_, _) {
          final v = _flip.value;
          final showBack = v < 0.5;
          final angle = v * 3.14159;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: showBack
                ? _CardBack(color: color, label: isChance ? '?' : '◆')
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _CardFront(
                      color: color,
                      title: isChance ? 'CHANCE' : 'COMMUNITY CHEST',
                      body: widget.card.description,
                      onOk: () {
                        widget.controller.acknowledgeCard();
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280, minHeight: 360),
      child: Container(
        decoration: CartoonShape.cartoonGlossy(
            fill: color, radius: CartoonShape.radiusLarge, offset: 7),
        alignment: Alignment.center,
        child: Text(label,
            style: GameFonts.fredoka(
                size: 120,
                weight: FontWeight.w900,
                color: Colors.white,
                shadows: const [
                  Shadow(
                      color: GameColors.outline,
                      offset: Offset(4, 6),
                      blurRadius: 0),
                ])),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.color,
    required this.title,
    required this.body,
    required this.onOk,
  });
  final Color color;
  final String title;
  final String body;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: CartoonPanel(
        fill: GameColors.cream,
        padding: const EdgeInsets.all(20),
        radius: CartoonShape.radiusLarge,
        offset: CartoonShape.shadowLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: CartoonShape.pill(fill: color, borderWidth: 3),
              child: Text(title,
                  style: GameFonts.buttonLabel(color: Colors.white, size: 14)),
            ),
            const SizedBox(height: 16),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GameFonts.title(),
            ),
            const SizedBox(height: 20),
            CartoonButton(
              label: 'OK',
              color: GameColors.happyGreen,
              size: CartoonButtonSize.medium,
              onPressed: onOk,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen auction overlay with bid chips and a pass button.
class AuctionOverlay extends StatefulWidget {
  const AuctionOverlay({super.key, required this.controller});
  final GameController controller;

  @override
  State<AuctionOverlay> createState() => _AuctionOverlayState();
}

class _AuctionOverlayState extends State<AuctionOverlay> {
  int _bid = 0;

  @override
  void initState() {
    super.initState();
    _bid = widget.controller.auction?.highestBid ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.controller.auction;
    if (a == null) return const SizedBox.shrink();
    final bidder = a.current;
    final minBid = a.highestBid + 10000;
    return _BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
            color: GameColors.happyOrange,
            title: 'AUCTION: ${a.property.name}',
            subtitle: 'Highest bid: ${RupeeFormatter.compact(a.highestBid)}'
                '${a.highestBidder != null ? ' by ${a.highestBidder!.name}' : ''}',
          ),
          const SizedBox(height: 10),
          Text('${bidder.name}\'s turn', style: GameFonts.title()),
          Text(RupeeFormatter.format(_bid < minBid ? minBid : _bid),
              style: GameFonts.numberHuge()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final step in const <int>[10000, 50000, 100000])
                CartoonButton(
                  label: '+${RupeeFormatter.compact(step)}',
                  color: GameColors.happyBlue,
                  size: CartoonButtonSize.small,
                  onPressed: () => setState(() {
                    _bid = (_bid < minBid ? minBid : _bid) + step;
                  }),
                ),
              CartoonButton(
                label: 'RESET',
                color: GameColors.happyPurple,
                size: CartoonButtonSize.small,
                onPressed: () => setState(() => _bid = minBid),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CartoonButton(
                label: 'PASS',
                color: GameColors.happyRed,
                icon: Icons.close_rounded,
                onPressed: () {
                  widget.controller.passBid();
                  setState(() {
                    _bid = widget.controller.auction?.highestBid ?? 0;
                  });
                },
              ),
              CartoonButton(
                label: 'BID',
                color: GameColors.happyGreen,
                icon: Icons.gavel_rounded,
                enabled: _bid >= minBid && bidder.balance >= _bid,
                onPressed: (_bid >= minBid && bidder.balance >= _bid)
                    ? () {
                        widget.controller.placeBid(_bid);
                        setState(() {
                          _bid = widget.controller.auction?.highestBid ??
                              0;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Jail pre-roll choice.
class JailChoiceOverlay extends StatelessWidget {
  const JailChoiceOverlay({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.currentPlayer;
    final hasGOOJF = p.goojfCards.isNotEmpty;
    final canPay = p.balance >= controller.engine.config.jailExitCost;
    return _BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
            color: GameColors.happyBlue,
            title: '${p.name} is in Jail',
            subtitle: 'Turn ${p.jailTurns + 1} of 3',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              CartoonButton(
                label: 'PAY ₹50K',
                color: GameColors.happyGreen,
                enabled: canPay,
                onPressed: canPay ? controller.payToLeaveJail : null,
              ),
              CartoonButton(
                label: 'USE CARD',
                color: GameColors.happyPurple,
                enabled: hasGOOJF,
                onPressed: hasGOOJF ? controller.useGoojfToLeaveJail : null,
              ),
              CartoonButton(
                label: 'ROLL DOUBLES',
                color: GameColors.happyOrange,
                onPressed: controller.rollDice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Game over screen with trophy + confetti + final standings.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.controller,
    required this.onPlayAgain,
  });
  final GameController controller;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final players = [...controller.engine.players]
      ..sort((a, b) => b.balance.compareTo(a.balance));
    final winner = players.firstWhere((p) => !p.isBankrupt,
        orElse: () => players.first);
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: CartoonPanel(
        fill: GameColors.cream,
        padding: const EdgeInsets.all(24),
        radius: CartoonShape.radiusLarge,
        offset: CartoonShape.shadowLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (_, t, _) => Transform.scale(
                scale: t,
                child: Icon(Icons.emoji_events_rounded,
                    size: 96, color: GameColors.gold),
              ),
            ),
            const SizedBox(height: 12),
            Text('${winner.name} Wins!',
                style: GameFonts.fredoka(
                    size: 36,
                    weight: FontWeight.w900,
                    color: GameColors.happyRed)),
            const SizedBox(height: 14),
            for (var i = 0; i < players.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${i + 1}.  ',
                        style: GameFonts.title(
                            color: i == 0
                                ? GameColors.gold
                                : GameColors.outline)),
                    Text(players[i].name, style: GameFonts.title()),
                    const SizedBox(width: 10),
                    Text(RupeeFormatter.compact(players[i].balance),
                        style: GameFonts.bodyBold(color: GameColors.happyRed)),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            CartoonButton(
              label: 'PLAY AGAIN',
              color: GameColors.happyGreen,
              icon: Icons.replay_rounded,
              size: CartoonButtonSize.large,
              pulse: true,
              onPressed: onPlayAgain,
            ),
          ],
        ),
      ),
    );
  }
}

/// Property manager sheet listing current player's holdings.
class PropertyManagerOverlay extends StatefulWidget {
  const PropertyManagerOverlay({super.key, required this.controller});
  final GameController controller;

  @override
  State<PropertyManagerOverlay> createState() => _PropertyManagerOverlayState();
}

class _PropertyManagerOverlayState extends State<PropertyManagerOverlay> {
  @override
  Widget build(BuildContext context) {
    final p = widget.controller.currentPlayer;
    return _BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
              color: GameColors.happyGreen,
              title: 'My Properties',
              subtitle:
                  '${p.ownedProperties.length} property(ies)'),
          const SizedBox(height: 10),
          if (p.ownedProperties.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('You own no properties yet.',
                  style: GameFonts.body()),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: p.ownedProperties.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final prop = p.ownedProperties[i];
                  final canBuild = widget.controller.engine
                      .canUpgradeProperty(prop, p);
                  final canSell = widget.controller.engine
                      .canDowngradeProperty(prop, p);
                  final canMortgage = p.canMortgageProperty(prop);
                  final canUnmortgage = p.canUnmortgageProperty(prop);
                  return CartoonPanel(
                    padding: const EdgeInsets.all(10),
                    fill: GameColors.cream,
                    radius: CartoonShape.radiusSmall,
                    offset: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              color: GameColors.forGroup(prop.colorGroup),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(prop.name,
                                  style: GameFonts.bodyBold()),
                            ),
                            if (prop.isMortgaged)
                              const Icon(Icons.lock, size: 16,
                                  color: GameColors.happyRed),
                            if (prop.houses > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text('🏠 ${prop.houses}',
                                    style: GameFonts.bodyBold()),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            CartoonButton(
                              label: 'BUILD',
                              color: GameColors.happyGreen,
                              size: CartoonButtonSize.small,
                              enabled: canBuild,
                              onPressed: canBuild
                                  ? () => setState(() => widget
                                      .controller
                                      .tryBuildHouse(prop))
                                  : null,
                            ),
                            CartoonButton(
                              label: 'SELL',
                              color: GameColors.happyOrange,
                              size: CartoonButtonSize.small,
                              enabled: canSell,
                              onPressed: canSell
                                  ? () => setState(() => widget
                                      .controller
                                      .trySellHouse(prop))
                                  : null,
                            ),
                            CartoonButton(
                              label: canUnmortgage
                                  ? 'UNMORTGAGE'
                                  : 'MORTGAGE',
                              color: canUnmortgage
                                  ? GameColors.happyBlue
                                  : GameColors.happyRed,
                              size: CartoonButtonSize.small,
                              enabled: canMortgage || canUnmortgage,
                              onPressed: canMortgage
                                  ? () => setState(() => widget.controller
                                      .tryMortgage(prop))
                                  : canUnmortgage
                                      ? () => setState(() => widget.controller
                                          .tryUnmortgage(prop))
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          CartoonButton(
            label: 'CLOSE',
            color: GameColors.happyPurple,
            size: CartoonButtonSize.medium,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Two-column trade panel.
class TradeOverlay extends StatefulWidget {
  const TradeOverlay({super.key, required this.controller});
  final GameController controller;

  @override
  State<TradeOverlay> createState() => _TradeOverlayState();
}

class _TradeOverlayState extends State<TradeOverlay> {
  Player? _partner;
  final Set<Property> _offer = {};
  final Set<Property> _request = {};
  int _offerCash = 0;
  int _requestCash = 0;

  @override
  Widget build(BuildContext context) {
    final me = widget.controller.currentPlayer;
    final others = widget.controller.engine.players
        .where((p) => p != me && !p.isBankrupt)
        .toList();
    _partner ??= others.isNotEmpty ? others.first : null;

    return _BottomSheetWrapper(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Banner(
            color: GameColors.happyPink,
            title: 'Trade',
            subtitle: 'Offer / Request between players',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [
              for (final o in others)
                CartoonButton(
                  label: o.name,
                  color: _partner == o
                      ? GameColors.happyGreen
                      : GameColors.happyBlue,
                  size: CartoonButtonSize.small,
                  onPressed: () {
                    setState(() {
                      _partner = o;
                      _request.clear();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_partner != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TradeColumn(
                    title: me.name,
                    properties: me.ownedProperties,
                    selected: _offer,
                    cash: _offerCash,
                    onCash: (v) => setState(() => _offerCash = v),
                    onToggle: (p) => setState(
                        () => _offer.contains(p) ? _offer.remove(p) : _offer.add(p)),
                    maxCash: me.balance,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TradeColumn(
                    title: _partner!.name,
                    properties: _partner!.ownedProperties,
                    selected: _request,
                    cash: _requestCash,
                    onCash: (v) => setState(() => _requestCash = v),
                    onToggle: (p) => setState(() => _request.contains(p)
                        ? _request.remove(p)
                        : _request.add(p)),
                    maxCash: _partner!.balance,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CartoonButton(
                label: 'CANCEL',
                color: GameColors.happyRed,
                onPressed: () => Navigator.of(context).pop(),
              ),
              CartoonButton(
                label: 'PROPOSE',
                color: GameColors.happyGreen,
                icon: Icons.handshake_rounded,
                enabled: _partner != null &&
                    (_offer.isNotEmpty ||
                        _request.isNotEmpty ||
                        _offerCash > 0 ||
                        _requestCash > 0),
                onPressed: () {
                  final ok = widget.controller.executeTrade(
                    partner: _partner!,
                    offeredProperties: _offer.toList(),
                    requestedProperties: _request.toList(),
                    offeredCash: _offerCash,
                    requestedCash: _requestCash,
                  );
                  Navigator.of(context).pop();
                  if (!ok) {
                    CartoonDialog.alert(context,
                        title: 'Trade Failed',
                        message: 'Trade was invalid or could not complete.',
                        headerColor: GameColors.happyRed);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TradeColumn extends StatelessWidget {
  const _TradeColumn({
    required this.title,
    required this.properties,
    required this.selected,
    required this.cash,
    required this.onCash,
    required this.onToggle,
    required this.maxCash,
  });

  final String title;
  final List<Property> properties;
  final Set<Property> selected;
  final int cash;
  final ValueChanged<int> onCash;
  final ValueChanged<Property> onToggle;
  final int maxCash;

  @override
  Widget build(BuildContext context) {
    return CartoonPanel(
      fill: GameColors.parchment,
      padding: const EdgeInsets.all(8),
      radius: CartoonShape.radiusSmall,
      offset: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: GameFonts.bodyBold()),
          const SizedBox(height: 4),
          SizedBox(
            height: 140,
            child: ListView(
              children: [
                for (final p in properties)
                  GestureDetector(
                    onTap: () => onToggle(p),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: CartoonShape.pill(
                        fill: selected.contains(p)
                            ? GameColors.happyGreen
                            : Colors.white,
                        offset: selected.contains(p) ? 3 : 1.5,
                        borderWidth: 2.5,
                      ),
                      child: Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              color: GameColors.forGroup(p.colorGroup)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(p.name,
                                style: GameFonts.nunito(
                                    size: 11,
                                    weight: FontWeight.w800,
                                    color: selected.contains(p)
                                        ? Colors.white
                                        : GameColors.outline)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('Cash ${RupeeFormatter.compact(cash)}',
              style: GameFonts.bodyBold()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CartoonButton(
                label: '−50K',
                color: GameColors.happyRed,
                size: CartoonButtonSize.small,
                onPressed: cash >= 50000 ? () => onCash(cash - 50000) : null,
                enabled: cash >= 50000,
              ),
              CartoonButton(
                label: '+50K',
                color: GameColors.happyGreen,
                size: CartoonButtonSize.small,
                onPressed: cash + 50000 <= maxCash
                    ? () => onCash(cash + 50000)
                    : null,
                enabled: cash + 50000 <= maxCash,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────

class _BottomSheetWrapper extends StatelessWidget {
  const _BottomSheetWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: CartoonPanel(
            fill: GameColors.cream,
            radius: CartoonShape.radiusLarge,
            offset: CartoonShape.shadowLarge,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: CartoonShape.cartoonBox(
        fill: color,
        radius: CartoonShape.radiusMedium,
        offset: 4,
        borderWidth: 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GameFonts.buttonLabel(color: Colors.white, size: 18)),
          Text(subtitle,
              style: GameFonts.nunito(
                  size: 12, weight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
