import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'responsive_layout.dart';
import 'ui_components.dart';
import 'app_theme.dart';
import 'l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String? _selectedMode;
  int? _avatarIndex;
  final List<String> avatars = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatar5.png',
    'assets/avatar6.png',
    'assets/avatar7.png',
    'assets/avatar8.png',
    'assets/avatar9.png',
    'assets/avatar10.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvatarIndex();
  }

  Future<void> _loadAvatarIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarIndex = prefs.getInt('avatarIndex') ?? 0;
    });
  }

  void _onModeSelected(String mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  void _onProceed(BuildContext context) {
    if (_selectedMode == null || _selectedMode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.selectGameMode, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Proceed to next screen or logic
    Navigator.pushNamed(context, '/player');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _CheckeredBackground(
        child: ResponsiveLayout(
          mobile: Builder(
            builder: (context) => _ModeSelectionContent(
              maxWidth: 420,
              selectedMode: _selectedMode,
              onModeTap: _onModeSelected,
              onProceed: () => _onProceed(context),
              avatarIndex: _avatarIndex,
              avatarPath: _avatarIndex != null ? avatars[_avatarIndex!.clamp(0, avatars.length - 1)] : avatars[0],
            ),
          ),
          tablet: Center(
            child: SizedBox(
              width: 500,
              child: _ModeSelectionContent(
                maxWidth: 500,
                selectedMode: _selectedMode,
                onModeTap: _onModeSelected,
                onProceed: () => _onProceed(context),
                avatarIndex: _avatarIndex,
                avatarPath: _avatarIndex != null ? avatars[_avatarIndex!.clamp(0, avatars.length - 1)] : avatars[0],
              ),
            ),
          ),
          desktop: Center(
            child: SizedBox(
              width: 600,
              child: _ModeSelectionContent(
                maxWidth: 600,
                selectedMode: _selectedMode,
                onModeTap: _onModeSelected,
                onProceed: () => _onProceed(context),
                avatarIndex: _avatarIndex,
                avatarPath: _avatarIndex != null ? avatars[_avatarIndex!.clamp(0, avatars.length - 1)] : avatars[0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeSelectionContent extends StatelessWidget {
  final double maxWidth;
  final String? selectedMode;
  final ValueChanged<String> onModeTap;
  final VoidCallback onProceed;
  final int? avatarIndex;
  final String avatarPath;
  const _ModeSelectionContent({
    required this.maxWidth,
    required this.selectedMode,
    required this.onModeTap,
    required this.onProceed,
    required this.avatarIndex,
    required this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    double baseWidth = 420.0;
    double baseHeight = 800.0;
    double widthScale = (maxWidth / baseWidth).clamp(0.7, 1.2);
    double heightScale = (screenHeight / baseHeight).clamp(0.7, 1.2);
    double scale = widthScale < heightScale ? widthScale : heightScale;
    double maxContentWidth = maxWidth * 0.98;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
                minHeight: screenHeight * 0.98,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Use only the reusable LoginBoardHeader for consistent image and spacing
                  LoginBoardHeader(
                    maxContentWidth: maxContentWidth,
                    scale: scale,
                  ),
                  SizedBox(height: 12 * scale),
                  // Remove extra SizedBox above and below
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile avatar (left, now tappable for editing)
                      Tooltip(
                        message: AppStrings.editProfileTooltip, // Add this string to l10n.dart if not present
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: AvatarDisplay(
                            imagePath: avatarPath,
                            outerRadius: 22 * scale,
                            innerRadius: 18 * scale,
                            showBorder: true,
                            borderColor: Colors.white,
                            borderWidth: 2 * scale,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 6 * scale,
                                offset: Offset(0, 2 * scale),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Friends and Settings icons (right)
                      Row(
                        children: [
                          IconButton(
                            icon: CircleAvatar(
                              radius: 20 * scale,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.group, color: Colors.blue[800], size: 24 * scale),
                            ),
                            tooltip: AppStrings.friendsTooltip,
                            onPressed: () {},
                          ),
                          SizedBox(width: 8 * scale),
                          IconButton(
                            icon: CircleAvatar(
                              radius: 20 * scale,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.settings, color: Colors.blue[800], size: 24 * scale),
                            ),
                            tooltip: AppStrings.settingsTooltip,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  // Game mode options in a 2x2 grid
                  Row(
                    children: [
                      Expanded(
                        child: GameModeButton(
                          color: Color(0xFFB620E0), // Purple for solo
                          icon: Icons.computer,
                          title: AppStrings.soloChallenge,
                          onTap: () => onModeTap('solo'),
                          scale: scale,
                          selected: selectedMode == 'solo',
                          semanticLabel: AppStrings.soloChallenge,
                        ),
                      ),
                      SizedBox(width: 18 * scale),
                      Expanded(
                        child: GameModeButton(
                          color: Color(0xFF00C853), // Green for local multiplayer
                          icon: Icons.devices,
                          title: AppStrings.localMultiplayer,
                          onTap: () => onModeTap('local'),
                          scale: scale,
                          selected: selectedMode == 'local',
                          semanticLabel: AppStrings.localMultiplayer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: GameModeButton(
                          color: Color(0xFF2979FF), // Blue for global match
                          icon: Icons.public,
                          title: AppStrings.globalMatch,
                          onTap: () => onModeTap('global'),
                          scale: scale,
                          selected: selectedMode == 'global',
                          semanticLabel: AppStrings.globalMatch,
                        ),
                      ),
                      SizedBox(width: 18 * scale),
                      Expanded(
                        child: GameModeButton(
                          color: Color(0xFFFFC400), // Yellow for private room
                          icon: Icons.group_add,
                          title: AppStrings.privateRoom,
                          onTap: () => onModeTap('private'),
                          scale: scale,
                          selected: selectedMode == 'private',
                          semanticLabel: AppStrings.privateRoom,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  ElevatedButton(
                    onPressed: onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.button(scale),
                      minimumSize: Size(double.infinity, 48 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius(scale)),
                      ),
                    ),
                    child: Text(AppStrings.continueBtn),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Clouds (reuse from login)
        _FloatingCloud(
          initialTop: 8 * scale,
          left: 40 * scale,
          right: null,
          width: 312 * scale,
          height: 182 * scale,
          asset: 'assets/cloud1.svg',
          opacity: 0.85,
          scale: scale,
          phase: 0,
        ),
        _FloatingCloud(
          initialTop: 60 * scale,
          left: null,
          right: 10 * scale,
          width: 240 * scale,
          height: 140 * scale,
          asset: 'assets/cloud2.svg',
          opacity: 0.8,
          scale: scale,
          phase: 1,
        ),
        _FloatingCloud(
          initialTop: 200 * scale,
          left: 40 * scale,
          right: null,
          width: 180 * scale,
          height: 110 * scale,
          asset: 'assets/cloud3.svg',
          opacity: 0.7,
          scale: scale,
          phase: 2,
        ),
        _FloatingCloud(
          initialTop: 200 * scale,
          left: null,
          right: 60 * scale,
          width: 160 * scale,
          height: 100 * scale,
          asset: 'assets/cloud4.svg',
          opacity: 0.75,
          scale: scale,
          phase: 3,
        ),
      ],
    );
  }
}

// Copied from login_screen.dart for reuse
class _CheckeredBackground extends StatelessWidget {
  final Widget child;
  const _CheckeredBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckeredPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent, AppColors.primary, AppColors.background],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _CheckeredPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 64;
    final paint1 = Paint()..color = Colors.white.withOpacity(0.07);
    final paint2 = Paint()..color = Colors.white.withOpacity(0.13);
    for (int y = 0; y < size.height / squareSize; y++) {
      for (int x = 0; x < size.width / squareSize; x++) {
        final paint = (x + y) % 2 == 0 ? paint1 : paint2;
        canvas.drawRect(
          Rect.fromLTWH(x * squareSize, y * squareSize, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingCloud extends StatefulWidget {
  final double initialTop;
  final double? left;
  final double? right;
  final double width;
  final double height;
  final String asset;
  final double opacity;
  final double scale;
  final int phase;

  const _FloatingCloud({
    required this.initialTop,
    this.left,
    this.right,
    required this.width,
    required this.height,
    required this.asset,
    required this.opacity,
    required this.scale,
    required this.phase,
    Key? key,
  }) : super(key: key);

  @override
  State<_FloatingCloud> createState() => _FloatingCloudState();
}

class _FloatingCloudState extends State<_FloatingCloud> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value * 2 * math.pi;
        double floatOffset;
        switch (widget.phase) {
          case 0:
            floatOffset = 10.0 * widget.scale * math.sin(t);
            break;
          case 1:
            floatOffset = 10.0 * widget.scale * math.cos(t);
            break;
          case 2:
            floatOffset = 10.0 * widget.scale * math.sin(t + 1);
            break;
          case 3:
            floatOffset = 10.0 * widget.scale * math.cos(t + 1);
            break;
          default:
            floatOffset = 0.0;
        }
        return Positioned(
          top: widget.initialTop * widget.scale + floatOffset,
          left: widget.left,
          right: widget.right,
          child: Opacity(
            opacity: widget.opacity,
            child: Transform(
              transform: Matrix4.identity()..scale(widget.scale, widget.scale),
              alignment: Alignment.center,
              child: widget.asset.endsWith('.svg')
                  ? SvgPicture.asset(
                      widget.asset,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      widget.asset,
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
    );
  }
}
