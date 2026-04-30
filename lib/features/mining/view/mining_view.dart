// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // --- ROLLING BALANCE (Inspirasi dari Screenshot Lu) ---
              _buildRollingBalance(prov),
              
              const SizedBox(height: 50),

              // --- ASYNC RUNNING BARS (Garis Cahaya Lari) ---
              _buildCleanRunningBar(color: Colors.orangeAccent, isMining: prov.isMining, offset: 0.0),
              const SizedBox(height: 12),
              _buildCleanRunningBar(color: themeColor, isMining: prov.isMining, offset: 0.4),
              
              const SizedBox(height: 40),

              // --- HASH RATE (Minimalist) ---
              Text(
                prov.isMining ? (prov.isBoostActive ? "15.90 Gh/s" : "8.20 Gh/s") : "0.00 Gh/s",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9), 
                  fontSize: 20, 
                  fontWeight: FontWeight.w200, 
                  fontFamily: 'monospace',
                  letterSpacing: 1
                ),
              ),

              const Spacer(flex: 2),

              // --- ACTION BUTTON ---
              _buildActionArea(prov, themeColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget buat bikin angka nambah secara Rolling/Tumpuk
  Widget _buildRollingBalance(MiningProvider prov) {
    // Simulasi angka saldo yang nambah (Ganti sesuai field saldo lu nanti)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("B ", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18)),
        // Pake AnimatedSwitcher biar angkanya tumpuk pas ganti
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            prov.isMining ? "0.00000431" : "0.00000000",
            key: ValueKey<String>(prov.isMining ? "active" : "idle"), // Key penting buat trigger animasi
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanRunningBar({required Color color, required bool isMining, required double offset}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(height: 4, width: double.infinity, color: color.withOpacity(0.05)),
          if (isMining)
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                double progress = (_shimmerController.value + offset) % 1.0;
                return Positioned(
                  left: (MediaQuery.of(context).size.width * progress) - 120,
                  child: Container(
                    height: 4,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, color.withOpacity(0.5), color.withOpacity(0.8), Colors.transparent],
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
