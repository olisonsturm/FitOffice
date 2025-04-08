import 'dart:ui';

import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Path? _path;
  PathMetric? _pathMetric;
  Offset? _avatarPosition;

  final int numberOfLevels = 5;
  final List<Offset> _levelOffsets = [];
  late Future<void> _pathInitializationFuture;

  @override
  void initState() {
    super.initState();
    _pathInitializationFuture = _initPath();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() {
      if (_pathMetric != null) {
        final offset = _pathMetric!.getTangentForOffset(
          _pathMetric!.length * _controller.value,
        )?.position;
        setState(() => _avatarPosition = offset);
      }
    });

    // Delay path initialization until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pathInitializationFuture = _initPath();
      });
    });
  }

  Future<void> _initPath() async {
    try {
      print("Initializing path...");
      final size = MediaQuery.of(context).size;
      _path = Path()
        ..moveTo(0, size.height * 0.2)
        ..cubicTo(
          size.width * 0.25,
          size.height * 0.05,
          size.width * 0.75,
          size.height * 0.35,
          size.width,
          size.height * 0.2,
        );

      _pathMetric = _path!.computeMetrics().first;

      // Calculate level offsets
      _levelOffsets.clear();
      for (int i = 0; i < numberOfLevels; i++) {
        final pos = _pathMetric!
            .getTangentForOffset(_pathMetric!.length * (i / (numberOfLevels - 1)))
            ?.position;
        if (pos != null) _levelOffsets.add(pos);
      }

      print("Path initialized successfully.");
      // Start the animation after path initialization
      _controller.repeat(reverse: false);
    } catch (e) {
      print("Error initializing path: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _pathInitializationFuture, // Use the initialized Future
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show a loading indicator until the path is initialized
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Ensure _path and _pathMetric are not null before using them
        if (_path == null || _pathMetric == null) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: const Center(
              child: Text("Error: Path not initialized"),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Stack(
            children: [
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _PathPainter(path: _path!),
              ),
              ..._levelOffsets
                  .map((offset) => Positioned(
                left: offset.dx - 20,
                top: offset.dy - 20,
                child: LevelBubble(),
              ))
                  .toList(),
              if (_avatarPosition != null)
                Positioned(
                  left: _avatarPosition!.dx - 15,
                  top: _avatarPosition!.dy - 15,
                  child: AnimatedAvatar(),
                ),
            ],
          ),
        );
      },
    );
  }
}

// 🎨 The Path Painter
class _PathPainter extends CustomPainter {
  final Path path;
  _PathPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.6),
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.star, color: Colors.white, size: 22),
      ),
    );
  }
}

// 🟠 The Animated Avatar
class AnimatedAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}