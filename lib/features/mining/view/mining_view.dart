// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../provider/mining_provider.dart';
import '../../../core/constants/app_colors.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _coreController;

  @override
  void initState() {
    super.initState();
    _coreController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _coreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final miningProv = Provider.of<MiningProvider>(context);
    final themeColor = miningProv.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildTopStatus(miningProv, themeColor),
            
            const Expanded(
              child: Center(
                child: HexCoreVisualizer(), // Visual Utama Tanpa Jarum
              ),
            ),

            _buildStatsAndAction(miningProv, themeColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatus(MiningProvider prov, Color color) {
    return Column(
      children: [
        Text(prov.isMining ? "MINING IN PROGRESS" : "SYSTEM STANDBY",
          style: TextStyle(color: color.withOpacity(0.5), fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (prov.isMining)
          Text(prov.remainingMiningTimeStr, 
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w200, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildStatsAndAction(MiningProvider prov, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, val, child) {
                  return Text(val.toStringAsFixed(1), 
                    style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900));
                },
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 8),
                child: Text("Gh/s", style: TextStyle(color: Colors.white24, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: prov.isMining ? Colors.white.withOpacity(0.05) : color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: () => prov.isMining ? null : prov.startMiningSession(),
              child: Text(prov.isMining ? "CORE ACTIVE" : "ACTIVATE CORE",
                style: TextStyle(color: prov.isMining ? Colors.white38 : Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => prov.canClaimBoost() ? prov.startBoostSession() : null,
            child: Text(
              prov.isBoostActive ? "OVERCLOCK ACTIVE: ${prov.remainingBoostTimeStr}" : "WATCH AD FOR 2X OVERCLOCK",
              style: TextStyle(color: prov.isBoostActive ? const Color(0xFFC154F7) : Colors.white10, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class HexCoreVisualizer extends StatefulWidget {
  const HexCoreVisualizer({super.key});

  @override
  State<HexCoreVisualizer> createState() => _HexCoreVisualizerState();
}

class _HexCoreVisualizerState extends State<HexCoreVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final color = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: HexCorePainter(
            progress: _controller.value,
            color: color,
            isMining: prov.isMining,
          ),
        );
      },
    );
  }
}

class HexCorePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isMining;

  HexCorePainter({required this.progress, required this.color, required this.isMining});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(isMining ? 0.8 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (isMining) paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);

    // 1. Gambar Hexagon Utama di Tengah
    _drawHexagon(canvas, center, 60 * (isMining ? (1.0 + math.sin(progress * math.pi * 2) * 0.05) : 1.0), paint);

    // 2. Gambar Partikel Orbit (Muter)
    if (isMining) {
      final particlePaint = Paint()..color = color;
      for (int i = 0; i < 12; i++) {
        double angle = (progress * 2 * math.pi) + (i * (math.pi * 2 / 12));
        double distance = 100 + (math.sin(progress * 4 * math.pi + i) * 10);
        canvas.drawCircle(
          Offset(center.dx + math.cos(angle) * distance, center.dy + math.sin(angle) * distance),
          2,
          particlePaint..color = color.withOpacity((1.0 - (i / 12)).clamp(0, 1)),
        );
      }
    }

    // 3. Lingkaran Scanner Tipis
    final scannerPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 120, scannerPaint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60) * (math.pi / 180) - (math.pi / 2);
      Offset point = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      if (i == 0) path.moveTo(point.dx, point.dy);
      else path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexCorePainter oldDelegate) => true;
}
