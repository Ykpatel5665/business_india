import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'responsive_layout.dart';
import 'dart:math' as math;
import 'app_theme.dart';
import 'widgets/background_widgets.dart';
import 'constants/avatars.dart';
import 'widgets/avatar_display.dart';
import 'widgets/profile_name_display.dart';
import 'widgets/avatar_selector.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/primary_button.dart';
import 'widgets/login_board_header.dart';

// TODO: Import your theme and constants files here

// TODO: Replace these with AppLocalizations lookups when localization is set up.
const kProfileLabel = 'Profile';
const kDoneButton = 'DONE';
const kNameHint = 'Enter your name';
const kNamePlaceholder = 'Your Name';

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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService.loadProfile();
    setState(() {
      selectedAvatarIndex = profile.avatarIndex;
      _nameController.text = profile.name;
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
    final name = _nameController.text.trim();
    final avatarIdx = selectedAvatarIndex!;
    await ProfileService.saveProfile(avatarIndex: avatarIdx, name: name);
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
      body: CheckeredBackground(
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

class ProfileAvatarSection extends StatelessWidget {
  final int? selectedAvatarIndex;
  final TextEditingController nameController;
  final double scale;
  const ProfileAvatarSection({
    required this.selectedAvatarIndex,
    required this.nameController,
    required this.scale,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedAvatarIndex == null) return const SizedBox.shrink();
    return Column(
      children: [
        AvatarDisplay(
          imagePath: avatars[selectedAvatarIndex!],
          outerRadius: 38 * scale,
          innerRadius: 32 * scale,
        ),
        SizedBox(height: 6 * scale),
        ProfileNameDisplay(
          name: nameController.text,
          scale: scale,
        ),
      ],
    );
  }
}

class AvatarSelectorSection extends StatelessWidget {
  final int? selectedAvatarIndex;
  final double scale;
  final void Function(int) onAvatarTap;
  const AvatarSelectorSection({
    required this.selectedAvatarIndex,
    required this.scale,
    required this.onAvatarTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarSelector(
      avatars: avatars,
      selectedIndex: selectedAvatarIndex,
      scale: scale,
      onAvatarTap: onAvatarTap,
    );
  }
}

class NameInputSection extends StatelessWidget {
  final TextEditingController nameController;
  final double scale;
  final void Function(String) onChanged;
  const NameInputSection({
    required this.nameController,
    required this.scale,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding(scale) * 2.7,
      ),
      child: CustomTextField(
        controller: nameController,
        scale: scale,
        onChanged: onChanged,
      ),
    );
  }
}

class DoneButtonSection extends StatelessWidget {
  final bool isValid;
  final double scale;
  final VoidCallback? onTap;
  const DoneButtonSection({
    required this.isValid,
    required this.scale,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PrimaryButton(
        label: kDoneButton,
        scale: scale,
        onTap: isValid ? onTap : null,
        enabled: isValid,
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
                          ProfileAvatarSection(
                            selectedAvatarIndex: selectedAvatarIndex,
                            nameController: _nameController,
                            scale: scale,
                          ),
                          SizedBox(height: 12 * scale),
                          AvatarSelectorSection(
                            selectedAvatarIndex: selectedAvatarIndex,
                            scale: scale,
                            onAvatarTap: (avatarIdx) {
                              state.selectedAvatarIndex = avatarIdx;
                              (state as dynamic).setState(() {});
                            },
                          ),
                          SizedBox(height: 16 * scale),
                          NameInputSection(
                            nameController: _nameController,
                            scale: scale,
                            onChanged: (_) {
                              (state as dynamic).setState(() {});
                            },
                          ),
                          SizedBox(height: 16 * scale),
                          DoneButtonSection(
                            isValid: isValid,
                            scale: scale,
                            onTap: state._saveUserDataAndNavigate,
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
            FloatingCloud(
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
            FloatingCloud(
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
            FloatingCloud(
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
            FloatingCloud(
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
