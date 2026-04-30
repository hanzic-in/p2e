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
  late AnimationController _morphController;

  @override
  void initState() {
    super.initState();
    // Controller buat ngacak-ngacak permukaan bola
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    // Skema warna pekat: Biru Cyan (Normal) -> Ungu Pekat (Boost)
    final themeColor = prov.isBoostActive ? const Color(0xFF9400D3) : const Color(0xFF00FFFF);

    return Scaffold(
      backgroundColor: const Color(0xFF030408),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildHeader(),
            const Spacer(),

            // --- THE CORE INTERFACE ---
            Center(
              child: GestureDetector(
                onTap: () => prov.isMining ? null : prov.startMiningSession(),
                child: AnimatedBuilder(
                  animation: _morphController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Layer 1: Glow Pendaran Luar (Biar Neon)
                        if (prov.isMining)
                          CustomPaint(
                            size: const Size(300, 300),
                            painter: NeonGlowPainter(color: themeColor),
                          ),
                        
                        // Layer 2: Bola Energi Bergejolak (Solid Morphing Core)
                        CustomPaint(
                          size: const Size(280, 280),
                          painter: SolidNeuralCorePainter(
                            morphValue: _morphController.value,
                            color: themeColor,
                            isMining: prov.isMining,
                          ),
                        ),

                        // Layer 3: Teks & Info (Terapung)
                        if (!prov.isMining)
                          const Text("MULAI", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 5)),
                      ],
                    );
                  },
                ),
              ),
            ),

            const Spacer(),
            _buildStatsAndAction(prov, themeColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text("NEURAL NETWORK", style: TextStyle(color: Colors.white12, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold)),
        Text("CORE V3.0", style: TextStyle(color: Colors.white24, fontSize: 8)),
      ],
    );
  }

  Widget _buildStatsAndAction(MiningProvider prov, Color color) {
    return AnimatedOpacity(
      opacity: prov.isMining ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
            duration: const Duration(seconds: 1),
            builder: (context, val, child) {
              return Text("${val.toStringAsFixed(1)} Gh/s", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w100, fontFamily: 'monospace'));
            },
          ),
          const SizedBox(height: 10),
          Text(prov.remainingMiningTimeStr, style: TextStyle(color: color.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- PAINTER 1: PEMDARAN CAHAYA NEON LUAR ---
class NeonGlowPainter extends CustomPainter {
  final Color color;
  NeonGlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.2;

    // Pake Outer blur biar cahayanya memancar keluar bola
    canvas.drawCircle(center, radius, Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 30));
  }
  @override
  bool shouldRepaint(NeonGlowPainter oldDelegate) => true;
}

// --- PAINTER 2: BOLA ENERGI BERGEJOLAK (SOLID) ---
class SolidNeuralCorePainter extends CustomPainter {
  final double morphValue;
  final Color color;
  final bool isMining;

  SolidNeuralCorePainter({required this.morphValue, required this.color, required this.isMining});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.2;

    final path = Path();
    const int totalPoints = 120; // Lebih banyak titik biar gejolaknya alus

    for (int i = 0; i <= totalPoints; i++) {
      double angle = (i * (360 / totalPoints)) * (math.pi / 180);
      
      double morphEffect = 0.0;
      if (isMining) {
        // Rumus Acak Bergejolak (Noise): Gabungan beberapa Sin/Cos dengan waktu
        double time = morphValue * 2 * math.pi;
        morphEffect = (math.sin(angle * 4 + time) * 12) + 
                     (math.cos(angle * 6 - time * 1.5) * 8) +
                     (math.sin(angle * 2 + time * 2) * 5);
      }

      double finalRadius = radius + morphEffect;
      double x = center.dx + math.cos(angle) * finalRadius;
      double y = center.dy + math.sin(angle) * finalRadius;

      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();

    // 2. THE PAINT (Pekat & 3D)
    final spherePaint = Paint()
      ..style = PaintingStyle.fill
      // Pake RadialGradient yang tumpuk-tumpuk biar pekat
      ..shader = RadialGradient(
        colors: [
          Colors.white,              // Putih terang di tengah (core)
          color.withOpacity(0.9),     // Warna pekat (pekat)
          color.withOpacity(0.2),     // Bayangan luar
        ],
        stops: const [0.0, 0.6, 1.0], // Stop-nya digeser biar pekatnya luas
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, spherePaint);
  }

  @override
  bool shouldRepaint(SolidNeuralCorePainter oldDelegate) => true;
}
