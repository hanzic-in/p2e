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

  void _showUpgradePopup(BuildContext context, FarmItem farm, DashboardProvider prov) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(farm.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white24))
            ],
          ),
          const SizedBox(height: 20),
          Image.asset(farm.assetPath, height: 80),
          const SizedBox(height: 15),
          Text("Tingkatkan ke LVL ${farm.level + 1}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Tingkatkan level produksi untuk hasil lebih maksimal", 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
          
          const SizedBox(height: 25),
          // Info Box
          Row(
            children: [
              _infoTile("DURASI PENINGK.", "${farm.upgradeDuration}s", Icons.timer_outlined),
              const SizedBox(width: 15),
              _infoTile("BIAYA PENINGK.", "${farm.upgradePrice.toInt()}", Icons.monetization_on_outlined),
            ],
          ),

          const SizedBox(height: 25),
          const Text("PRODUKSI TINGKAT LANJUT", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_filled, color: Colors.amber, size: 16),
              const SizedBox(width: 5),
              Text("${(farm.level + 1) * 2 - 1}s", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Image.asset(farm.assetPath, height: 16),
              const SizedBox(width: 5),
              Text("${(farm.level + 1) * 2}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 30),
          // Tombol Final
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: () {
                prov.startUpgrade(farm.id);
                Navigator.pop(context);
              },
              child: const Text("TINGKATKAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    ),
  );
}

  void claimResult(int id) {
    final index = _myFarms.indexWhere((f) => f.id == id);
    if (index == -1) return;
    var farm = _myFarms[index];
    if (farm.status != ProductionStatus.ready) return;
    
    farm.stock += (farm.currentIncome).toInt();
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
}
