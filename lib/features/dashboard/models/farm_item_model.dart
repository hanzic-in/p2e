import 'package:flutter/material.dart';

enum ProductionStatus { locked, idle, producing, ready }

class FarmItem {
  final int id;
  final String name;
  final String assetPath;
  final int cycleDuration;
  final double incomeBCoin;
  final double incomeKey;
  
  ProductionStatus status;
  int remainingSeconds;

  FarmItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.cycleDuration,
    required this.incomeBCoin,
    required this.incomeKey,
    this.status = ProductionStatus.locked,
    this.remainingSeconds = 0,
  });
}

List<FarmItem> initialFarms = [
  FarmItem(id: 1, name: "Gandum", assetPath: "assets/images/wheat.png", cycleDuration: 9, incomeBCoin: 2, incomeKey: 0.1, status: ProductionStatus.idle),
  FarmItem(id: 2, name: "Kentang", assetPath: "assets/images/potato.png", cycleDuration: 15, incomeBCoin: 5, incomeKey: 0.2, status: ProductionStatus.locked),
  FarmItem(id: 3, name: "Wortel", assetPath: "assets/images/carrot.png", cycleDuration: 30, incomeBCoin: 12, incomeKey: 0.5, status: ProductionStatus.locked),
];
