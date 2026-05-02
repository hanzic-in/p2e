import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/mining_provider.dart';
import 'dart:async';
import 'dart:math' as math;

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState()State createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  Timer? _balanceTimer;
  
  // PENTING: Gunakan fixed-point arithmetic (satuan terkecil)
  // Daripada int besar yang loncat, pakai increment kecil & konsisten
  int _balanceInt = 0;
  
  String formatBalance(int value) {
    // Format: X.XXXXXXXX (1 digit whole + 8 decimal)
    final str = value.toString().padLeft(9, '0');
    final whole = str.substring(0, 1);
    final decimal = str.substring(1);
    return "$whole.$decimal";
  }

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Timer lebih cepat untuk update balance, tapi increment kecil
    _balanceTimer = Timer.periodic(
      const Duration(milliseconds: 800), // Lebih sering, increment lebih kecil
      (timer) {
        final prov = Provider.of<MiningProvider>(context, listen: false);
        if (prov.isMining && mounted) {
          // Increment kecil & konsisten (simulasi satoshi)
          // 1-5 satoshi per 800ms = terlihat realistis
          final increment = 1 + math.Random().nextInt(4);
          setState(() {
            _balanceInt += increment;
          });
        }
      },
    );
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
    final tokenColor = const Color(0xFF00E5FF); 
    final boostColor = const Color(0xFFC154F7);
    final activeThemeColor = prov.isBoostActive ? boostColor : tokenColor;
    final formatted = formatBalance(_balanceInt);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1116),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        Text("D-COIN CLOUD MINING", 
                          style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Icon(Icons.bolt_rounded, color: Colors.orangeAccent, size: 18),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // PENTING: Gunakan const key untuk prevent unnecessary rebuild
                    _buildTokenBalance(formatted, tokenColor),
                    
                    const SizedBox(height: 35),
                    _buildStreamBar(color: Colors.orangeAccent, isMining: prov.isMining, offset: 0.0),
                    const SizedBox(height: 12),
                    _buildStreamBar(color: activeThemeColor, isMining: prov.isMining, offset: 0.5),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          prov.isMining 
                            ? (prov.isBoostActive ? "15.90 Gh/s" : "8.20 Gh/s") 
                            : "0.00 Gh/s",
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

  Widget _buildTokenBalance(String formatted, Color color) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    return Text(
                      char,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28, // Perbesar untuk proporsi
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        height: 1.0,
                      ),
                    );
                  }

                  // PENTING: Key unik yang stabil berdasarkan posisi digit
                  return SlotDigit(
                    key: ValueKey('digit-$index'),
                    digit: num,
                    delayMs: index * 40, // Delay berdasarkan posisi (ripple effect)
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text("TOTAL D-COIN EARNED", 
          style: TextStyle(color: color.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                        colors: [
                          Colors.transparent, 
                          color.withOpacity(0.5), 
                          color.withOpacity(0.9), 
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
            side: prov.isMining 
              ? BorderSide(color: Colors.white.withOpacity(0.1)) 
              : BorderSide.none,
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
            child: Center(
              child: Text("CLAIM", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))
            ),
          )
        ],
      ),
    );
  }
}

// ============================================
// SLOT DIGIT - VERSI STABIL & SMOOTH
// ============================================
class SlotDigit extends StatefulWidget {
  final int digit;
  final int delayMs;
  
  const SlotDigit({
    required this.digit, 
    this.delayMs = 0, 
    super.key
  });

  @override
  State<SlotDigit> createState() => _SlotDigitState();
}

class _SlotDigitState extends State<SlotDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  late int _displayDigit;
  int? _queuedDigit;
  bool _isRolling = false;

  static const double _itemHeight = 32.0;
  static const double _itemWidth = 18.0;

  @override
  void initState() {
    super.initState();
    _displayDigit = widget.digit;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // Sedikit lebih lambat = lebih smooth
    );

    _animation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: Curves.easeOutCubic, // Lebih natural
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SlotDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Hanya proses kalau digit benar-benar berbeda
    if (widget.digit != oldWidget.digit) {
      _handleDigitChange(widget.digit);
    }
  }

  void _handleDigitChange(int newDigit) {
    if (_isRolling) {
      // Queue digit terbaru, overwrite yang lama
      _queuedDigit = newDigit;
      return;
    }
    _startRoll(newDigit);
  }

  Future<void> _startRoll(int targetDigit) async {
    if (!mounted) return;
    
    // Delay berbasis posisi untuk efek ripple
    if (widget.delayMs > 0) {
      await Future.delayed(Duration(milliseconds: widget.delayMs));
    }
    
    if (!mounted || targetDigit == _displayDigit) return;

    setState(() => _isRolling = true);

    // Hitung jarak terpendek (contoh: 9->1 lebih baik roll backward)
    int diff = targetDigit - _displayDigit;
    if (diff > 5) diff -= 10;
    if (diff < -5) diff += 10;
    
    final steps = diff.abs();
    final direction = diff > 0 ? 1 : -1;

    for (int i = 0; i < steps; i++) {
      if (!mounted) break;
      
      final nextDigit = (_displayDigit + direction + 10) % 10;
      
      // Reset controller untuk animasi baru
      _controller.reset();
      await _controller.forward();
      
      if (!mounted) break;
      
      setState(() {
        _displayDigit = nextDigit;
      });
      
      // Jeda antar step - semakin cepat = semakin "kacau" tapi seru
      await Future.delayed(const Duration(milliseconds: 60));
    }

    if (!mounted) return;
    
    setState(() => _isRolling = false);

    // Proses queue kalau ada
    if (_queuedDigit != null && _queuedDigit != _displayDigit) {
      final next = _queuedDigit!;
      _queuedDigit = null;
      _startRoll(next);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung next digit untuk animasi
    final nextDigit = (_displayDigit + 1) % 10;
    final prevDigit = (_displayDigit - 1 + 10) % 10;
    
    return SizedBox(
      width: _itemWidth,
      height: _itemHeight,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final offset = _animation.value * _itemHeight;
            
            return Stack(
              children: [
                // Digit saat ini (bergerak keluar)
                Transform.translate(
                  offset: Offset(0, offset),
                  child: _digitBox(_displayDigit),
                ),
                // Digit berikutnya (masuk dari arah roll)
                Transform.translate(
                  offset: Offset(0, offset + _itemHeight),
                  child: _digitBox(nextDigit),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _digitBox(int digit) {
    return SizedBox(
      height: _itemHeight,
      width: _itemWidth,
      child: Center(
        child: Text(
          '$digit',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
