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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Controller untuk efek detak jantung (Pulse)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF060812),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // --- HEADER ---
            _buildHeader(),
            
            const Spacer(),

            // --- CENTRAL UNIT (MULAI -> CORE) ---
            Center(
              child: GestureDetector(
                onTap: () {
                  if (!prov.isMining) {
                    prov.startMiningSession();
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    // Hanya berdetak kalau belum mining
                    double scale = prov.isMining ? 1.0 : _pulseAnimation.value;
                    
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Glow Detak Jantung (Background Pulse)
                        if (!prov.isMining)
                          Container(
                            width: 220 * scale,
                            height: 220 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                )
                              ],
                            ),
                          ),

                        // 2. Lingkaran Utama / Core Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          height: prov.isMining ? 300 : 220,
                          width: prov.isMining ? 300 : 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: prov.isMining ? Colors.transparent : themeColor.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Visual Partikel (Muncul pas mining)
                              if (prov.isMining)
                                ParticleCoreVisualizer(color: themeColor),

                              // Teks MULAI (Fade Out pas mining)
                              AnimatedOpacity(
                                opacity: prov.isMining ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 400),
                                child: Text(
                                  "MULAI",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32 * (prov.isMining ? 0.5 : 1.0),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const Spacer(),

            // --- STATS BAR (Slide up pas mining) ---
            _buildStatsFooter(prov, themeColor),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text("B-COIN PROTOCOL", style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text("NODE ID: 0xFF229", style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildStatsFooter(MiningProvider prov, Color color) {
    return AnimatedOpacity(
      opacity: prov.isMining ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutExpo,
            builder: (context, val, child) {
              return Text("${val.toStringAsFixed(1)} Gh/s", 
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w200, fontFamily: 'monospace'));
            },
          ),
          const SizedBox(height: 10),
          Text("TIME REMAINING: ${prov.remainingMiningTimeStr}", 
            style: TextStyle(color: color.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

// --- VISUAL PARTICLE CORE (SMOOTH & ORGANIC) ---
class ParticleCoreVisualizer extends StatefulWidget {
  final Color color;
  const ParticleCoreVisualizer({super.key, required this.color});

  @override
  State<ParticleCoreVisualizer> createState() => _ParticleCoreVisualizerState();
}

class _ParticleCoreVisualizerState extends State<ParticleCoreVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: CorePainter(
            time: DateTime.now().millisecondsSinceEpoch / 1000,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class CorePainter extends CustomPainter {
  final double time;
  final Color color;

  CorePainter({required this.time, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.5;

    // 1. Inner Energy Waves
    final wavePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 3; i++) {
      final path = Path();
      for (double a = 0; a <= math.pi * 2; a += 0.1) {
        double r = radius - (i * 15);
        double dist = math.sin(a * 4 + time * (i + 2)) * 8;
        double x = center.dx + (r + dist) * math.cos(a);
        double y = center.dy + (r + dist) * math.sin(a);
        if (a == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, wavePaint);
    }

    // 2. Particle Dust Ring (Banyak & Kecil)
    final random = math.Random(88);
    for (int i = 0; i < 150; i++) {
      double speed = random.nextDouble() * 0.4 + 0.1;
      double orbit = radius + 5 + (random.nextDouble() * 35);
      double angle = (time * speed) + (i * (math.pi * 2 / 150));
      
      double px = center.dx + orbit * math.cos(angle);
      double py = center.dy + orbit * math.sin(angle);

      canvas.drawCircle(
        Offset(px, py), 
        random.nextDouble() * 1.5, 
        Paint()..color = color.withOpacity(random.nextDouble() * 0.5)
      );
    }
  }

  @override
  bool shouldRepaint(CorePainter oldDelegate) => true;
}
