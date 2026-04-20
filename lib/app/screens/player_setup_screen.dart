import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/art/token_painter.dart';
import '../controllers/game_controller.dart';
import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../theme/game_shapes.dart';
import '../widgets/cartoon_button.dart';
import '../widgets/cartoon_panel.dart';
import '../widgets/cartoon_toggle.dart';
import 'backdrop.dart';
import 'game_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});
  static const routeName = '/setup';

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int _count = 2;
  late List<_SlotData> _slots;

  @override
  void initState() {
    super.initState();
    _slots = [
      for (var i = 0; i < 6; i++)
        _SlotData(
          name: 'Player ${i + 1}',
          colorIndex: i,
          avatarIndex: i,
          isBot: i > 0,
        ),
    ];
  }

  bool get _canStart {
    final colors = <int>{};
    for (var i = 0; i < _count; i++) {
      final s = _slots[i];
      if (s.name.trim().isEmpty) return false;
      if (!colors.add(s.colorIndex)) return false;
    }
    return true;
  }

  void _start() {
    final ctl = context.read<GameController>();
    final slots = [
      for (var i = 0; i < _count; i++)
        PlayerSlot(
          name: _slots[i].name,
          colorIndex: _slots[i].colorIndex,
          avatarIndex: _slots[i].avatarIndex,
          isBot: _slots[i].isBot,
        ),
    ];
    ctl.startGame(slots);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.sunsetStart,
      body: SunsetBackdrop(
        floaters: false,
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.of(context).pop()),
              _CountSelector(
                count: _count,
                onChanged: (c) => setState(() => _count = c),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  itemCount: _count,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _SlotRow(
                    slot: _slots[i],
                    seatIndex: i,
                    onColor: () => _pickColor(i),
                    onAvatar: () => _pickAvatar(i),
                    onName: (n) => setState(() => _slots[i].name = n),
                    onBot: (b) => setState(() => _slots[i].isBot = b),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: CartoonButton(
                  label: 'START!',
                  icon: Icons.flag_rounded,
                  color: GameColors.happyGreen,
                  size: CartoonButtonSize.huge,
                  expanded: true,
                  pulse: _canStart,
                  sparkle: _canStart,
                  enabled: _canStart,
                  onPressed: _canStart ? _start : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickColor(int slot) async {
    final used = <int>{
      for (var i = 0; i < _count; i++)
        if (i != slot) _slots[i].colorIndex,
    };
    final picked = await showDialog<int>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ColorPicker(
        current: _slots[slot].colorIndex,
        taken: used,
      ),
    );
    if (picked != null) setState(() => _slots[slot].colorIndex = picked);
  }

  Future<void> _pickAvatar(int slot) async {
    final picked = await showDialog<int>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _AvatarPicker(
        color: GameColors.playerColors[_slots[slot].colorIndex],
        current: _slots[slot].avatarIndex,
      ),
    );
    if (picked != null) setState(() => _slots[slot].avatarIndex = picked);
  }
}

class _SlotData {
  _SlotData({
    required this.name,
    required this.colorIndex,
    required this.avatarIndex,
    required this.isBot,
  });
  String name;
  int colorIndex;
  int avatarIndex;
  bool isBot;
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
      child: Row(
        children: [
          CartoonButton(
            icon: Icons.arrow_back_rounded,
            color: GameColors.happyPurple,
            size: CartoonButtonSize.small,
            onPressed: onBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Who's Playing?",
              style: GameFonts.fredoka(
                size: 28,
                weight: FontWeight.w900,
                color: GameColors.white,
                shadows: const [
                  Shadow(
                    color: GameColors.outline,
                    offset: Offset(2, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountSelector extends StatelessWidget {
  const _CountSelector({required this.count, required this.onChanged});
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Wrap(
        spacing: 8,
        children: [
          for (final n in [2, 3, 4, 5, 6])
            GestureDetector(
              onTap: () => onChanged(n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: count == n ? 56 : 46,
                height: count == n ? 56 : 46,
                alignment: Alignment.center,
                decoration: CartoonShape.cartoonGlossy(
                  fill: count == n
                      ? GameColors.happyYellow
                      : GameColors.happyBlue,
                  radius: CartoonShape.radiusSmall,
                  offset: count == n ? 5 : 3,
                  borderWidth: 3,
                ),
                child: Text('$n',
                    style: GameFonts.fredoka(
                        size: count == n ? 28 : 22,
                        weight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                              color: GameColors.outline,
                              offset: Offset(0, 2),
                              blurRadius: 0),
                        ])),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.slot,
    required this.seatIndex,
    required this.onColor,
    required this.onAvatar,
    required this.onName,
    required this.onBot,
  });

  final _SlotData slot;
  final int seatIndex;
  final VoidCallback onColor;
  final VoidCallback onAvatar;
  final ValueChanged<String> onName;
  final ValueChanged<bool> onBot;

  @override
  Widget build(BuildContext context) {
    final color = GameColors.playerColors[slot.colorIndex];
    return CartoonPanel(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatar,
            child: Container(
              width: 56,
              height: 56,
              decoration: CartoonShape.cartoonBox(
                fill: Colors.white,
                radius: CartoonShape.radiusSmall,
                offset: 3,
                borderWidth: 3,
              ),
              child: CustomPaint(
                painter:
                    TokenPainter(color: color, faceVariant: slot.avatarIndex),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EditableName(
                  initial: slot.name,
                  onChanged: onName,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onColor,
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: CartoonShape.pill(
                            fill: color, offset: 1.5, borderWidth: 2.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'tap to change',
                        style: GameFonts.nunito(
                            size: 11,
                            weight: FontWeight.w700,
                            color: GameColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CartoonToggle(
            value: slot.isBot,
            onChanged: onBot,
            onLabel: 'CPU',
            offLabel: 'YOU',
            activeColor: GameColors.happyPurple,
            inactiveColor: GameColors.happyGreen,
          ),
        ],
      ),
    );
  }
}

class _EditableName extends StatefulWidget {
  const _EditableName({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_EditableName> createState() => _EditableNameState();
}

class _EditableNameState extends State<_EditableName> {
  late final TextEditingController _ctl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctl,
      style: GameFonts.title(),
      maxLength: 18,
      decoration: const InputDecoration(
        isDense: true,
        counterText: '',
        border: InputBorder.none,
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.current, required this.taken});
  final int current;
  final Set<int> taken;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CartoonPanel(
        fill: GameColors.cream,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Colour', style: GameFonts.title()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < GameColors.playerColors.length; i++)
                  GestureDetector(
                    onTap: taken.contains(i)
                        ? null
                        : () => Navigator.of(context).pop(i),
                    child: Opacity(
                      opacity: taken.contains(i) ? 0.35 : 1.0,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: CartoonShape.cartoonBox(
                          fill: GameColors.playerColors[i],
                          radius: CartoonShape.radiusSmall,
                          offset: i == current ? 5 : 3,
                          borderWidth: 3,
                          border: i == current
                              ? GameColors.happyYellow
                              : GameColors.outline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.color, required this.current});
  final Color color;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CartoonPanel(
        fill: GameColors.cream,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Face', style: GameFonts.title()),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (var i = 0; i < 12; i++)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(i),
                    child: Container(
                      decoration: CartoonShape.cartoonBox(
                        fill: Colors.white,
                        radius: CartoonShape.radiusSmall,
                        offset: i == current ? 5 : 3,
                        borderWidth: 3,
                        border: i == current
                            ? GameColors.happyYellow
                            : GameColors.outline,
                      ),
                      child: CustomPaint(
                        painter: TokenPainter(color: color, faceVariant: i),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
