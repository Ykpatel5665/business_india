import 'package:flutter/material.dart';

import '../controllers/sound_manager.dart';
import '../theme/game_colors.dart';
import '../theme/game_fonts.dart';
import '../widgets/cartoon_button.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/cartoon_panel.dart';
import '../widgets/cartoon_toggle.dart';
import 'backdrop.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum GameSpeed { slow, normal, fast }

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sfx;
  late bool _music;
  late bool _vibe;
  GameSpeed _speed = GameSpeed.normal;

  @override
  void initState() {
    super.initState();
    _sfx = SoundManager.instance.sfxEnabled;
    _music = SoundManager.instance.musicEnabled;
    _vibe = SoundManager.instance.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.sunsetStart,
      body: SunsetBackdrop(
        floaters: false,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Header(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        _Row(
                          label: 'Sound Effects',
                          trailing: CartoonToggle(
                            value: _sfx,
                            onChanged: (v) {
                              setState(() => _sfx = v);
                              SoundManager.instance.sfxEnabled = v;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _Row(
                          label: 'Music',
                          trailing: CartoonToggle(
                            value: _music,
                            onChanged: (v) {
                              setState(() => _music = v);
                              SoundManager.instance.musicEnabled = v;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _Row(
                          label: 'Vibration',
                          trailing: CartoonToggle(
                            value: _vibe,
                            onChanged: (v) {
                              setState(() => _vibe = v);
                              SoundManager.instance.vibrationEnabled = v;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        CartoonPanel(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Game Speed', style: GameFonts.title()),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                children: [
                                  for (final s in GameSpeed.values)
                                    CartoonButton(
                                      label: s.name.toUpperCase(),
                                      color: _speed == s
                                          ? GameColors.happyGreen
                                          : GameColors.happyBlue,
                                      size: CartoonButtonSize.small,
                                      onPressed: () => setState(() => _speed = s),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CartoonButton(
                          label: 'RESET GAME DATA',
                          color: GameColors.happyRed,
                          icon: Icons.delete_outline_rounded,
                          size: CartoonButtonSize.medium,
                          expanded: true,
                          onPressed: () => _confirmReset(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CartoonDialog(
        title: 'Reset everything?',
        headerColor: GameColors.happyRed,
        body: Text(
          'This clears settings and any saved progress. This cannot be undone.',
          style: GameFonts.body(),
        ),
        actions: [
          CartoonButton(
            label: 'Cancel',
            color: GameColors.happyBlue,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CartoonButton(
            label: 'Reset',
            color: GameColors.happyRed,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Row(
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
            'Settings',
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
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.trailing});
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return CartoonPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GameFonts.title())),
          trailing,
        ],
      ),
    );
  }
}
