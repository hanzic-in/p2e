import 'dart:async';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  double _balance = 0.0;
  double _hashrate = 0.001;

  double get balance => _balance;
  double get hashrate => _hashrate;

  DashboardProvider() {
    _startMining();
  }

  void _startMining() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _balance += _hashrate;
      notifyListeners();
    });
  }

  void upgradeHashrate(double value) {
    _hashrate += value;
    notifyListeners();
  }
  
  List<Building?> _slots = List.generate(9, (index) => null);

  List<Building?> get slots => _slots;

  void buildStructure(int index, Building building) {
    _slots[index] = building;
    _hashrate += building.addedHashrate;
    notifyListeners();
  }
}
