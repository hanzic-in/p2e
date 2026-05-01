import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../provider/mining_provider.dart';
import 'dart:math' as math;

class MiningView extends StatefulWidget {
  const MiningView({super.key});

  @override
  _MiningViewState createState() => _MiningViewState();
}

class _MiningViewState extends State<MiningView>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;

  // Pakai double biar bisa increment kecil-kecil
  double _balanceExact = 0.0;

  // Rate mining per detik (disesuaikan biar keliatan smooth)
  // Normal: ~0.5 unit/detik, Boost: ~1.2 unit/detik
  static const double _miningRateNormal = 0.5;
  static const double _miningRateBoost = 1.2;

  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

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

    // Pakai Ticker untuk delta time yang akurat — tidak tergantung asumsi 60fps
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    // Delta time dalam detik, di-clamp max 100ms biar aman kalau frame drop
    final double dt =
        ((elapsed - _lastElapsed).inMicroseconds / 1000000.0).clamp(0.0, 0.1);
    _lastElapsed = elapsed;

    final prov = Provider.of<MiningProvider>(context, listen: false);
    if (!prov.isMining) return;

    final rate =
        prov.isBoostActive ? _miningRateBoost : _miningRateNormal;

    setState(() {
      _balanceExact += rate * dt;
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MiningProvider>(context);
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
              // --- 1. MAIN MINING PANEL ---
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
                        Text(
                          "D-COIN CLOUD MINING",
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Icon(Icons.bolt_rounded,
                            color: Colors.orangeAccent, size: 18),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildTokenBalance(prov, tokenColor),
                    const SizedBox(height: 35),
                    _buildStreamBar(
                        color: Colors.orangeAccent,
                        isMining: prov.isMining,
                        offset: 0.0),
                    const SizedBox(height: 12),
                    _buildStreamBar(
                        color: activeThemeColor,
                        isMining: prov.isMining,
                        offset: 0.5),
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
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- 2. TIMER ACTION BUTTON ---
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

              // --- 3. REWARD CARDS ---
              Row(
                children: [
                  Expanded(
                      child: _buildRewardCard(
                          "Daily Check-in", "5.0 Gh/s", activeThemeColor)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildRewardCard(
                          "Ad-Boost", "12.5 Gh/s", activeThemeColor)),
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
    // Konversi ke int buat formatting, tapi smooth karena _balanceExact update per frame
    final int balanceInt = _balanceExact.floor();
    final String formatted = formatBalance(balanceInt);

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
                  border:
                      Border.all(color: color.withOpacity(0.5), width: 1.5),
                ),
                child: Text(
                  "D",
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),

              // Rolling digits — key STATIC berdasarkan index posisi
              // Jangan pakai ValueKey yang berubah tiap rebuild!
              Row(
                mainAxisSize: MainAxisSize.min,
                children: formatted
                    .split('')
                    .asMap()
                    .entries
                    .map<Widget>((entry) {
                  final index = entry.key;
                  final char = entry.value;
                  final num = int.tryParse(char);

                  if (num == null) {
                    // Karakter titik desimal — static
                    return const Text(
                      '.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    );
                  }

                  return RollingDigit(
                    // KEY STATIC: berdasarkan posisi, bukan nilai.
                    // Ini penting! Kalau key berubah, widget di-recreate
                    // dari scratch dan animasi mulai dari 0 lagi.
                    key: ValueKey('digit_slot_$index'),
                    digit: num,
                    // Digit paling kanan (least significant) paling cepat berputar
                    // Digit paling kiri (most significant) paling lambat
                    spinSpeed: _getSpinSpeed(index, formatted.length),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "TOTAL D-COIN EARNED",
          style: TextStyle(
              color: color.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
      ],
    );
  }

  // Kecepatan spin disesuaikan per posisi digit
  // Index 0 = paling kiri (most significant, bergerak paling lambat)
  // Index terakhir = paling kanan (least significant, bergerak paling cepat)
  double _getSpinSpeed(int index, int totalLength) {
    // Skip titik desimal dari hitungan — cari berapa digit yang ada
    // Posisi dari kanan (0 = paling kanan)
    final fromRight = totalLength - 1 - index;
    // Kecepatan base: makin kanan makin cepat
    // fromRight=0 → speed 20, fromRight=13 → speed 4
    return (4.0 + fromRight * 1.2).clamp(4.0, 20.0);
  }

  Widget _buildStreamBar(
      {required Color color,
      required bool isMining,
      required double offset}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
              height: 4,
              width: double.infinity,
              color: Colors.white.withOpacity(0.02)),
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
            Icon(
                prov.isMining
                    ? Icons.timer_outlined
                    : Icons.play_arrow_rounded,
                size: 20),
            const SizedBox(width: 10),
            Text(
              prov.isMining
                  ? prov.remainingMiningTimeStr
                  : "START MINING SESSION",
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1),
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
          Text(title,
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 35,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text("CLAIM",
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================
// RollingDigit — smooth slot-machine digit dengan physics benar
// ============================================================
class RollingDigit extends StatefulWidget {
  final int digit;
  final double spinSpeed; // kecepatan target dalam "digit per detik"

  const RollingDigit({
    required this.digit,
    this.spinSpeed = 10.0,
    super.key,
  });

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit>
    with SingleTickerProviderStateMixin {
  // _position adalah posisi kontinu — bukan dibatasi 0-9
  // Misal: 12.7 → baseDigit=2, fraction=0.7
  // Ini penting supaya animasi bisa "jalan terus" tanpa jump
  double _position = 0.0;
  double _targetPosition = 0.0;
  double _velocity = 0.0;

  static const double _digitHeight = 36.0;
  static const double _digitWidth = 20.0;

  // Physics constants
  static const double _maxVelocity = 30.0;
  static const double _acceleration = 40.0; // seberapa cepat ngejar target
  static const double _friction = 0.85;     // braking saat mendekati target
  static const double _snapThreshold = 0.02; // jarak minimum sebelum snap

  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _position = widget.digit.toDouble();
    _targetPosition = widget.digit.toDouble();

    // Pakai Ticker biar dapat delta time akurat
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      // Hitung selisih yang benar (selalu maju, tidak mundur)
      // Contoh: dari 8 ke 1 → maju 3 step (8→9→0→1), bukan mundur 7
      double diff = (widget.digit - oldWidget.digit + 10) % 10;
      if (diff == 0) diff = 10; // misal 5→5 dipaksa 10 (satu putaran penuh)
      _targetPosition += diff;
    }
  }

  void _onTick(Duration elapsed) {
    // Delta time dalam detik, clamp max 50ms (jaga-jaga kalau app di-background)
    final double dt =
        ((elapsed - _lastElapsed).inMicroseconds / 1000000.0).clamp(0.0, 0.05);
    _lastElapsed = elapsed;

    if (dt == 0) return;

    final double dist = _targetPosition - _position;

    if (dist.abs() < _snapThreshold && _velocity.abs() < 0.05) {
      // Snap ke target — berhenti total
      if (_position != _targetPosition || _velocity != 0) {
        setState(() {
          _position = _targetPosition;
          _velocity = 0;
        });
      }
      return;
    }

    if (dist.abs() > 0.5) {
      // Masih jauh dari target → percepat ke arah target
      // Juga pertimbangkan spinSpeed sebagai kecepatan minimum saat mining aktif
      final double targetVel =
          (dist.sign * widget.spinSpeed).clamp(-_maxVelocity, _maxVelocity);
      // Lerp velocity menuju targetVel dengan acceleration
      _velocity += (targetVel - _velocity) * _acceleration * dt;
      _velocity = _velocity.clamp(-_maxVelocity, _maxVelocity);
    } else {
      // Dekat target → perlambat dengan friction
      _velocity *= math.pow(_friction, dt * 60).toDouble();
    }

    setState(() {
      _position += _velocity * dt;
      // Pastikan tidak overshoot (tidak melewati target saat decelerating)
      if (_velocity > 0 && _position > _targetPosition) {
        _position = _targetPosition;
        _velocity = 0;
      } else if (_velocity < 0 && _position < _targetPosition) {
        _position = _targetPosition;
        _velocity = 0;
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int baseDigit = _position.floor() % 10;
    final int nextDigit = (baseDigit + 1) % 10;
    final double fraction = _position - _position.floor();

    // Speed factor untuk efek visual (blur, trail opacity)
    final double speedFactor = (_velocity.abs() / _maxVelocity).clamp(0.0, 1.0);

    // Easing: smooth saat lambat, linear saat cepat
    final double easedFraction = speedFactor > 0.5
        ? fraction
        : Curves.easeInOutCubic.transform(fraction);

    return SizedBox(
      width: _digitWidth,
      height: _digitHeight,
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ghost trails (hanya tampil saat cukup cepat)
            if (speedFactor > 0.1) ..._buildTrails(fraction, speedFactor),

            // Digit saat ini — bergerak naik
            Transform.translate(
              offset: Offset(0, -easedFraction * _digitHeight),
              child: Opacity(
                opacity: (1.0 - easedFraction).clamp(0.0, 1.0),
                child: _buildDigitText(baseDigit, isMain: true),
              ),
            ),

            // Digit berikutnya — masuk dari bawah
            Transform.translate(
              offset: Offset(0, (1.0 - easedFraction) * _digitHeight),
              child: Opacity(
                opacity: easedFraction.clamp(0.0, 1.0),
                child: _buildDigitText(nextDigit, isMain: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTrails(double fraction, double speedFactor) {
    final List<Widget> trails = [];
    // Jumlah trail: 1-4 tergantung kecepatan
    final int trailCount = (1 + speedFactor * 3).floor().clamp(1, 4);

    for (int i = 1; i <= trailCount; i++) {
      final int trailDigit = (_position.floor() - i).remainder(10);
      final double trailOffset = (-fraction - i) * _digitHeight;

      // Opacity eksponensial — trail pertama paling jelas
      final double opacity =
          (math.pow(0.5, i).toDouble() * speedFactor * 0.7).clamp(0.0, 0.4);

      if (opacity > 0.02) {
        trails.add(
          Transform.translate(
            offset: Offset(0, trailOffset),
            child: Opacity(
              opacity: opacity,
              child: _buildDigitText(
                (trailDigit + 10) % 10,
                isMain: false,
                blur: i * 1.0 + speedFactor * 2.0,
              ),
            ),
          ),
        );
      }
    }

    return trails;
  }

  Widget _buildDigitText(int digit, {required bool isMain, double blur = 0}) {
    return SizedBox(
      height: _digitHeight,
      width: _digitWidth,
      child: Center(
        child: Text(
          '$digit',
          style: TextStyle(
            fontSize: isMain ? 22 : 18,
            fontWeight: isMain ? FontWeight.w900 : FontWeight.w600,
            fontFamily: 'monospace',
            color: isMain ? Colors.white : Colors.white54,
            shadows: blur > 0
                ? [
                    Shadow(
                      blurRadius: blur,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
