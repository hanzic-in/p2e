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
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Buat muter teks kinetik di background
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // --- KINETIC VISUALIZER AREA ---
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Decorative Kinetic Circles (Muter Pelan)
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(300, 300),
                            painter: KineticTextPainter(color: themeColor.withOpacity(0.1)),
                          ),
                        );
                      },
                    ),

                    // 2. Main Hash Counter (Typography Fokus)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("STREAMS ACTIVE", 
                          style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        
                        // Angka Utama dengan Animasi Rolling
                        _buildRollingNumber(
                          prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0.0,
                          themeColor,
                        ),
                        
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(4)),
                          child: const Text("GH/S", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM CONTROL INTERFACE ---
            _buildKineticControls(prov, themeColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRollingNumber(double value, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, val, child) {
        return Text(
          val.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            letterSpacing: -4,
            shadows: [
              Shadow(color: color.withOpacity(0.5), blurRadius: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKineticControls(MiningProvider prov, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Elegant Timer
          if (prov.isMining)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "SESSION EXPIRES IN: ${prov.remainingMiningTimeStr}",
                style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace', letterSpacing: 1),
              ),
            ),
          
          // Action Button - Minimalist Kinetic Style
          GestureDetector(
            onTap: () => prov.isMining ? null : prov.startMiningSession(),
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: prov.isMining ? Colors.white10 : color, width: 2),
                borderRadius: BorderRadius.circular(0), // Kotak kaku khas Kinetic UI
              ),
              child: Center(
                child: Text(
                  prov.isMining ? "SYSTEM RUNNING" : "ENGAGE MINING UNIT",
                  style: TextStyle(
                    color: prov.isMining ? Colors.white24 : color,
                    fontWeight: FontWeight.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Boost Action
          InkWell(
            onTap: () => prov.canClaimBoost() ? prov.startBoostSession() : null,
            child: Text(
              prov.isBoostActive ? "OVERCLOCK ON // ${prov.remainingBoostTimeStr}" : "INITIATE 2X BOOST",
              style: TextStyle(
                color: prov.isBoostActive ? const Color(0xFFC154F7) : Colors.white10,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PAINTER UNTUK TEKS DEKORATIF YANG MUTER ---
class KineticTextPainter extends CustomPainter {
  final Color color;
  KineticTextPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const text = " • NEXUS PROTOCOL • DATA MINING • BLOCKCHAIN STREAM • ";
    const textStyle = TextStyle(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 4);
    
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // Gambar teks dalam lingkaran
    for (int i = 0; i < text.length; i++) {
      double angle = (i * (360 / text.length)) * (math.pi / 180);
      canvas.save();
      canvas.translate(center.dx + 130 * math.cos(angle), center.dy + 130 * math.sin(angle));
      canvas.rotate(angle + (math.pi / 2));
      
      textPainter.text = TextSpan(text: text[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    // Tambah garis crosshair tipis
    final linePaint = Paint()..color = Colors.white.withOpacity(0.02)..strokeWidth = 1;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
