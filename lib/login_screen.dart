import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'responsive_layout.dart';
import 'dart:math' as math;
import 'ui_components.dart';
import 'app_theme.dart';

// TODO: Import your theme and constants files here

// TODO: Replace these with AppLocalizations lookups when localization is set up.
const kProfileLabel = 'Profile';
const kDoneButton = 'DONE';
const kNameHint = 'Enter your name';
const kNamePlaceholder = 'Your Name';

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int? selectedAvatarIndex;
  final TextEditingController _nameController = TextEditingController();
  bool get isValid =>
      selectedAvatarIndex != null && _nameController.text.trim().length >= 3;

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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarIdx = prefs.getInt('avatarIndex');
    final name = prefs.getString('userName');
    setState(() {
      selectedAvatarIndex = avatarIdx ?? 0;
      _nameController.text = name ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserDataAndNavigate() async {
    if (!isValid) {
      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedAvatarIndex == null
              ? 'Please select an avatar.'
              : 'Please enter a name with at least 3 characters.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    final avatarIdx = selectedAvatarIndex!;
    await prefs.setInt('avatarIndex', avatarIdx);
    await prefs.setString('userName', name);
    // Log to terminal
    print('User selected name: ' + name);
    print('User selected avatar index: ' + avatarIdx.toString());
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/mode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _CheckeredBackground(
        child: ResponsiveLayout(
          mobile: Builder(
            builder:
                (context) => _LoginProfileContent(state: this, maxWidth: 420),
          ),
          tablet: Center(
            child: SizedBox(
              width: 500,
              child: _LoginProfileContent(state: this, maxWidth: 500),
            ),
          ),
          desktop: Center(
            child: SizedBox(
              width: 600,
              child: _LoginProfileContent(state: this, maxWidth: 600),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginProfileContent extends StatelessWidget {
  final _LoginScreenState state;
  final double maxWidth;
  const _LoginProfileContent({required this.state, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final selectedAvatarIndex = state.selectedAvatarIndex;
    final _nameController = state._nameController;
    final avatars = state.avatars;
    final isValid = state.isValid;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fluid, adaptive scaling based on available width and height
        final screenHeight = MediaQuery.of(context).size.height;
        // Use a flexible base width and height for scaling
        double baseWidth = 420.0;
        double baseHeight = 800.0;
        double widthScale = (constraints.maxWidth / baseWidth).clamp(0.7, 1.2);
        double heightScale = (screenHeight / baseHeight).clamp(0.7, 1.2);
        double scale = widthScale < heightScale ? widthScale : heightScale;
        double maxContentWidth = constraints.maxWidth * 0.98;
        return Stack(
          children: [
            // Main scrollable content (behind the clouds)
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
                      SizedBox(height: 0 * scale),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            kProfileLabel,
                            style: AppTextStyles.titleLarge(scale).copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 6 * scale),
                          if (selectedAvatarIndex != null)
                            Column(
                              children: [
                                AvatarDisplay(
                                  imagePath: avatars[selectedAvatarIndex],
                                  outerRadius: 38 * scale,
                                  innerRadius: 32 * scale,
                                ),
                                SizedBox(height: 6 * scale),
                                ProfileNameDisplay(
                                  name: _nameController.text,
                                  scale: scale,
                                ),
                              ],
                            ),
                          SizedBox(height: 12 * scale),
                          AvatarSelector(
                            avatars: avatars,
                            selectedIndex: selectedAvatarIndex,
                            scale: scale,
                            onAvatarTap: (avatarIdx) {
                              state.selectedAvatarIndex = avatarIdx;
                              (state as dynamic).setState(() {});
                            },
                          ),
                          SizedBox(height: 16 * scale),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.cardPadding(scale) * 2.7,
                            ),
                            child: CustomTextField(
                              controller: _nameController,
                              scale: scale,
                              onChanged: (_) {
                                (state as dynamic).setState(() {});
                              },
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          Center(
                            child: PrimaryButton(
                              label: kDoneButton,
                              scale: scale,
                              onTap: isValid ? state._saveUserDataAndNavigate : null,
                              enabled: isValid,
                            ),
                          ),
                          SizedBox(height: 24 * scale),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Clouds around the header (randomized positions)
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
              initialTop: 200 * scale, // moved lower from 120
              left: 40 * scale, // moved right from 0
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
      },
    );
  }
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

class _FloatingCloudState extends State<_FloatingCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11), // Slower and smoother
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
              child:
                  widget.asset.endsWith('.svg')
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
