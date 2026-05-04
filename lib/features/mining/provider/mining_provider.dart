import 'package:flutter/material.dart';
import 'dart:async';
  
class MiningProvider extends ChangeNotifier {
  bool _isMining = false;
  
  double _baseHashRate = 10.0; 
  double _minedCoinBalance = 0.0;

  // STATE BOOST SPEED
  bool _isBoostActive = false;
  DateTime? _lastBoostClaimTime;
  DateTime? _boostEndTime;

  // Getter UI
  bool get isMining => _isMining;

  String get remainingMiningTimeStr {
  if (_miningEndTime == null) return "00:00";
  final now = DateTime.now();
  final remaining = _miningEndTime!.difference(now);
  if (remaining.isNegative) return "00:00";
  return _formatDuration(remaining);
}
  double get currentHashRate => _isBoostActive ? _baseHashRate * 2 : _baseHashRate;
  double get minedCoinBalance => _minedCoinBalance;
  bool get isBoostActive => _isBoostActive;

  String get remainingBoostTimeStr {
    if (_boostEndTime == null) return "00:00";
    final now = DateTime.now();
    final remaining = _boostEndTime!.difference(now);
    if (remaining.isNegative) return "00:00";
    return _formatDuration(remaining);
  }

  int balanceMicro = 0;
  DateTime? lastUpdate;

  void addBalance(int val) {
    balanceMicro += val;
    notifyListeners();
  }
  
  // ACTION MINING START
  void startMiningSession() {
    final now = DateTime.now();
    _isMining = true;
    _minedCoinBalance = 0.0;
    _miningEndTime = now.add(const Duration(minutes: 30));
    lastUpdate = now;
    notifyListeners();
  }

  void stopMiningSession() {
    _isMining = false;
    _miningEndTime = null;
    notifyListeners();
  }

  // ACTION CLAIM BOOST
  bool canClaimBoost() {
    if (_lastBoostClaimTime == null) return true;
    final now = DateTime.now();
    return now.difference(_lastBoostClaimTime!) >= const Duration(hours: 24);
  }

  void startBoostSession() {
  final now = DateTime.now();

  _isBoostActive = true;
  _boostEndTime = now.add(const Duration(minutes: 2));
  _lastBoostClaimTime = now;

  notifyListeners();
}

  void refreshBoost() {
  if (!_isBoostActive || _boostEndTime == null) return;

  final now = DateTime.now();
  if (now.isAfter(_boostEndTime!)) {
    _isBoostActive = false;
    _boostEndTime = null;
    notifyListeners();
  }
}

  void refreshMining() {
  if (!_isMining || _miningEndTime == null || lastUpdate == null) return;

  final now = DateTime.now();

  final effectiveNow = now.isAfter(_miningEndTime!)
      ? _miningEndTime!
      : now;

  final seconds = effectiveNow.difference(lastUpdate!).inSeconds;
  if (seconds > 0) {
    final ratePerSecond = currentHashRate / 3600;
    _minedCoinBalance += ratePerSecond * seconds;
    balanceMicro += seconds * (1000 + math.Random().nextInt(5000));
    lastUpdate = effectiveNow;
  }
  if (now.isAfter(_miningEndTime!)) {
    _isMining = false;
    _miningEndTime = null;
  }
  notifyListeners();
}
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    _boostTimer?.cancel();
    super.dispose();
  }
}
