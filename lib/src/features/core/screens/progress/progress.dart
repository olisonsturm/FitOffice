import 'dart:ui';

import 'package:fit_office/src/constants/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  ProgressScreenState createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Path? _path;
  PathMetric? _pathMetric;
  Offset? _avatarPosition;

  final int numberOfLevels = 5;
  final List<Offset> _levelOffsets = [];
  late Future<void> _pathInitializationFuture;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    //_pathInitializationFuture = _initPath();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() {
        if (_pathMetric != null) {
          final offset = _pathMetric!
              .getTangentForOffset(
                _pathMetric!.length * _controller.value,
              )
              ?.position;
          setState(() => _avatarPosition = offset);
        }
      });

    // Delay path initialization until after the first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   setState(() {
    //     //_pathInitializationFuture = _initPath();
    //   });
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _pathInitializationFuture = _initPath();
      _initialized = true;
    }
  }

  Future<void> _initPath() async {
    try {
      if (kDebugMode) {
        print("Initializing path...");
      }

      final size = MediaQuery.of(context).size;
      final double startX = size.width * 0.1;
      final double endX = size.width * 0.9;
      final double heightStep = size.height * 0.2; // Höhe bleibt konstant

      // Beginne den Pfad an einem festen Punkt
      _path = Path()..moveTo(startX, size.height * 0.1);

      for (int i = 0; i < numberOfLevels - 1; i++) {
        // Konstanten y-Werte für die Kurvenhöhe
        final double y1 = size.height * 0.1 + heightStep * i;
        final double y2 = y1 + heightStep;

        // Alterniere zwischen Start- und End-X
        final double x1 = (i % 2 == 0) ? endX : startX;
        final double xMid = (startX + endX) / 2;

        // Kurve erstellen mit konstanten Steuerelementen
        _path!.cubicTo(
          x1, y1 + heightStep * 0.3, // Kontrollpunkt 1
          x1, y1 + heightStep * 0.7, // Kontrollpunkt 2
          xMid, y2, // Endpunkt
        );
      }

      _pathMetric = _path!.computeMetrics().first;

      // Berechne die Level-Offsets
      _levelOffsets.clear();
      for (int i = 0; i < numberOfLevels; i++) {
        final pos = _pathMetric!
            .getTangentForOffset(
                _pathMetric!.length * (i / (numberOfLevels - 1)))
            ?.position;
        if (pos != null) _levelOffsets.add(pos);
      }

      if (kDebugMode) {
        print("Path initialized successfully.");
      }

      // Initialisierung abgeschlossen, aber Animation bleibt pausiert
      _controller.value = 0.0; // Setze die Animation auf den Startpunkt
      _moveToNextLevel();
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing path: $e");
      }
    }
  }

  void _moveToNextLevel() {
    if (_controller.isAnimating || _controller.value >= 1.0) return;

    final nextStep =
        (_controller.value + 1.0 / (numberOfLevels - 1)).clamp(0.0, 1.0);
    _controller.animateTo(nextStep, duration: const Duration(seconds: 1));
  }

  // Updated advanceStep to trigger fox animation
  void advanceStep() {
    if (_controller.isAnimating) return;

    final nextStep = _controller.value + 1.0 / (numberOfLevels - 1);

    setState(() {
      _controller.value = nextStep.clamp(0.0, 1.0);
    });

    // Trigger step animation
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder(
      future: _pathInitializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: isDarkMode ? tBlackColor : Colors.grey[100],
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_path == null || _pathMetric == null) {
          return Scaffold(
            backgroundColor: isDarkMode ? tBlackColor : Colors.grey[100],
            body: const Center(child: Text("Error: Path not initialized")),
          );
        }

        final size = MediaQuery.of(context).size;
        final canvasHeight = size.height * 1.5; // größerer Bereich für Scroll

        return Scaffold(
          backgroundColor: isDarkMode ? tBlackColor : Colors.grey[100],
          body: SingleChildScrollView(
            child: SizedBox(
              height: canvasHeight,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(size.width, canvasHeight),
                    painter: _PathPainter(path: _path!, isDarkMode: isDarkMode),
                  ),
                  ..._levelOffsets.map((offset) => Positioned(
                        left: offset.dx - 50,
                        top: offset.dy - 50,
                        child: LevelBubble(isDarkMode: isDarkMode),
                      )),
                  if (_avatarPosition != null)
                    Positioned(
                      left: _avatarPosition!.dx - 50,
                      top: _avatarPosition!.dy - 50,
                      child: const AnimatedAvatar(),
                    ),
                  Positioned(
                    bottom: 20,
                    left: size.width * 0.5 - 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.deepPurple
                            : const Color(0xFFE30613),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        side: BorderSide.none,
                      ),
                      onPressed: _moveToNextLevel,
                      child: const Text('Next Level',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🎨 The Path Painter
class _PathPainter extends CustomPainter {
  final Path path;
  final bool isDarkMode;

  _PathPainter({required this.path, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.white24 : const Color(0x33333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🟣 A "Level Bubble"
class LevelBubble extends StatelessWidget {
  final bool isDarkMode;

  const LevelBubble({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.deepPurple : const Color(0xFFE30613),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.deepPurpleAccent : Colors.redAccent)
                .withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.school, color: Colors.white, size: 48),
      ),
    );
  }
}

// 🟠 The Animated Avatar
class AnimatedAvatar extends StatelessWidget {
  const AnimatedAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: tBottomNavBarSelectedColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrangeAccent.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.pets, color: Colors.white, size: 50),
      ),
    );
  }
}
