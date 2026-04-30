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
  late AnimationController _morphController;

  @override
  void initState() {
    super.initState();
    // Controller buat ngacak-ngacak permukaan bola (morphing)
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
    // Skema warna: Ijo Neon (Normal) -> Ungu Neon (Boost)
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF040508), // Hitam Deep Blue (OLED friendly)
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // --- HEADER (Style Neural) ---
            const Text("NEURAL HASH STREAM", style: TextStyle(color: Colors.white10, letterSpacing: 5, fontSize: 10, fontWeight: FontWeight.bold)),
            
            const Spacer(),

            // --- THE NEURAL SPHERE (VISUAL UTAMA - GAYA SIRI) ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Layer Glow di belakang
                  AnimatedBuilder(
                    animation: _morphController,
                    builder: (context, child) {
                      // Efek napas (pulse) pendaran cahaya
                      double pulse = 0.5 + (math.sin(_morphController.value * math.pi * 2) * 0.1);
                      return Container(
                        width: 220, height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(prov.isMining ? 0.15 * pulse : 0.02),
                              blurRadius: 60, spreadRadius: 10,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Custom Paint buat Bola yang Morphing
                  AnimatedBuilder(
                    animation: _morphController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(280, 280),
                        painter: NeuralSpherePainter(
                          morphValue: _morphController.value,
                          color: themeColor,
                          isMining: prov.isMining,
                          // Turbulensi makin tinggi kalau Boost aktif
                          turbulence: prov.isBoostActive ? 2.5 : 1.0,
                        ),
                      );
                    },
                  ),

                  // Angka Gh/s (Floating in the middle)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutExpo,
                        builder: (context, val, child) {
                          return Text(
                            val.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w100, fontFamily: 'monospace', letterSpacing: -2),
                          );
                        },
                      ),
                      Text("GH/S DATA RATE", style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- INFO & CONTROL INTERFACE ---
            _buildNeuralControls(prov, themeColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuralControls(MiningProvider prov, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Elegant Session Timer
          if (prov.isMining)
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "ACTIVE STREAM // ${prov.remainingMiningTimeStr}",
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ),
            ),
          
          // Action Button (Style Glassmorphism tipis)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: prov.isMining ? Colors.transparent : color,
                foregroundColor: prov.isMining ? color : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: prov.isMining ? color.withOpacity(0.3) : Colors.transparent),
                ),
                elevation: 0,
              ),
              onPressed: () => prov.isMining ? null : prov.startMiningSession(),
              child: Text(
                prov.isMining ? "NEURAL NETWORK ONLINE" : "ENGAGE NEURAL CORE",
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Overclock Action
          InkWell(
            onTap: () => prov.canClaimBoost() ? prov.startBoostSession() : null,
            child: Text(
              prov.isBoostActive ? "OVERCLOCK ACTIVE: ${prov.remainingBoostTimeStr}" : "INITIATE 2X OVERCLOCK // WATCH AD",
              style: TextStyle(
                color: prov.isBoostActive ? const Color(0xFFC154F7) : Colors.white.withOpacity(0.05),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PAINTER UNTUK BOLA SIRI (NEURAL SPHERE) ---
class NeuralSpherePainter extends CustomPainter {
  final double morphValue;
  final Color color;
  final bool isMining;
  final double turbulence; // Tingkat keacakan permukaan

  NeuralSpherePainter({required this.morphValue, required this.color, required this.isMining, required this.turbulence});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2.8;
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Kalau mati, cuma ada pendaran cahaya tipis di tengah
    if (!isMining) {
      canvas.drawCircle(center, baseRadius, paint..color = Colors.white.withOpacity(0.01));
      return;
    }

    // Kita gambar 3 layer bola transparan biar dapet efek Siri yang mewah
    _drawMorphingSphere(canvas, center, baseRadius, paint, color.withOpacity(0.05), 1.0); // Base layer redup
    _drawMorphingSphere(canvas, center, baseRadius - 10, paint, color.withOpacity(0.15), 1.5); // Middle layer
    _drawMorphingSphere(canvas, center, baseRadius - 20, paint, color.withOpacity(0.4), 2.0); // Inner core tajam
  }

  void _drawMorphingSphere(Canvas canvas, Offset center, double radius, Paint paint, Color sphereColor, double speedMultiplier) {
    paint.color = sphereColor;
    final path = Path();
    const int totalPoints = 90; // Jumlah titik koordinat di sekeliling lingkaran

    // Ini kuncinya: Ngerubah radius di tiap titik pake matematika acak (Morphing)
    for (int i = 0; i <= totalPoints; i++) {
      double angle = (i * (360 / totalPoints)) * (math.pi / 180);
      
      // Rumus Morphing Acak (Abstract Wave): Combine multiple Sin/Cos with time
      double time = morphValue * 2 * math.pi * speedMultiplier;
      
      // Kita campur beberapa frekuensi biar dapet bentuk gak beraturan (anti-GIF kaku)
      double morphEffect = 0.0;
      if (isMining) {
        morphEffect = (math.sin(angle * 3 + time) * 8 * turbulence) + 
                     (math.cos(angle * 5 - time * 1.5) * 5 * turbulence) +
                     (math.sin(angle * 2 + time * 2) * 3);
      }

      double finalRadius = radius + morphEffect;

      double x = center.dx + math.cos(angle) * finalRadius;
      double y = center.dy + math.sin(angle) * finalRadius;

      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();

    // Kasih efek glow solid (Siri style)
    if (isMining) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NeuralSpherePainter oldDelegate) => true;
}
