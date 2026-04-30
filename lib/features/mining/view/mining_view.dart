// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../provider/mining_provider.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  State<MiningView> createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: NeuralCorePainter(_controller.value),
              size: const Size(300, 300),
            );
          },
        ),
      ),
    );
  }
}

class NeuralCorePainter extends CustomPainter {
  final double animationValue;
  NeuralCorePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // 1. Lapisan Glow Luar (Aura)
    final outerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.blueAccent.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
    canvas.drawCircle(center, radius * 1.5, outerGlow);

    // 2. Efek Gelombang Energi (Plasma)
    for (int i = 0; i < 3; i++) {
      final waveValue = (animationValue + (i * 0.3)) % 1.0;
      final waveRadius = radius * (0.8 + (waveValue * 0.4));
      final wavePaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(1.0 - waveValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, waveRadius, wavePaint);
    }

    // 3. Inti Bola (The Core)
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.blueAccent,
          Colors.black,
        ],
        stops: const [0.1, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Memberikan efek distorsi kecil pada radius inti
    final pulse = 5 * math.sin(animationValue * 2 * math.pi);
    canvas.drawCircle(center, radius + pulse, corePaint);
  }

  @override
  bool shouldRepaint(NeuralCorePainter oldDelegate) => true;
}
