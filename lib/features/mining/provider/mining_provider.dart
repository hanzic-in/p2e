import 'package:flutter/material.dart';
import 'dart:async';

class MiningProvider extends ChangeNotifier {
  // --- STATE MINING UTAMA ---
  bool _isMining = false;
  Duration _remainingMiningTime = Duration.zero;
  Timer? _miningTimer;
  
  double _baseHashRate = 10.0; 
  double _minedCoinBalance = 0.0;

  // --- STATE BOOST KECEPATAN ---
  bool _isBoostActive = false;
  Duration _remainingBoostTime = Duration.zero;
  Timer? _boostTimer;
  DateTime? _lastBoostClaimTime;

  // Getter UI
  bool get isMining => _isMining;
  String get remainingMiningTimeStr => _formatDuration(_remainingMiningTime);
  double get currentHashRate => _isBoostActive ? _baseHashRate * 2 : _baseHashRate;
  double get minedCoinBalance => _minedCoinBalance;
  bool get isBoostActive => _isBoostActive;
  String get remainingBoostTimeStr => _formatDuration(_remainingBoostTime);

  // --- ACTION: MULAI MINING ---
  void startMiningSession() {

    _isMining = true;
    _remainingMiningTime = const Duration(minutes: 30);
    _minedCoinBalance = 0.0;
    
    _miningTimer?.cancel();
    _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingMiningTime.inSeconds > 0) {
        _remainingMiningTime -= const Duration(seconds: 1);
        _minedCoinBalance += (currentHashRate / 3600);
        notifyListeners();
      } else {
        stopMiningSession(completed: true);
      }
    });
    notifyListeners();
  }

  void stopMiningSession({bool completed = false}) {
    _isMining = false;
    _remainingMiningTime = Duration.zero;
    _miningTimer?.cancel();

    if (completed) {
    }
    notifyListeners();
  }

  // --- ACTION: CLAIM BOOST ---
  bool canClaimBoost() {
    if (_lastBoostClaimTime == null) return true;
    final now = DateTime.now();
    return now.difference(_lastBoostClaimTime!) >= const Duration(hours: 24);
  }

  void startBoostSession() {
    _isBoostActive = true;
    _remainingBoostTime = const Duration(minutes: 2);
    _lastBoostClaimTime = DateTime.now();

    _boostTimer?.cancel();
    _boostTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingBoostTime.inSeconds > 0) {
        _remainingBoostTime -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        _isBoostActive = false;
        _remainingBoostTime = Duration.zero;
        _boostTimer?.cancel();
        notifyListeners();
      }
    });
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
