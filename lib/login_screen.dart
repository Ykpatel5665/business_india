import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// TODO: Import your theme and constants files here

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int? selectedAvatarIndex;
  final TextEditingController _nameController = TextEditingController();
  bool get isValid => selectedAvatarIndex != null && _nameController.text.trim().length >= 3;

  final List<String> avatars = [
    // TODO: Replace with your asset paths
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserDataAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    final avatarIdx = selectedAvatarIndex!;
    await prefs.setInt('avatarIndex', avatarIdx);
    await prefs.setString('userName', name);
    // Log to terminal
    print('User selected name: ' + name);
    print('User selected avatar index: ' + avatarIdx.toString());
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // Add a playful, game-style gradient background
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB2FEFA), // Light blue
                  Color(0xFF0ED2F7), // Sky blue
                  Color(0xFF4A90E2), // Deeper blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animate the card like a floating cloud
          Center(
            child: _AnimatedFloatingCard(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Choose Your Avatar', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            children: List.generate(avatars.length, (index) {
                              final isSelected = selectedAvatarIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => selectedAvatarIndex = index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutBack,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.25) : Colors.transparent,
                                        blurRadius: 24.0,
                                        spreadRadius: 2.0,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary.withOpacity(0.18),
                                              theme.colorScheme.secondary.withOpacity(0.12),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                  ),
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.18 : 1.0,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutBack,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 44,
                                          backgroundColor: isSelected
                                              ? Colors.amber.withOpacity(0.18)
                                              : Colors.white,
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundImage: AssetImage(avatars[index]),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            bottom: 6,
                                            right: 6,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.amber.withOpacity(0.5),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(Icons.check, color: Colors.white, size: 18),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Enter your name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 32),
                          AnimatedOpacity(
                            opacity: isValid ? 1.0 : 0.5,
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: isValid
                                  ? _saveUserDataAndNavigate
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                textStyle: theme.textTheme.titleLarge,
                                elevation: 6,
                              ),
                              child: const Text('Continue'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated floating card widget
class _AnimatedFloatingCard extends StatefulWidget {
  final Widget child;
  const _AnimatedFloatingCard({required this.child});

  @override
  State<_AnimatedFloatingCard> createState() => _AnimatedFloatingCardState();
}

class _AnimatedFloatingCardState extends State<_AnimatedFloatingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 18).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
