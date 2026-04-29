// lib/features/mining/view/mining_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../provider/mining_provider.dart';
import '../../../core/constants/app_colors.dart';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _jitterController;

  @override
  void initState() {
    super.initState();
    _jitterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _jitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final miningProv = Provider.of<MiningProvider>(context);

    double targetValue = miningProv.isMining ? (miningProv.isBoostActive ? 0.85 : 0.45) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C16),
      appBar: AppBar(
        title: const Text("B-COIN MINER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF111422),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _jitterController,
                    builder: (context, child) {
                      double jitter = 0.0;
                      if (miningProv.isMining) {
                        jitter = math.sin(_jitterController.value * math.pi * 2) * 0.015;
                      }

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: (targetValue + jitter).clamp(0.0, 1.0)),
                        duration: Duration(milliseconds: miningProv.isMining ? 150 : 1500),
                        curve: miningProv.isMining ? Curves.linear : Curves.easeOutBack,
                        builder: (context, animValue, child) {
                          return CustomPaint(
                            size: const Size(220, 180),
                            painter: _ModernMiningGaugePainter(
                              value: animValue,
                              isMining: miningProv.isMining,
                              isBoost: miningProv.isBoostActive,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const Text("CURRENT HASH RATE", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: miningProv.isMining ? (miningProv.isBoostActive ? 15.9 : 8.2) : 0),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, val, child) {
                          return Text(
                            val.toStringAsFixed(1),
                            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8, left: 6),
                        child: Text("Gh/s", style: TextStyle(color: Colors.white60, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildAdGatePanel(context, miningProv),
          ],
        ),
      ),
    );
  }

  Widget _buildAdGatePanel(BuildContext context, MiningProvider miningProv) {
    final themeColor = miningProv.isBoostActive ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    return Column(
      children: [
        if (!miningProv.isMining)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: themeColor.withOpacity(0.5)),
                ),
                elevation: 0,
              ),
              onPressed: () {
                miningProv.startMiningSession();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill_rounded, color: themeColor),
                  const SizedBox(width: 12),
                  Text("START MINING SESSION (30m)", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: themeColor, size: 16),
                const SizedBox(width: 8),
                Text("Time Remaining: ${miningProv.remainingMiningTimeStr}", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

        const SizedBox(height: 25),
        _buildSpeedBoostCard(context, miningProv),
      ],
    );
  }

  Widget _buildSpeedBoostCard(BuildContext context, MiningProvider prov) {
    const boostColor = Color(0xFFC154F7);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111422),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: boostColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: boostColor, size: 36),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AD-GAINED SPEED BOOST (2x)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(prov.isBoostActive ? "Boost Active!" : "Watch Ad to double speed (2m)", style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          
          if (prov.isBoostActive)
            Text(prov.remainingBoostTimeStr, style: const TextStyle(color: boostColor, fontWeight: FontWeight.bold))
          else if (!prov.canClaimBoost())
            const Icon(Icons.history_toggle_off_rounded, color: Colors.white12)
          else
            IconButton(
              icon: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF00FFD1)),
              onPressed: () {
                prov.startBoostSession();
              },
            ),
        ],
      ),
    );
  }
}

class _ModernMiningGaugePainter extends CustomPainter {
  final double value;
  final bool isMining;
  final bool isBoost;

  _ModernMiningGaugePainter({required this.value, required this.isMining, required this.isBoost});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const double startAngle = math.pi;
    const double sweepAngle = math.pi;

    final themeColor = isBoost ? const Color(0xFFC154F7) : const Color(0xFF00FFD1);

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;
    
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, trackPaint);

    final tickPaint = Paint()..color = Colors.white10..strokeWidth = 1.5;
    for (int i = 0; i <= 20; i++) {
      final angle = startAngle + (sweepAngle * (i / 20));
      final isMajor = i % 5 == 0;
      final len = isMajor ? 18.0 : 8.0;
      tickPaint.color = isMajor ? Colors.white30 : Colors.white10;

      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * (radius - 5), center.dy + math.sin(angle) * (radius - 5)),
        Offset(center.dx + math.cos(angle) * (radius - 5 - len), center.dy + math.sin(angle) * (radius - 5 - len)),
        tickPaint,
      );
    }

    if (value > 0) {
      final progressPaint = Paint()
        ..color = themeColor.withOpacity(isMining ? 0.8 : 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;
      
      if (isMining) {
        progressPaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
      }

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * value, false, progressPaint);
    }

    final needleAngle = startAngle + (sweepAngle * value);
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    if (isMining) {
      needlePaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleAngle);

    const double needleW = 5.0;
    const double needleL = 100.0;
    
    final needleRect = RRect.fromLTRBAndCorners(
      -5,
      -needleW / 2, 
      needleL, 
      needleW / 2, 
      topLeft: const Radius.circular(1),
      bottomLeft: const Radius.circular(1),
      topRight: const Radius.circular(5),
      bottomRight: const Radius.circular(5),
    );
    canvas.drawRRect(needleRect, needlePaint);
    canvas.restore();

    canvas.drawCircle(center, 15, Paint()..color = const Color(0xFF0A0C16));
    canvas.drawCircle(center, 8, Paint()..color = themeColor.withOpacity(0.5));
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ModernMiningGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isBoost != isBoost || oldDelegate.isMining != isMining;
  }
}
