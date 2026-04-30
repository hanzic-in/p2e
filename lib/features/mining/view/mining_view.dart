// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../provider/mining_provider.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Controller utama yang jalan terus tanpa henti
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00D1FF); // Biru cyan kayak referensi

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text("ENERGY CORE STATUS: ACTIVE", style: TextStyle(color: Colors.white10, letterSpacing: 4, fontSize: 10, fontWeight: FontWeight.bold)),
            
            const Expanded(
              child: Center(
                child: ParticleCoreVisualizer(),
              ),
            ),

            // --- INFO DISPLAY ---
            _buildStatsAndAction(prov, themeColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsAndAction(MiningProvider prov, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, val, child) {
              return Text(
                "${val.toStringAsFixed(1)} GH/S",
                style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w100, fontFamily: 'monospace'),
              );
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: prov.isMining ? Colors.white.withOpacity(0.05) : color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              onPressed: () => prov.isMining ? null : prov.startMiningSession(),
              child: Text(prov.isMining ? "CORE STABILIZED" : "IGNITE CORE",
                style: TextStyle(color: prov.isMining ? Colors.white24 : Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleCoreVisualizer extends StatefulWidget {
  const ParticleCoreVisualizer({super.key});

  @override
  State<ParticleCoreVisualizer> createState() => _ParticleCoreVisualizerState();
}

class _ParticleCoreVisualizerState extends State<ParticleCoreVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final color = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00D1FF);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: CorePainter(
            time: DateTime.now().millisecondsSinceEpoch / 1000,
            color: color,
            isMining: prov.isMining,
            pulse: _pulseController.value,
          ),
        );
      },
    );
  }
}

class CorePainter extends CustomPainter {
  final double time;
  final Color color;
  final bool isMining;
  final double pulse;

  CorePainter({required this.time, required this.color, required this.isMining, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // 1. Layer Glow Belakang (Pendaran Cahaya)
    final glowPaint = Paint()
      ..color = color.withOpacity(isMining ? 0.15 * pulse : 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, radius, glowPaint);

    // 2. Main Sphere Core (Bola Kaca Transparan)
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.0), color.withOpacity(0.2)],
        stops: const [0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    // 3. Garis Orbit Bergelombang (Inner Waves)
    if (isMining) {
      final wavePaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      for (int i = 0; i < 3; i++) {
        final path = Path();
        for (double angle = 0; angle <= math.pi * 2; angle += 0.1) {
          double r = radius - 5 - (i * 10);
          double distortion = math.sin(angle * 3 + time * (i + 1)) * 5;
          double x = center.dx + (r + distortion) * math.cos(angle);
          double y = center.dy + (r + distortion) * math.sin(angle);
          if (angle == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, wavePaint);
      }
    }

    // 4. THE PARTICLE RING (Cincin Debu Cahaya - Rahasia Biar Gak Kayak GIF)
    final random = math.Random(42); // Seed dikunci biar partikel nggak loncat-loncat liar
    final particlePaint = Paint()..style = PaintingStyle.fill;

    int particleCount = isMining ? 150 : 30;
    for (int i = 0; i < particleCount; i++) {
      // Logic pergerakan partikel: Setiap partikel punya orbit unik
      double speed = random.nextDouble() * 0.5 + 0.2;
      double orbitRadius = radius + 20 + (random.nextDouble() * 30);
      double angle = (time * speed) + (i * (math.pi * 2 / particleCount));
      
      // Kasih sedikit goyangan vertikal/horizontal
      double offset = math.sin(time + i) * 10;
      
      double px = center.dx + (orbitRadius + offset) * math.cos(angle);
      double py = center.dy + (orbitRadius + offset) * math.sin(angle);

      double pSize = random.nextDouble() * 2.0;
      particlePaint.color = color.withOpacity(random.nextDouble() * 0.8);
      
      // Partikel makin terang kalau deket "kamera" (simulasi 3D)
      if (math.sin(angle) > 0) {
         canvas.drawCircle(Offset(px, py), pSize, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CorePainter oldDelegate) => true;
}
