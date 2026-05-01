import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mining_provider.dart';
import 'dart:async';
import 'dart:math' as math;

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  Timer? _balanceTimer; 
  int _balanceInt = 0;
  
  String formatBalance(int value) {
    final str = value.toString().padLeft(14, '0');
    final whole = str.substring(0, 1);
    final decimal = str.substring(1);
    return "$whole.$decimal";
  }
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _balanceTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      final prov = Provider.of<MiningProvider>(context, listen: false);
      if (prov.isMining) {
        final random = math.Random();
        setState(() {
          _balanceInt += math.Random().nextInt(99) + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _balanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
    // Token in-game color: Electric Cyan
    final tokenColor = const Color(0xFF00E5FF); 
    final boostColor = const Color(0xFFC154F7);
    final activeThemeColor = prov.isBoostActive ? boostColor : tokenColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1116),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. MAIN MINING PANEL (TOP SECTION) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F26),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("D-COIN CLOUD MINING", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Icon(Icons.bolt_rounded, color: Colors.orangeAccent, size: 18),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // In-Game Token Balance Section
                    _buildTokenBalance(prov, tokenColor),
                    
                    const SizedBox(height: 35),

                    // --- LOADING STREAMS (LARI ASINKRON) ---
                    _buildStreamBar(color: Colors.orangeAccent, isMining: prov.isMining, offset: 0.0),
                    const SizedBox(height: 12),
                    _buildStreamBar(color: activeThemeColor, isMining: prov.isMining, offset: 0.5),

                    const SizedBox(height: 25),

                    // Hashrate Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          prov.isMining ? (prov.isBoostActive ? "15.90 Gh/s" : "8.20 Gh/s") : "0.00 Gh/s",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9), 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            fontFamily: 'monospace'
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- 2. TIMER ACTION BUTTON (30 MINS LOGIC) ---
              _buildTimerButton(prov, activeThemeColor),

              const SizedBox(height: 15),
              const Center(
                child: Text(
                  "Session length: 30m. System will auto-suspend after timeout.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ),

              const SizedBox(height: 30),

              // --- 3. REWARD CARDS (NO FAQ) ---
              Row(
                children: [
                  Expanded(child: _buildRewardCard("Daily Check-in", "5.0 Gh/s", activeThemeColor)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildRewardCard("Ad-Boost", "12.5 Gh/s", activeThemeColor)),
                ],
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenBalance(MiningProvider prov, Color color) {
  String formatted = formatBalance(_balanceInt);

  return Column(
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo D
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.5), width: 1.5)
              ),
              child: Text("D", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Row(
  mainAxisSize: MainAxisSize.min,
  children: formatted.split('').asMap().entries.map<Widget>((entry) { 
    final index = entry.key;
    final char = entry.value;
    final num = int.tryParse(char);

    if (num == null) {
      return Text(char, style: const TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900,
      ));
    }
    return RollingDigit(
      key: ValueKey('digit-$index'),
      digit: num,
      speed: 5.0 + (index * 2.0),
    );
  }).toList(),
),

          ],
        ),
      ),
      const SizedBox(height: 4),
      Text("TOTAL D-COIN EARNED", style: TextStyle(color: color.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
    ],
  );
}


  
  Widget _buildStreamBar({required Color color, required bool isMining, required double offset}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(height: 4, width: double.infinity, color: Colors.white.withOpacity(0.02)),
          if (isMining)
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                double progress = (_shimmerController.value + offset) % 1.0;
                return Positioned(
                  left: (MediaQuery.of(context).size.width * progress) - 150,
                  child: Container(
                    height: 4,
                    width: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, color.withOpacity(0.5), color.withOpacity(0.9), Colors.transparent],
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

  Widget _buildTimerButton(MiningProvider prov, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: prov.isMining ? Colors.transparent : color,
          foregroundColor: prov.isMining ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: prov.isMining ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
          ),
          elevation: 0,
        ),
        onPressed: () {
          if (!prov.isMining) {
            prov.startMiningSession();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(prov.isMining ? Icons.timer_outlined : Icons.play_arrow_rounded, size: 20),
            const SizedBox(width: 10),
            Text(
              prov.isMining ? prov.remainingMiningTimeStr : "START MINING SESSION",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 35,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Center(child: Text("CLAIM", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );
  }

}

class RollingDigit extends StatefulWidget {
  final int digit;
  final double speed; // putaran per detik (higher = faster)
  const RollingDigit({
    required this.digit,
    this.speed = 8.0, // default 8 putaran/detik
    super.key,
  });

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Posisi "virtual" — bisa 1.5, 2.3, etc (bukan integer)
  double _position = 0.0;
  double _targetPosition = 0.0;
  
  static const double _h = 36;
  static const double _w = 20;

  @override
  void initState() {
    super.initState();
    _position = widget.digit.toDouble();
    _targetPosition = widget.digit.toDouble();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    _controller.addListener(_onTick);
  }

  @override
  void didUpdateWidget(covariant RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      // Naikkan target — bisa loncat banyak angka
      double diff = (widget.digit - oldWidget.digit + 10) % 10;
      if (diff == 0) diff = 10; // minimal 1 putaran
      _targetPosition += diff;
    }
  }

  void _onTick() {
    // Lerp ke target dengan kecepatan
    double delta = (_targetPosition - _position) * 0.15;
    
    // Minimal movement biar gak stuck
    if (delta.abs() < 0.01 && _position != _targetPosition) {
      delta = (_targetPosition > _position) ? 0.05 : -0.05;
    }
    
    setState(() {
      _position += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extract fractional part untuk posisi Y
    double fraction = _position - _position.floor();
    int currentDigit = _position.floor() % 10;
    int nextDigit = (currentDigit + 1) % 10;
    
    return SizedBox(
      width: _w,
      height: _h,
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // TRAIL / BLUR — angka yang sudah lewat (ghosting)
            ..._buildTrails(),
            
            // CURRENT — angka utama (sedang keluar ke atas)
            Transform.translate(
              offset: Offset(0, -fraction * _h),
              child: Opacity(
                opacity: 1 - fraction,
                child: _digitText(currentDigit, isMain: true),
              ),
            ),
            
            // NEXT — angka berikutnya (masuk dari bawah)
            Transform.translate(
              offset: Offset(0, (1 - fraction) * _h),
              child: Opacity(
                opacity: fraction,
                child: _digitText(nextDigit, isMain: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTrails() {
  List<Widget> trails = [];
  double frac = _position - _position.floor();
  
  for (int i = 1; i <= 3; i++) {
    int trailDigit = (_position.floor() - i) % 10;
    double trailOffset = (-frac - i) * _h;
    double trailOpacity = math.max(0, 0.3 - (i * 0.08));
    
    if (trailOpacity > 0) {
      trails.add(
        Transform.translate(
          offset: Offset(0, trailOffset),
          child: Opacity(
            opacity: trailOpacity,
            child: _digitText(trailDigit, isMain: false, blur: i.toDouble()),
          ),
        ),
      );
    }
  }
  
  return trails;
}


  Widget _digitText(int digit, {required bool isMain, double blur = 0}) {
    return SizedBox(
      height: _h,
      width: _w,
      child: Center(
        child: Text(
          '$digit',
          style: TextStyle(
            fontSize: isMain ? 22 : 18,
            fontWeight: isMain ? FontWeight.w900 : FontWeight.w500,
            fontFamily: 'monospace',
            color: isMain 
              ? Colors.white 
              : Colors.white.withOpacity(0.4),
            shadows: isMain ? null : [
              Shadow(
                blurRadius: blur * 2,
                color: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
