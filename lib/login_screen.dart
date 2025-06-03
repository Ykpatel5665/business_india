import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Import your theme and constants files here

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
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7), Color(0xFF4A90E2)],
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
      backgroundColor: Colors.transparent,
      body: _CheckeredBackground(
        child: Stack(
          children: [
            // Clouds (placeholders)
            Positioned(
              top: 40,
              left: 24,
              child: _Cloud(size: 60),
            ),
            Positioned(
              top: 100,
              right: 32,
              child: _Cloud(size: 40),
            ),
            Positioned(
              bottom: 80,
              left: 40,
              child: _Cloud(size: 50),
            ),
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Logo/title image (responsive, higher and larger)
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double maxWidth = constraints.maxWidth;
                            double imageWidth = maxWidth * 0.7;
                            if (imageWidth < 200) imageWidth = 200;
                            if (imageWidth > 420) imageWidth = 420;
                            return Image.asset(
                              'assets/loginboard.png',
                              width: imageWidth,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        height: 2,
                        width: 220,
                        color: Colors.white.withOpacity(0.25),
                      ),
                      const SizedBox(height: 0),
                      // Profile header (shifted up)
                      Text(
                        'Profile',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Selected avatar (centered, larger)
                      if (selectedAvatarIndex != null)
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundImage: AssetImage(avatars[selectedAvatarIndex!]),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      // Avatar horizontal list
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: avatars.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 18),
                          itemBuilder: (context, index) {
                            final isSelected = selectedAvatarIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => selectedAvatarIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.greenAccent : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: Colors.green.withOpacity(0.25), blurRadius: 12, offset: Offset(0, 4))]
                                      : [],
                                ),
                                child: CircleAvatar(
                                  radius: isSelected ? 38 : 32,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: isSelected ? 34 : 28,
                                    backgroundImage: AssetImage(avatars[index]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Name input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: TextField(
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
                      ),
                      const SizedBox(height: 24),
                      // 3D green DONE button
                      GestureDetector(
                        onTap: isValid ? _saveUserDataAndNavigate : null,
                        child: AnimatedOpacity(
                          opacity: isValid ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent[400],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green[900]!.withOpacity(0.35),
                                  offset: const Offset(0, 6),
                                  blurRadius: 16,
                                ),
                              ],
                              border: Border.all(color: Colors.green[800]!, width: 2),
                            ),
                            child: Text(
                              'DONE',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double size;
  const _Cloud({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.18,
            top: size * 0.18,
            child: Container(
              width: size * 0.5,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size * 0.16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
