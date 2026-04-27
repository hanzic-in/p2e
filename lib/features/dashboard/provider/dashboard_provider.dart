import 'dart:async';
import 'package:flutter/material.dart';
import '../models/farm_item_model.dart';

class DashboardProvider extends ChangeNotifier {
  double _balance = 0.0;
  List<FarmItem> _myFarms = initialFarmData;

  double get balance => _balance;
  List<FarmItem> get myFarms => _myFarms;

  DashboardProvider() {
    _startFarmProduction();
  }

  void _startFarmProduction() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var farm in _myFarms) {
        if (!farm.isLocked) {
          _balance += (farm.incomePerCycle / farm.cycleDuration);
        }
      }
      notifyListeners();
    });
  }

  void unlockFarm(int index) {
    if (_balance >= _myFarms[index].unlockPrice) {
      _balance -= _myFarms[index].unlockPrice;
      var item = _myFarms[index];
      _myFarms[index] = FarmItem(
        name: item.name,
        productionLabel: item.productionLabel,
        incomePerCycle: item.incomePerCycle,
        cycleDuration: item.cycleDuration,
        isLocked: false,
        icon: item.icon,
      );
      notifyListeners();
    }
  }
}
