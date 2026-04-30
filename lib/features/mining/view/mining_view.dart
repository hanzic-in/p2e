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
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Controller untuk menggerakkan gelombang cairan
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF080910),
      body: Stack(
        children: [
          // --- LAYER 1: FLUID BACKGROUND (Cairan yang memenuhi layar bawah) ---
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FluidWavePainter(
                    waveValue: _waveController.value,
                    color: themeColor,
                    // Tinggi cairan naik berdasarkan status mining
                    fillLevel: prov.isMining ? (prov.isBoostActive ? 0.45 : 0.35) : 0.2,
                    isMining: prov.isMining,
                  ),
                );
              },
            ),
          ),

          // --- LAYER 2: UI CONTENT ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SYSTEM FLUIDITY", style: TextStyle(color: Colors.white24, letterSpacing: 4, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(prov.isMining ? "STREAMS STABLE" : "PUMP IDLE", style: TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 18)),
                  
                  const Spacer(),

                  // Hash Rate Display (Floating in the middle of fluid)
                  Center(
                    child: Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
                          duration: const Duration(seconds: 1),
                          builder: (context, val, child) {
                            return Text(
                              val.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w100, fontFamily: 'monospace'),
                            );
                          },
                        ),
                        const Text("GH/S OUTPUT", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 5)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // --- ACTION INTERFACE ---
                  _buildFluidControls(prov, themeColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluidControls(MiningProvider prov, Color color) {
    return Column(
      children: [
        if (prov.isMining)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white24, size: 14),
                const SizedBox(width: 8),
                Text(prov.remainingMiningTimeStr, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: prov.isMining ? Colors.white.withOpacity(0.05) : color,
              foregroundColor: prov.isMining ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            onPressed: () => prov.isMining ? null : prov.startMiningSession(),
            child: Text(prov.isMining ? "CORE ACTIVE" : "INITIALIZE PUMP", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        
        const SizedBox(height: 20),
        
        GestureDetector(
          onTap: () => prov.canClaimBoost() ? prov.startBoostSession() : null,
          child: Text(
            prov.isBoostActive ? "OVERCLOCK ACTIVE: ${prov.remainingBoostTimeStr}" : "WATCH AD FOR 2X TURBULENCE",
            style: TextStyle(color: prov.isBoostActive ? const Color(0xFFC154F7) : Colors.white10, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// --- PAINTER UNTUK SIMULASI CAIRAN (FLUID DYNAMICS) ---
class FluidWavePainter extends CustomPainter {
  final double waveValue;
  final Color color;
  final double fillLevel; // 0.0 - 1.0
  final bool isMining;

  FluidWavePainter({required this.waveValue, required this.color, required this.fillLevel, required this.isMining});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double baseHeight = size.height * (1 - fillLevel);

    // Kita gambar 3 lapisan gelombang dengan kecepatan dan opacity berbeda
    _drawWave(canvas, size, paint, color.withOpacity(0.1), waveValue, 20, 1.0); // Gelombang belakang
    _drawWave(canvas, size, paint, color.withOpacity(0.2), waveValue + 0.5, 15, 1.5); // Gelombang tengah
    _drawWave(canvas, size, paint, color.withOpacity(0.4), waveValue + 0.2, 10, 2.0); // Gelombang depan
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, Color waveColor, double animValue, double amplitude, double speed) {
    paint.color = waveColor;
    final path = Path();
    final double baseHeight = size.height * (1 - fillLevel);

    path.moveTo(0, baseHeight);

    // Gambar gelombang menggunakan Sine Wave
    for (double i = 0; i <= size.width; i++) {
      // Logic gejolak: kalau mining, amplitudo gelombang makin berantakan/aktif
      double activeAmplitude = isMining ? (amplitude + math.sin(animValue * 5) * 5) : amplitude;
      
      double y = baseHeight + math.sin((i / size.width * 2 * math.pi) + (animValue * 2 * math.pi * speed)) * activeAmplitude;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Beri efek glow tipis di permukaan air
    if (isMining) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FluidWavePainter oldDelegate) => true;
}
