// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mining_provider.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with TickerProviderStateMixin {
  // Controller buat animasi "cahaya lari" di dalem bar
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
      backgroundColor: const Color(0xFF05060B), // Back to Black sangar
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("OPERATIONAL DASHBOARD", style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // --- HEADER STATS ---
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: themeColor, size: 40),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15900 : 8200) : 0),
                        duration: const Duration(seconds: 1),
                        builder: (context, val, child) {
                          return Text(
                            "${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} H/s",
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                          );
                        },
                      ),
                      const Text("CURRENT NETWORK LOAD", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- DYNAMIC PROGRESS BARS (Sesuai mau lu Han) ---
              _buildRunningProgressBar(
                label: "SESSION PROCESS",
                color: Colors.orangeAccent,
                isMining: prov.isMining,
                progress: 0.8, // Misal sesi udah jalan 80%
              ),
              
              const SizedBox(height: 25),

              _buildRunningProgressBar(
                label: "MINING STABILITY",
                color: themeColor,
                isMining: prov.isMining,
                progress: 0.6,
              ),

              const SizedBox(height: 50),

              // --- ACTION BUTTON ---
              _buildMainButton(prov, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunningProgressBar({required String label, required Color color, required bool isMining, required double progress}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            if (isMining) 
              Text("${(progress * 100).toInt()}%", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              // Background Bar Kosong
              Container(height: 8, width: double.infinity, color: Colors.white.withOpacity(0.03)),
              
              // Bar Progress Utama
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 8,
                width: MediaQuery.of(context).size.width * (isMining ? progress : 0.05),
                decoration: BoxDecoration(
                  color: isMining ? color.withOpacity(0.3) : Colors.white10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // CAHAYA LARI (The "Loading" effect)
              if (isMining)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned(
                      left: (MediaQuery.of(context).size.width * _shimmerController.value) - 100,
                      child: Container(
                        height: 8,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, color.withOpacity(0.8), Colors.transparent],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(MiningProvider prov, Color themeColor) {
    return InkWell(
      onTap: () => prov.isMining ? null : prov.startMiningSession(),
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: prov.isMining ? Colors.transparent : themeColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: prov.isMining ? Colors.redAccent.withOpacity(0.5) : Colors.transparent),
        ),
        child: Center(
          child: Text(
            prov.isMining ? "ABORT SESSION" : "INITIATE SYSTEM",
            style: TextStyle(
              color: prov.isMining ? Colors.redAccent : Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
