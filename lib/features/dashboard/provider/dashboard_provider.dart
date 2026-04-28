import 'dart:async';
import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';

class DashboardProvider extends ChangeNotifier {
  double _balanceBCoin = 5000.0;
  double _balanceKeyCoin = 0.0;
  double _balanceSpecial = 0.0;
  
  List<FarmItem> _myFarms = initialFarms;
  final Map<int, Timer?> _timers = {};

  double get bCoin => _balanceBCoin;
  double get keyCoin => _balanceKeyCoin;
  double get special => _balanceSpecial;
  List<FarmItem> get myFarms => _myFarms;

  // --- LOGIC ---
  bool canBeUnlocked(FarmItem target) {
    if (target.unlockRequirements.isEmpty) return true;

    return target.unlockRequirements.every((reqName) {
      return _myFarms.any((farm) => 
        farm.name == reqName && farm.status != ProductionStatus.locked
      );
    });
  }

  // --- LOGIC BELI / BUKA ITEM ---
  void unlockFarm(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    if (index == -1) return;
    
    var farm = _myFarms[index];
    
    double unlockCost = 500.0; 

    if (farm.status == ProductionStatus.locked && 
        canBeUnlocked(farm) && 
        _balanceBCoin >= unlockCost) {
      
      _balanceBCoin -= unlockCost;
      farm.status = ProductionStatus.idle;
      notifyListeners();
    }
  }

  // --- LOGIC PRODUKSI ---
  void startProduction(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    var farm = _myFarms[index];
    
    if (farm.status != ProductionStatus.idle) return;
    
    farm.status = ProductionStatus.producing;
    farm.remainingSeconds = farm.cycleDuration;
    notifyListeners();

    _timers[farm.id]?.cancel();
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

  void claimResult(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    var farm = _myFarms[index];
    
    if (farm.status != ProductionStatus.ready) return;
    
    farm.stock += (farm.currentIncome).toInt();
    _balanceKeyCoin += farm.baseIncomeKey;
    farm.status = ProductionStatus.idle;
    notifyListeners();
  }

  // ... upgradeFarm & sellStock ...
  void upgradeFarm(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    var farm = _myFarms[index];
    if (_balanceBCoin >= farm.upgradePrice) {
      _balanceBCoin -= farm.upgradePrice;
      farm.level++;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    super.dispose();
  }
}
