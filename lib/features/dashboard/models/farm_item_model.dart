import 'package:flutter/material.dart';

class FarmItem {
  final String name;
  final String productionLabel;
  final double incomePerCycle;
  final int cycleDuration;
  final bool isLocked;
  final double unlockPrice;
  final IconData icon;

  FarmItem({
    required this.name,
    required this.productionLabel,
    required this.incomePerCycle,
    required this.cycleDuration,
    this.isLocked = true,
    this.unlockPrice = 0,
    required this.icon,
  });
}

List<FarmItem> initialFarmData = [
  FarmItem(name: "Gandum", productionLabel: "2 / 9s", incomePerCycle: 2, cycleDuration: 9, isLocked: false, icon: Icons.grass),
  FarmItem(name: "Kentang", productionLabel: "5 / 15s", incomePerCycle: 5, cycleDuration: 15, unlockPrice: 1500, icon: Icons.fiber_manual_record),
  FarmItem(name: "Wortel", productionLabel: "10 / 30s", incomePerCycle: 10, cycleDuration: 30, unlockPrice: 3000, icon: Icons.commit),
];
