import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';
import '../models/order_model.dart';

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

  bool canBeUnlocked(FarmItem target) {
    if (target.unlockRequirements.isEmpty) return true;
    return target.unlockRequirements.every((reqName) {
      return _myFarms.any((farm) => 
        farm.name == reqName && farm.status != ProductionStatus.locked
      );
    });
  }

  void unlockFarm(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    if (index == -1) return;
    var farm = _myFarms[index];
    double unlockCost = 500.0; 

    if (farm.status == ProductionStatus.locked && canBeUnlocked(farm) && _balanceBCoin >= unlockCost) {
      _balanceBCoin -= unlockCost;
      farm.status = ProductionStatus.idle;
      notifyListeners();
    }
  }

  void startProduction(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    if (index == -1) return;
    var farm = _myFarms[index];
    if (farm.status != ProductionStatus.idle) return;
    
    farm.status = ProductionStatus.producing;
    farm.remainingSeconds = farm.currentProductionTime;
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

  void startUpgrade(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    var farm = _myFarms[index];

    if (_balanceBCoin >= farm.upgradePrice && !farm.isUpgrading) {
      _balanceBCoin -= farm.upgradePrice;
      farm.isUpgrading = true;
      farm.upgradeRemainingSeconds = farm.upgradeDuration;
      notifyListeners();

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (farm.upgradeRemainingSeconds > 0) {
          farm.upgradeRemainingSeconds--;
          notifyListeners();
        } else {
          farm.level++;
          farm.isUpgrading = false;
          timer.cancel();
          notifyListeners();
        }
      });
    }
  }

  void startUnlock(int id) {
  final index = _myFarms.indexWhere((f) => f.id == id);
  var farm = _myFarms[index];

  if (_balanceBCoin >= farm.unlockCost && farm.status == ProductionStatus.locked && !farm.isUnlocking) {
    _balanceBCoin -= farm.unlockCost;
    farm.isUnlocking = true;
    farm.unlockRemainingSeconds = farm.unlockDuration;
    notifyListeners();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (farm.unlockRemainingSeconds > 0) {
        farm.unlockRemainingSeconds--;
        notifyListeners();
      } else {
        farm.isUnlocking = false;
        farm.status = ProductionStatus.idle;
        timer.cancel();
        notifyListeners();
      }
    });
  }
}

void claimResult(int id) {
  final index = _myFarms.indexWhere((f) => f.id == id);
  if (index == -1) return;  
  var farm = _myFarms[index];
  if (farm.status != ProductionStatus.ready) return;
  
  farm.stock += farm.currentStockYield; 
  _balanceKeyCoin += farm.baseIncomeKey;  
  farm.status = ProductionStatus.idle;
  notifyListeners();
}


  void upgradeFarm(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    if (index == -1) return;
    var farm = _myFarms[index];
    if (_balanceBCoin >= farm.upgradePrice) {
      _balanceBCoin -= farm.upgradePrice;
      farm.level++;
      notifyListeners();
    }
  }

  // --- INI FUNGSI YANG TADI ILANG ---
  void sellStock(int id, int amount) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    if (index == -1) return;
    var farm = _myFarms[index];
    
    if (farm.stock >= amount) {
      farm.stock -= amount;
      _balanceBCoin += (amount * 10);
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

  void generateRandomOrder() {
  final random = Random();
  List<Map<String, String>> buyers = [
    {'name': 'Eagle Eye Eddie', 'img': 'assets/images/eddie.png'},
    {'name': 'Captain Roger', 'img': 'assets/images/roger.png'},
    {'name': 'Uncle Bob', 'img': 'assets/images/bob.png'},
  ];

  var selectedBuyer = buyers[random.nextInt(buyers.length)];
  int itemCount = 3 + random.nextInt(3);
  int totalQuantity = 0;
  int hours = (rewardCoin / 100000).floor() + 2 + random.nextInt(3);

  _currentUrgentOrder = UrgentOrder(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    buyerName: selectedBuyer['name']!,
    buyerImage: selectedBuyer['img']!,
    rewardCoin: (totalQuantity * 1000).toDouble(),
    rewardKey: totalQuantity > 1000 ? 1 : 0,
    deliveryDuration: Duration(hours: hours),
    requiredItems: generatedItems,
  );  
    notifyListeners();
  }

}
