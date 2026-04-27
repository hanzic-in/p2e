import 'package:flutter/material.dart';

enum ProductionStatus { locked, idle, producing, ready }

class FarmItem {
  final int id;
  final String name;
  final String assetPath;
  final int cycleDuration;
  final double baseIncome;
  final double baseIncomeKey;
  
  int level;
  int stock;
  ProductionStatus status;
  int remainingSeconds;

  FarmItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.cycleDuration,
    required this.baseIncome,
    required this.baseIncomeKey,
    this.level = 1,
    this.stock = 0,
    this.status = ProductionStatus.locked,
    this.remainingSeconds = 0,
  });

  double get currentIncome => baseIncome * level;
  double get upgradePrice => 100.0 * level;
}

List<FarmItem> initialFarms = [
  FarmItem(id: 1, name: "Gandum", assetPath: "assets/images/wheat.png", cycleDuration: 9, baseIncome: 2, baseIncomeKey: 0.1, status: ProductionStatus.idle),
  FarmItem(id: 2, name: "Kentang", assetPath: "assets/images/potato.png", cycleDuration: 15, baseIncome: 5, baseIncomeKey: 0.2, status: ProductionStatus.locked),
  FarmItem(id: 3, name: "Wortel", assetPath: "assets/images/carrot.png", cycleDuration: 30, baseIncome: 12, baseIncomeKey: 0.5, status: ProductionStatus.locked),
];
