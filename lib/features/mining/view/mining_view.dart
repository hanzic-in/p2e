import 'package:flutter/material.dart';
import '../provider/mining_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  State<MiningView> createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView> {
  int _balanceInt = 0;
  Timer? _timer;

  final Color tokenColor = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _balanceInt += 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatBalance(int value) {
    final str = value.toString().padLeft(14, '0');
    final whole = str.substring(0, str.length - 13);
    final decimal = str.substring(str.length - 13);
    return "$whole.$decimal";
  }

  @override
  Widget build(BuildContext context) {
    final formatted = formatBalance(_balanceInt);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1116),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1F26),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MINING PANEL",
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(Icons.bolt, color: Colors.orangeAccent),
                  ],
                ),

                const SizedBox(height: 30),

                // BALANCE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: tokenColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "D",
                        style: TextStyle(
                          color: tokenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: formatted
                          .split('')
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final char = entry.value;
                        final num = int.tryParse(char);

                        if (num == null) {
                          return Text(
                            char,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        }

                        return SlotDigit(
                          key: ValueKey('$index-$num'),
                          digit: num,
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  "TOTAL D-COIN EARNED",
                  style: TextStyle(
                    color: tokenColor.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SlotDigit extends StatefulWidget {
  final int digit;
  const SlotDigit({required this.digit, super.key});

  @override
  State<SlotDigit> createState() => _SlotDigitState();
}

class _SlotDigitState extends State<SlotDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int current = 0;
  int next = 0;
  bool animating = false;

  static const double h = 32;

  @override
  void initState() {
    super.initState();

    current = widget.digit;
    next = widget.digit;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _animation = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant SlotDigit oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.digit != current && !animating) {
      next = widget.digit;
      _run();
    }
  }

  Future<void> _run() async {
    animating = true;

    await _controller.forward();

    setState(() {
      current = next;
    });

    _controller.reset();
    animating = false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: h,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _animation.value * h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: h,
                    child: Center(child: Text('$current', style: _style())),
                  ),
                  SizedBox(
                    height: h,
                    child: Center(child: Text('$next', style: _style())),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  TextStyle _style() => const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
      );
}
