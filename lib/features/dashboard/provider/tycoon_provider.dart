import 'dart:async';
import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';

class TycoonProvider extends ChangeNotifier {
  // MultiCurrency
  double _balanceBCoin = 0.0;
  double _balanceKey = 0.0;
  double _balanceSpecial = 0.0;

  List<FarmItem> _myFarms = initialFarms;

  final Map<int, Timer?> _timers = {};

  double get bCoin => _balanceBCoin;
  double get key => _balanceKey;
  double get special => _balanceSpecial;
  List<FarmItem> get myFarms => _myFarms;

  void startProduction(int farmId) {
    int index = _myFarms.indexWhere((f) => f.id == farmId);
    if (index == -1) return;

    var farm = _myFarms[index];
    if (farm.status != ProductionStatus.idle) return;

    farm.status = ProductionStatus.producing;
    farm.remainingSeconds = farm.cycleDuration;
    notifyListeners();

    _timers[farmId] = Timer.periodic(Duration(seconds: 1), (timer) {
      if (farm.remainingSeconds > 0) {
        farm.remainingSeconds--;
        notifyListeners();
      } else {
        farm.status = ProductionStatus.ready;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void claimResult(int farmId) {
    int index = _myFarms.indexWhere((f) => f.id == farmId);
    if (index == -1) return;

    var farm = _myFarms[index];
    if (farm.status != ProductionStatus.ready) return;

    _balanceBCoin += farm.incomeBCoin;
    _balanceKey += farm.incomeKey;
    farm.status = ProductionStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timers.forEach((key, timer) => timer?.cancel());
    super.dispose();
  }
}
