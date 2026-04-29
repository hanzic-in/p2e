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
Widget _buildAnimatedVga(AnimationController controller, MiningProvider prov) {
  return Container(
    height: 220,
    width: double.infinity,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(220, 220),
          painter: MiningGaugePainter(
            value: prov.isMining ? (prov.isBoostActive ? 0.8 : 0.4) : 0.0,
          ),
        ),
        
        Positioned(
          bottom: 20,
          child: Column(
            children: [
              const Text("MINING SPEED", 
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    prov.isMining ? (prov.isBoostActive ? "15.9" : "8.2") : "0", 
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 4),
                    child: Text("Gh/s", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MiningGaugePainter extends CustomPainter {
  final double value;
  MiningGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    paint.color = Colors.white10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.8,
      math.pi * 1.4,
      false,
      paint,
    );

    if (value > 0) {
      paint.color = Colors.greenAccent.withOpacity(0.5);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.8,
        math.pi * 1.4 * value,
        false,
        paint,
      );
    }

    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double angle = (math.pi * 0.8) + (math.pi * 1.4 * value);
    
    final needlePath = Path();
    final needleLen = radius - 20;
    final tailLen = 10.0;
    
    needlePath.moveTo(
      center.dx + math.cos(angle) * needleLen,
      center.dy + math.sin(angle) * needleLen,
    );
    needlePath.lineTo(
      center.dx + math.cos(angle + 0.1) * tailLen,
      center.dy + math.sin(angle + 0.1) * tailLen,
    );
    needlePath.lineTo(
      center.dx + math.cos(angle - 0.1) * tailLen,
      center.dy + math.sin(angle - 0.1) * tailLen,
    );
    needlePath.close();    
    canvas.drawPath(needlePath, needlePaint);
    canvas.drawCircle(center, 5, needlePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

