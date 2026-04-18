import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/game_controller.dart';
import '../../game_logic/models/player.dart';
import '../../game_logic/models/property.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../utils/rupee_formatter.dart';
import '../common/gold_button.dart';

/// Two-column trade proposer. Left = your side, right = theirs.
class TradePanelSheet extends StatefulWidget {
  const TradePanelSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const TradePanelSheet(),
    );
  }

  @override
  State<TradePanelSheet> createState() => _TradePanelSheetState();
}

class _TradePanelSheetState extends State<TradePanelSheet> {
  Player? _partner;
  final Set<Property> _offering = {};
  final Set<Property> _requesting = {};
  int _offerCash = 0;
  int _requestCash = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GameController>();
    final me = c.currentPlayer;
    final others = c.engine.players
        .where((p) => p != me && !p.isBankrupt)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.panel,
          borderRadius: BorderRadius.vertical(top: AppRadius.lg),
        ),
        child: Column(
          children: [
            _Header(onClose: () => Navigator.of(context).pop()),
            if (_partner == null)
              Expanded(
                child: _PartnerPicker(
                  others: others,
                  controller: c,
                  onPick: (p) => setState(() => _partner = p),
                ),
              )
            else
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    _Side(
                      title: 'YOU OFFER',
                      player: me,
                      controller: c,
                      selected: _offering,
                      cashValue: _offerCash,
                      onToggle: (p) => setState(() {
                        _offering.contains(p)
                            ? _offering.remove(p)
                            : _offering.add(p);
                      }),
                      onCashChanged: (v) =>
                          setState(() => _offerCash = v),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    const Icon(Icons.swap_vert_rounded,
                        color: AppColors.gold, size: 28),
                    const SizedBox(height: AppSpacing.l),
                    _Side(
                      title: 'YOU WANT',
                      player: _partner!,
                      controller: c,
                      selected: _requesting,
                      cashValue: _requestCash,
                      onToggle: (p) => setState(() {
                        _requesting.contains(p)
                            ? _requesting.remove(p)
                            : _requesting.add(p);
                      }),
                      onCashChanged: (v) =>
                          setState(() => _requestCash = v),
                    ),
                  ],
                ),
              ),
            if (_partner != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    Expanded(
                      child: GoldButton(
                        label: 'CHANGE PARTNER',
                        icon: Icons.person_search_rounded,
                        danger: true,
                        onPressed: () => setState(() => _partner = null),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      flex: 2,
                      child: GoldButton(
                        label: 'EXECUTE TRADE',
                        icon: Icons.check_rounded,
                        success: true,
                        glowing: true,
                        onPressed: _canExecute(me) ? _execute : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _canExecute(Player me) {
    if (_partner == null) return false;
    if (me.balance < _offerCash) return false;
    if (_partner!.balance < _requestCash) return false;
    // Avoid trading properties with houses (engine-level rule).
    if (_offering.any((p) => p.houses > 0 || p.hasHotel)) return false;
    if (_requesting.any((p) => p.houses > 0 || p.hasHotel)) return false;
    if (_offering.isEmpty &&
        _requesting.isEmpty &&
        _offerCash == 0 &&
        _requestCash == 0) return false;
    return true;
  }

  void _execute() {
    final c = context.read<GameController>();
    c.executeTrade(
      partner: _partner!,
      offeredProperties: _offering.toList(),
      requestedProperties: _requesting.toList(),
      offeredCash: _offerCash,
      requestedCash: _requestCash,
    );
    Navigator.of(context).pop();
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.l, AppSpacing.l, AppSpacing.s, AppSpacing.m),
      child: Row(
        children: [
          Text('TRADE',
              style: AppTypography.display(size: 16, letterSpacing: 5)),
          const Spacer(),
          IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }
}

class _PartnerPicker extends StatelessWidget {
  final List<Player> others;
  final GameController controller;
  final ValueChanged<Player> onPick;
  const _PartnerPicker({
    required this.others,
    required this.controller,
    required this.onPick,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text('TRADE WITH…',
              style: AppTypography.label(
                  size: 11,
                  letterSpacing: 3,
                  color: AppColors.textMuted)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: others.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.s),
            itemBuilder: (_, i) {
              final p = others[i];
              final color =
                  AppColors.playerColors[controller.colorIndexFor(p)];
              return GestureDetector(
                onTap: () => onPick(p),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.panelInset,
                    borderRadius: AppRadius.rMd,
                    border:
                        Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                        alignment: Alignment.center,
                        child: Text('${p.tokenId}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(p.name,
                            style: AppTypography.body(
                                size: 14, weight: FontWeight.w700)),
                      ),
                      Text(RupeeFormatter.compact(p.balance),
                          style: AppTypography.money(
                              size: 13, color: color)),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.gold),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Side extends StatelessWidget {
  final String title;
  final Player player;
  final GameController controller;
  final Set<Property> selected;
  final int cashValue;
  final ValueChanged<Property> onToggle;
  final ValueChanged<int> onCashChanged;
  const _Side({
    required this.title,
    required this.player,
    required this.controller,
    required this.selected,
    required this.cashValue,
    required this.onToggle,
    required this.onCashChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.playerColors[controller.colorIndexFor(player)];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.panelInset,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: AppTypography.label(
                      size: 10,
                      letterSpacing: 3,
                      color: AppColors.textMuted)),
              const Spacer(),
              Text(player.name,
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: color,
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          // Cash row
          Row(
            children: [
              const Icon(Icons.payments_rounded,
                  color: AppColors.gold, size: 18),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  RupeeFormatter.format(cashValue),
                  style: AppTypography.money(size: 14),
                ),
              ),
              IconButton(
                onPressed: cashValue >= 50000
                    ? () => onCashChanged(cashValue - 50000)
                    : null,
                icon: const Icon(Icons.remove_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(
                onPressed: cashValue + 50000 <= player.balance
                    ? () => onCashChanged(cashValue + 50000)
                    : null,
                icon: const Icon(Icons.add_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(color: AppColors.divider),
          // Properties
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final p in player.ownedProperties)
                _PropertyChip(
                  property: p,
                  selected: selected.contains(p),
                  onTap: () => onToggle(p),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final Property property;
  final bool selected;
  final VoidCallback onTap;
  const _PropertyChip({
    required this.property,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final color = AppColors.group(property.colorGroup);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppRadius.rSm,
          color: selected
              ? color.withValues(alpha: 0.3)
              : AppColors.panelElevated,
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(property.name,
                style: AppTypography.body(
                    size: 11, weight: FontWeight.w600)),
            if (property.isMortgaged) ...[
              const SizedBox(width: 4),
              const Icon(Icons.account_balance_rounded,
                  size: 12, color: AppColors.warning),
            ],
          ],
        ),
      ),
    );
  }
}
