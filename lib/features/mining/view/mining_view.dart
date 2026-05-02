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
  
  // 14 decimal places
  int _balanceInt = 0;
  
  String formatBalance(int value) {
    // 1 whole digit + 14 decimal = 15 digits total
    final str = value.toString().padLeft(15, '0');
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

    _balanceTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        final prov = Provider.of<MiningProvider>(context, listen: false);
        if (prov.isMining && mounted) {
          final increment = 1 + math.Random().nextInt(3);
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
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        height: 1.0,
                      ),
                    );
                  }

                  return SlotDigit(
                    key: ValueKey('digit-$index'),
                    digit: num,
                    delayMs: index * 15,
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
  
  int _current = 0;
  int _next = 0;
  bool _isAnimating = false;

  // Ukuran sedang untuk 15 digit total
  static const double _h = 24.0;
  static const double _w = 14.0;
  static const _style = TextStyle(
    fontSize: 18, 
    fontWeight: FontWeight.w900, 
    fontFamily: 'monospace', 
    color: Colors.white, 
    height: 1,
  );

  @override
  void initState() {
    super.initState();
    _current = widget.digit;
    _next = widget.digit;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void didUpdateWidget(covariant SlotDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit == oldWidget.digit) return;
    if (_isAnimating) return;
    _triggerRoll(widget.digit);
  }

  void _triggerRoll(int target) async {
    if (target == _current || !mounted) return;
    
    if (widget.delayMs > 0) {
      await Future.delayed(Duration(milliseconds: widget.delayMs));
    }
    
    if (!mounted || target != widget.digit) return;
    
    _next = target;
    setState(() => _isAnimating = true);
    
    await _controller.forward(from: 0);
    
    if (!mounted) return;
    
    setState(() {
      _current = _next;
      _isAnimating = false;
    });
    
    if (widget.digit != _current) {
      _triggerRoll(widget.digit);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int diff = _next - _current;
    if (diff > 5) diff -= 10;
    if (diff < -5) diff += 10;
    final bool up = diff > 0;

    return SizedBox(
      width: _w,
      height: _h,
      child: ClipRect(
        child: _isAnimating
          ? AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final t = Curves.easeOutCubic.transform(_controller.value);
                final y = up ? -t * _h : t * _h;
                
                return Stack(
                  children: up
                    ? [
                        Transform.translate(offset: Offset(0, y), child: _txt(_current)),
                        Transform.translate(offset: Offset(0, y + _h), child: _txt(_next)),
                      ]
                    : [
                        Transform.translate(offset: Offset(0, y - _h), child: _txt(_next)),
                        Transform.translate(offset: Offset(0, y), child: _txt(_current)),
                      ],
                );
              },
            )
          : _txt(_current),
      ),
    );
  }

  Widget _txt(int d) => SizedBox(
    height: _h,
    width: _w,
    child: Center(
      child: Text('$d', style: _style),
    ),
  );
}
