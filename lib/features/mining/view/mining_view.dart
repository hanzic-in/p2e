// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mining_provider.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9), // Putih keabu-abuan bersih kayak referensi
      appBar: AppBar(
        title: const Text("MINING DASHBOARD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER INFO (ICON + HASHRATE) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
              ),
              child: Row(
                children: [
                  // Icon Speedometer Biru (Kayak screenshot)
                  _buildSpeedIcon(),
                  const SizedBox(width: 15),
                  
                  // Angka Hashrate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15900 : 8200) : 0),
                          duration: const Duration(seconds: 1),
                          builder: (context, val, child) {
                            return Text(
                              "${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} H/s",
                              style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- PROGRESS BARS SECTION ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // 1. Progress Bar Orange (Mining Session)
                  _buildLinearProgress(
                    label: "SESSION PROGRESS",
                    value: prov.isMining ? 0.75 : 0.0, // Ganti pake logic sisa waktu lu Han
                    color: Colors.orangeAccent,
                  ),
                  
                  const SizedBox(height: 20),

                  // 2. Progress Bar Biru (Stability/Network)
                  _buildLinearProgress(
                    label: "NETWORK STABILITY",
                    value: prov.isMining ? 0.45 : 0.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- ACTION BUTTON ---
            _buildActionButton(prov),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedIcon() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const Icon(Icons.speed_rounded, color: Colors.blueAccent, size: 45),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
          ],
        )
      ],
    );
  }

  Widget _buildLinearProgress({required String label, required double value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            ),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: 10,
              width: MediaQuery.of(context).size.width * value,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(MiningProvider prov) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: prov.isMining ? Colors.redAccent.withOpacity(0.1) : Colors.blueAccent,
          foregroundColor: prov.isMining ? Colors.redAccent : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => prov.isMining ? null : prov.startMiningSession(),
        child: Text(
          prov.isMining ? "STOP MINING SESSION" : "START MINING",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
