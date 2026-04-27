import 'dart:async';
import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';

class DashboardProvider extends ChangeNotifier {
  double _balanceBCoin = 0.0;
  double _balanceKeyCoin = 0.0;
  double _balanceSpecial = 0.0;
  
  List<FarmItem> _myFarms = initialFarms;
  final Map<int, Timer?> _timers = {};

  double get bCoin => _balanceBCoin;
  double get keyCoin => _balanceKeyCoin;
  double get special => _balanceSpecial;
  List<FarmItem> get myFarms => _myFarms;

  void startProduction(int index) {
    var farm = _myFarms[index];
    if (farm.status != ProductionStatus.idle) return;
    farm.status = ProductionStatus.producing;
    farm.remainingSeconds = farm.cycleDuration;
    notifyListeners();

    _timers[farm.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void claimResult(int index) {
    var farm = _myFarms[index];
    if (farm.status != ProductionStatus.ready) return;
    
    farm.stock += farm.currentIncome.toInt();
    _balanceKeyCoin += farm.baseIncomeKey;
    farm.status = ProductionStatus.idle;
    notifyListeners();
  }

  void upgradeFarm(int index) {
    var farm = _myFarms[index];
    if (_balanceBCoin >= farm.upgradePrice) {
      _balanceBCoin -= farm.upgradePrice;
      farm.level++;
      notifyListeners();
    }
  }

  void sellStock(int index, int amount) {
    var farm = _myFarms[index];
    if (farm.stock >= amount) {
      farm.stock -= amount;
      _balanceBCoin += (amount * 10);
      notifyListeners();
    }
  }
}
