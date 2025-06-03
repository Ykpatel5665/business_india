import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'responsive_layout.dart';

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
        child: ResponsiveLayout(
          mobile: Builder(
            builder: (context) => _LoginProfileContent(
              state: this,
              maxWidth: 420,
            ),
          ),
          tablet: Center(
            child: SizedBox(
              width: 500,
              child: _LoginProfileContent(
                state: this,
                maxWidth: 500,
              ),
            ),
          ),
          desktop: Center(
            child: SizedBox(
              width: 600,
              child: _LoginProfileContent(
                state: this,
                maxWidth: 600,
              ),
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
    final theme = Theme.of(context);
    final selectedAvatarIndex = state.selectedAvatarIndex;
    final _nameController = state._nameController;
    final avatars = state.avatars;
    final isValid = state.isValid;
    return LayoutBuilder(
      builder: (context, constraints) {
        double baseWidth = 390; // iPhone 12/13/14 width as base
        double scale = (constraints.maxWidth / baseWidth).clamp(0.85, 1.5);
        double maxContentWidth = constraints.maxWidth < 700 ? constraints.maxWidth : 600 * scale;
        return Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 24.0 * scale, bottom: 12.0 * scale),
                    child: Image.asset(
                      'assets/loginboard.png',
                      width: (constraints.maxWidth * 0.85).clamp(180.0, 700.0 * scale),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 2 * scale),
                    height: 2 * scale,
                    width: 220 * scale,
                    color: Colors.white.withOpacity(0.25),
                  ),
                  SizedBox(height: 0 * scale),
                  Text(
                    'Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2 * scale,
                      fontSize: (theme.textTheme.titleLarge?.fontSize ?? 24) * scale,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  if (selectedAvatarIndex != null)
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 38 * scale,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 32 * scale,
                            backgroundImage: AssetImage(avatars[selectedAvatarIndex]),
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Text(
                            _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w600,
                              fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    height: 60 * scale,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: avatars.length + 2,
                      separatorBuilder: (_, __) => SizedBox(width: 12 * scale),
                      itemBuilder: (context, index) {
                        if (index == 0 || index == avatars.length + 1) {
                          return SizedBox(width: 18 * scale);
                        }
                        final avatarIdx = index - 1;
                        final isSelected = selectedAvatarIndex == avatarIdx;
                        return GestureDetector(
                          onTap: () {
                            state.selectedAvatarIndex = avatarIdx;
                            (state as dynamic).setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(2 * scale),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.greenAccent : Colors.transparent,
                                width: 2 * scale,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Colors.green.withOpacity(0.18), blurRadius: 8 * scale, offset: Offset(0, 2 * scale))]
                                  : [],
                            ),
                            child: CircleAvatar(
                              radius: isSelected ? 26 * scale : 22 * scale,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: isSelected ? 22 * scale : 18 * scale,
                                backgroundImage: AssetImage(avatars[avatarIdx]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48.0 * scale),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50]?.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(14 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6 * scale,
                            offset: Offset(0, 1 * scale),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _nameController,
                        onChanged: (_) {
                          (state as dynamic).setState(() {});
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10 * scale),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Center(
                    child: GestureDetector(
                      onTap: isValid ? state._saveUserDataAndNavigate : null,
                      child: AnimatedOpacity(
                        opacity: isValid ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 36 * scale, vertical: 10 * scale),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[400],
                            borderRadius: BorderRadius.circular(12 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green[900]!.withOpacity(0.28),
                                offset: Offset(0, 4 * scale),
                                blurRadius: 10 * scale,
                              ),
                            ],
                            border: Border.all(color: Colors.green[800]!, width: 1.5 * scale),
                          ),
                          child: Text(
                            'DONE',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2 * scale,
                              fontSize: (theme.textTheme.titleMedium?.fontSize ?? 18) * scale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        );
      },
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
