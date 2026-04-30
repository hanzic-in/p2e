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
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    final themeColor = prov.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Scaffold(
      backgroundColor: const Color(0xFF030407),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Pindah ke tengah
            children: [
              const Spacer(flex: 3),

              // --- MINIMALIST PROGRESS BARS (ASYNC LARI) ---
              _buildCleanRunningBar(color: Colors.orangeAccent, isMining: prov.isMining, offset: 0.0),
              const SizedBox(height: 12),
              _buildCleanRunningBar(color: themeColor, isMining: prov.isMining, offset: 0.4), // Beda timing lari
              
              const SizedBox(height: 40),

              // --- SMALLER HASH RATE INFO (GAK KEGEDEAN) ---
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15900 : 8200) : 0),
                duration: const Duration(seconds: 1),
                builder: (context, val, child) {
                  return Text(
                    "${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} H/s",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9), 
                      fontSize: 22, // Ukuran pas, gak lebay
                      fontWeight: FontWeight.w200, 
                      fontFamily: 'monospace',
                      letterSpacing: 1
                    ),
                  );
                },
              ),
              
              if (prov.isMining) ...[
                const SizedBox(height: 10),
                Text(
                  prov.remainingMiningTimeStr,
                  style: const TextStyle(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ],

              const Spacer(flex: 2),

              // --- ABORT/START BUTTON ---
              _buildActionArea(prov, themeColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanRunningBar({required Color color, required bool isMining, required double offset}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          // Background Bar Full Redup
          Container(height: 4, width: double.infinity, color: color.withOpacity(0.05)),
          
          // Cahaya Lari (Logic Asinkron pake Offset)
          if (isMining)
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                // Modifikasi progress biar tiap bar punya posisi beda
                double progress = (_shimmerController.value + offset) % 1.0;
                
                return Positioned(
                  left: (MediaQuery.of(context).size.width * progress) - 120,
                  child: Container(
                    height: 4,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent, 
                          color.withOpacity(0.5), 
                          color.withOpacity(0.8), // Inti cahaya
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionArea(MiningProvider prov, Color color) {
    return InkWell(
      onTap: () => prov.isMining ? null : prov.startMiningSession(),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: prov.isMining ? Colors.redAccent.withOpacity(0.3) : color.withOpacity(0.3)),
          color: prov.isMining ? Colors.transparent : color.withOpacity(0.02),
        ),
        child: Text(
          prov.isMining ? "ABORT SESSION" : "INITIALIZE SYSTEM",
          style: TextStyle(
            color: prov.isMining ? Colors.redAccent.withOpacity(0.7) : color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
