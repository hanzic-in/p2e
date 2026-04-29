import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../provider/mining_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class MiningView extends StatefulWidget {
  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _fanController;

  @override
  void initState() {
    super.initState();
    _fanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), 
    );
  }

  @override
  void dispose() {
    _fanController.dispose();
    super.dispose();
  }

  void _showRewardedAd(BuildContext context, Function onAdWatched) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text("Menonton Iklan...", style: TextStyle(color: Colors.white)),
        content: const Text("Halah, ceritanya ini iklan video 30 detik.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAdWatched();
            },
            child: const Text("REWARD DITERIMA"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final miningProv = Provider.of<MiningProvider>(context);
    if (miningProv.isMining) {
      _fanController.duration = miningProv.isBoostActive 
          ? const Duration(milliseconds: 250) 
          : const Duration(milliseconds: 500);
      _fanController.repeat();
    } else {
      _fanController.stop();
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text("B-COIN MINING PANEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        miningProv.minedCoinBalance.toStringAsFixed(4),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text(" B-COIN", style: TextStyle(color: Colors.white38, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _buildAnimatedVga(_fanController),

                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${miningProv.currentHashRate.toStringAsFixed(1)} B-Coin/jam",
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        miningProv.isMining ? miningProv.remainingMiningTimeStr : "STANDBY",
                        style: TextStyle(
                          color: miningProv.isMining ? AppColors.primaryGreen : Colors.white24,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            if (!miningProv.isMining)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    _showRewardedAd(context, () {
                      miningProv.startMiningSession();
                    });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ondemand_video_rounded, color: Colors.black, size: 20),
                      SizedBox(width: 10),
                      Text("Tonton Iklan & Mulai Mining (30m)", 
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // --- PANEL FREE REWARD SPEED BOOST ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("FREE SPEED BOOST! (2x)", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text("Tonton iklan buat dapet kecepatan ganda selama 2 menit.", 
                          style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                  if (miningProv.isBoostActive)
                    Text(miningProv.remainingBoostTimeStr, 
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
                  else if (!miningProv.canClaimBoost())
                    const Icon(Icons.history_toggle_off_rounded, color: Colors.white12)
                  else
                    IconButton(
                      icon: const Icon(Icons.gif_box_rounded, color: AppColors.primaryGreen),
                      onPressed: () {
                        _showRewardedAd(context, () {
                          miningProv.startBoostSession();
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FUNGSI WIDGET VGA ANIMASI ---
Widget _buildAnimatedVga(AnimationController controller) {
  return Container(
    height: 120,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white10),
      // Contoh background grid atau texture VGA
      image: const DecorationImage(
        image: AssetImage('assets/images/vga_body.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        // Kipas Kiri
        Positioned(
          top: 30, left: 50,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * 2 * math.pi,
                child: child,
              );
            },
            child: Image.asset('assets/images/vga_fan.png', height: 60),
          ),
        ),
        // Kipas Kanan
        Positioned(
          top: 30, right: 50,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * 2 * math.pi,
                child: child,
              );
            },
            child: Image.asset('assets/images/vga_fan.png', height: 60),
          ),
        ),
        const Positioned(
          bottom: 10, left: 15,
          child: Text("B-COIN MINER v1.0", style: TextStyle(color: Colors.amber, fontSize: 8, fontFamily: 'Courier')),
        ),
      ],
    ),
  );
}
