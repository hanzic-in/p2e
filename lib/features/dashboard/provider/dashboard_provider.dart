import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';
import '../models/order_model.dart';

class DashboardProvider extends ChangeNotifier {

    List<CountryOrder> _countries = [
    CountryOrder(id: '1', name: 'Burundi', flagAsset: 'flags/burundi.png', continent: Continent.afrika, unlockCost: 50000, upgradeCost: 20000, deliveryTime: const Duration(minutes: 10), rewardKeyMin: 1, rewardKeyMax: 10),
    CountryOrder(id: '2', name: 'Uganda', flagAsset: 'flags/uganda.png', continent: Continent.afrika, unlockCost: 50000, upgradeCost: 25000, deliveryTime: const Duration(minutes: 5), rewardKeyMin: 3, rewardKeyMax: 9),
  ];

    List<CountryOrder> get countries => _countries;

  void unlockCountry(String id) {
    final index = _countries.indexWhere((c) => c.id == id);
    if (index != -1 && _balanceBCoin >= _countries[index].unlockCost) {
      _balanceBCoin -= _countries[index].unlockCost;
      _countries[index].isUnlocked = true;
      refreshCountryOrder(id);
      notifyListeners();
    }
  }

  void refreshCountryOrder(String id) {
    final index = _countries.indexWhere((c) => c.id == id);
    final random = Random();
    
    List<OrderItem> newItems = [];
    var pool = List<FarmItem>.from(_myFarms)..shuffle();
    
    for (var i = 0; i < 3; i++) {
      newItems.add(OrderItem(
        itemName: pool[i].name,
        assetPath: pool[i].assetPath,
        amount: 5 + random.nextInt(26),
      ));
    }
    _countries[index].requiredItems = newItems;
    notifyListeners();
  }
  
  double _balanceBCoin = 5000.0;
  double _balanceKeyCoin = 0.0;
  double _balanceSpecial = 0.0;
  
  List<FarmItem> _myFarms = initialFarms;
  final Map<int, Timer?> _timers = {};

  UrgentOrder? _currentUrgentOrder;
  UrgentOrder? get currentUrgentOrder => _currentUrgentOrder;

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
  List<OrderItem> listPesanan = []; 
  var semuaFarm = List<FarmItem>.from(_myFarms);
  semuaFarm.shuffle();

  int jumlahJenis = 3 + random.nextInt(4); 

  for (var i = 0; i < jumlahJenis; i++) {
    listPesanan.add(OrderItem(
      itemName: semuaFarm[i].name,
      assetPath: semuaFarm[i].assetPath,
      amount: 50 + random.nextInt(450),
    ));
  }
  double totalHadiah = (listPesanan.length * 20000).toDouble() + random.nextInt(10000);

  _currentUrgentOrder = UrgentOrder(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    buyerName: "Eagle Eye Eddie",
    buyerImage: "assets/images/eddie.png",
    requiredItems: listPesanan,
    rewardCoin: totalHadiah,
    rewardKey: totalHadiah > 100000 ? 1 : 0,
    deliveryDuration: Duration(hours: 2 + random.nextInt(6)),
  );
    notifyListeners();
  }


}
