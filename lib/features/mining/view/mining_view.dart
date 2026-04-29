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

                  _buildAnimatedVga(_fanController, miningProv),

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
  double jitter = 0.0;
  if (prov.isMining) {
    jitter = (math.sin(DateTime.now().millisecondsSinceEpoch / 150) * 0.012);
  }

  double baseTarget = prov.isMining ? (prov.isBoostActive ? 0.8 : 0.4) : 0.0;
  final double targetValue = (baseTarget + jitter).clamp(0.0, 1.0);
  
  return Container(
    height: 260,
    width: double.infinity,
    alignment: Alignment.center,
    child: Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: targetValue),
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
          builder: (context, animValue, child) {
            return CustomPaint(
              size: const Size(200, 200),
              painter: MiningGaugePainter(
                value: animValue, 
                isBoost: prov.isBoostActive
              ),
            );
          },
        ),
        
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("MINING SPEED", 
              style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: prov.isMining ? (prov.isBoostActive ? 15.9 : 8.2) : 0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, val, child) {
                    return Text(
                      val.toStringAsFixed(1), 
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'monospace')
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 4),
                  child: Text("Gh/s", style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 35),
          ],
        ),
      ],
    ),
  );
}




class MiningGaugePainter extends CustomPainter {
  final double value;
  final bool isBoost;
  
  MiningGaugePainter({required this.value, required this.isBoost});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final math.Random random = math.Random();
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1D2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * 0.8, math.pi * 1.4, false, bgPaint);

    final tickPaint = Paint()..color = Colors.white10..strokeWidth = 1.5;
    const int totalTicks = 30;
    for (int i = 0; i <= totalTicks; i++) {
      final double tickAngle = (math.pi * 0.8) + (math.pi * 1.4 * (i / totalTicks));
      final double innerRadius = radius - 15;
      final double outerRadius = (i % 5 == 0) ? radius : radius - 8;
      tickPaint.color = (i % 5 == 0) ? Colors.white30 : Colors.white10;

      canvas.drawLine(
        Offset(center.dx + math.cos(tickAngle) * innerRadius, center.dy + math.sin(tickAngle) * innerRadius),
        Offset(center.dx + math.cos(tickAngle) * outerRadius, center.dy + math.sin(tickAngle) * outerRadius),
        tickPaint,
      );
    }

    if (value > 0) {
      final progressPaint = Paint()
        ..color = isBoost ? const Color(0xFFC154F7) : const Color(0xFF00FFD1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.butt;
      
      progressPaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.8,
        math.pi * 1.4 * value,
        false,
        progressPaint,
      );
    }

    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double angle = (math.pi * 0.8) + (math.pi * 1.4 * value);
    
    final needlePath = Path();
    final double needleLength = radius - 10;
    final double needleWidth = 6.0;
    
    needlePath.moveTo(center.dx + math.cos(angle - 0.05) * needleWidth, center.dy + math.sin(angle - 0.05) * needleWidth);
    needlePath.lineTo(center.dx + math.cos(angle + 0.05) * needleWidth, center.dy + math.sin(angle + 0.05) * needleWidth);
    
    needlePath.lineTo(
      center.dx + math.cos(angle) * needleLength,
      center.dy + math.sin(angle) * needleLength,
    );
    needlePath.close();
    
    needlePaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);
    canvas.drawPath(needlePath, needlePaint);
    
    canvas.drawCircle(center, 12, Paint()..color = const Color(0xFF121420));
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


