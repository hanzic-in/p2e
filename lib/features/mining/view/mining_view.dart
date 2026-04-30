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

class _MiningViewState extends State<MiningView> with TickerProviderStateMixin {
  late AnimationController _shockwaveController;

  @override
  void initState() {
    super.initState();
    // Controller untuk dentuman (shockwave) yang keluar terus menerus
    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shockwaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF04060F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text("SYSTEM STATUS: ONLINE", style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 4)),
            
            const Spacer(),

            // --- THE CORE UNIT ---
            Center(
              child: GestureDetector(
                onTap: () => prov.isMining ? null : prov.startMiningSession(),
                child: AnimatedBuilder(
                  animation: _shockwaveController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(320, 320),
                      painter: ShockwaveCorePainter(
                        waveValue: _shockwaveController.value,
                        color: themeColor,
                        isMining: prov.isMining,
                        time: DateTime.now().millisecondsSinceEpoch / 1000,
                      ),
                    );
                  },
                ),
              ),
            ),

            const Spacer(),

            // --- SPEED INFO ---
            _buildSpeedSection(prov, themeColor),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedSection(MiningProvider prov, Color color) {
    return AnimatedOpacity(
      opacity: prov.isMining ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          if (!prov.isMining) 
            const Text("TAP TO INITIALIZE", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
            duration: const Duration(seconds: 1),
            builder: (context, val, child) {
              return Text("${val.toStringAsFixed(1)} Gh/s", 
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w100, fontFamily: 'monospace'));
            },
          ),
          if (prov.isMining)
             Text(prov.remainingMiningTimeStr, style: TextStyle(color: color.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ShockwaveCorePainter extends CustomPainter {
  final double waveValue; // 0.0 to 1.0 dari controller
  final Color color;
  final bool isMining;
  final double time;

  ShockwaveCorePainter({required this.waveValue, required this.color, required this.isMining, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 4;

    // 1. EFEK DENTUMAN (Shockwaves yang memancar keluar)
    if (isMining) {
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 3; i++) {
        // Offset tiap gelombang biar gantian
        double currentWave = (waveValue + (i * 0.33)) % 1.0;
        double radius = baseRadius + (currentWave * 100);
        double opacity = (1.0 - currentWave).clamp(0.0, 1.0);

        wavePaint.color = color.withOpacity(opacity * 0.4);
        canvas.drawCircle(center, radius, wavePaint);
      }
    } else {
      // Efek standby (detak halus)
      double standbyPulse = 1.0 + (math.sin(time * 3) * 0.05);
      canvas.drawCircle(center, baseRadius * standbyPulse, Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.stroke..strokeWidth = 1);
        
      // Teks MULAI di dalem (Manual Draw biar presisi tengah)
      const textStyle = TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900);
      final textPainter = TextPainter(text: const TextSpan(text: "MULAI", style: textStyle), textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // 2. THE 3D SPHERE (Biar bulet berisi)
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8), // Kilauan cahaya di tengah (highlight)
          color.withOpacity(0.5),        // Warna inti
          color.withOpacity(0.1),        // Bayangan luar
        ],
        stops: const [0.0, 0.4, 1.0],
        center: const Alignment(-0.3, -0.3), // Cahaya datang dari pojok kiri atas biar 3D
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawCircle(center, baseRadius, spherePaint);

    // 3. PARTICLE DUST (Muter-muter di dalem dan sekitar bola)
    if (isMining) {
      final random = math.Random(123);
      for (int i = 0; i < 60; i++) {
        double angle = (time * (random.nextDouble() * 2)) + i;
        double dist = baseRadius + (random.nextDouble() * 40 - 20);
        double px = center.dx + math.cos(angle) * dist;
        double py = center.dy + math.sin(angle) * dist;
        
        canvas.drawCircle(Offset(px, py), random.nextDouble() * 2, Paint()..color = color.withOpacity(random.nextDouble()));
      }
    }
  }

  @override
  bool shouldRepaint(ShockwaveCorePainter oldDelegate) => true;
}
