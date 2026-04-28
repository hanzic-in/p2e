import 'package:flutter/material.dart';

enum FarmSector { tanaman, hewan, pabrik, dapur, toko }
enum ProductionStatus { locked, idle, producing, ready }

class FarmItem {
  final int id;
  final String name;
  final String assetPath;
  final int cycleDuration;
  final double baseIncome;
  final double baseIncomeKey;
  final double unlockCost;
  final int unlockDuration;
  final FarmSector sector;
  final List<String> unlockRequirements;
  
  int level;
  int stock;
  bool isUnlocking;
  int unlockRemainingSeconds;
  bool isUpgrading;
  int upgradeRemainingSeconds;
  ProductionStatus status;
  int remainingSeconds;
  
  FarmItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.cycleDuration,
    required this.baseIncome,
    required this.baseIncomeKey,
    required this.sector,
    this.unlockRequirements = const [],
    this.level = 1,
    this.stock = 0,
    this.status = ProductionStatus.locked,
    this.unlockCost = 500.0,
    this.unlockDuration = 30,
    this.isUpgrading = false,
    this.remainingSeconds = 0,
    this.upgradeRemainingSeconds = 0,
  });

  int get dynamicProductionTime => (level * 2) - 1;
  int get upgradeDuration => level * 60;
  int get nextLevelProduction => (level + 1) * 2;
  double get currentIncome => baseIncome * level;
  double get upgradePrice => 150.0 * level;
}

// DATABASE MASTER LENGKAP
List<FarmItem> initialFarms = [
  // --- TANAMAN (Sektor 1) ---
  FarmItem(id: 1, name: "Gandum", assetPath: "assets/images/wheat.png", cycleDuration: 10, baseIncome: 2, baseIncomeKey: 0.1, sector: FarmSector.tanaman, status: ProductionStatus.idle),
  FarmItem(id: 2, name: "Kentang", assetPath: "assets/images/potato.png", cycleDuration: 20, baseIncome: 5, baseIncomeKey: 0.2, sector: FarmSector.tanaman),
  FarmItem(id: 3, name: "Wortel", assetPath: "assets/images/carrot.png", cycleDuration: 35, baseIncome: 10, baseIncomeKey: 0.4, sector: FarmSector.tanaman),
  FarmItem(id: 4, name: "Jagung", assetPath: "assets/images/corn.png", cycleDuration: 50, baseIncome: 15, baseIncomeKey: 0.6, sector: FarmSector.tanaman),
  FarmItem(id: 5, name: "Tomat", assetPath: "assets/images/tomato.png", cycleDuration: 70, baseIncome: 22, baseIncomeKey: 0.8, sector: FarmSector.tanaman),
  FarmItem(id: 6, name: "Apel", assetPath: "assets/images/apple.png", cycleDuration: 100, baseIncome: 35, baseIncomeKey: 1.2, sector: FarmSector.tanaman),
  FarmItem(id: 7, name: "Stroberi", assetPath: "assets/images/strawberry.png", cycleDuration: 150, baseIncome: 50, baseIncomeKey: 1.8, sector: FarmSector.tanaman),
  FarmItem(id: 8, name: "Anggur Putih", assetPath: "assets/images/white_grape.png", cycleDuration: 200, baseIncome: 75, baseIncomeKey: 2.5, sector: FarmSector.tanaman),
  FarmItem(id: 9, name: "Anggur Merah", assetPath: "assets/images/red_grape.png", cycleDuration: 250, baseIncome: 90, baseIncomeKey: 3.0, sector: FarmSector.tanaman),
  FarmItem(id: 10, name: "Blueberry", assetPath: "assets/images/blueberry.png", cycleDuration: 300, baseIncome: 110, baseIncomeKey: 4.0, sector: FarmSector.tanaman),
  FarmItem(id: 11, name: "Persik", assetPath: "assets/images/peach.png", cycleDuration: 350, baseIncome: 130, baseIncomeKey: 5.0, sector: FarmSector.tanaman),

  // --- HEWAN (Sektor 2) ---
  FarmItem(id: 21, name: "Ayam", assetPath: "assets/images/chicken.png", cycleDuration: 120, baseIncome: 80, baseIncomeKey: 2.0, sector: FarmSector.hewan, unlockRequirements: ["Gandum"]),
  FarmItem(id: 22, name: "Sapi", assetPath: "assets/images/cow.png", cycleDuration: 240, baseIncome: 200, baseIncomeKey: 5.0, sector: FarmSector.hewan, unlockRequirements: ["Gandum", "Jagung"]),
  FarmItem(id: 23, name: "Babi", assetPath: "assets/images/pig.png", cycleDuration: 300, baseIncome: 250, baseIncomeKey: 6.0, sector: FarmSector.hewan, unlockRequirements: ["Kentang", "Wortel"]),
  FarmItem(id: 24, name: "Angsa", assetPath: "assets/images/goose.png", cycleDuration: 180, baseIncome: 120, baseIncomeKey: 3.0, sector: FarmSector.hewan, unlockRequirements: ["Wortel"]),
  FarmItem(id: 25, name: "Domba", assetPath: "assets/images/sheep.png", cycleDuration: 400, baseIncome: 350, baseIncomeKey: 8.0, sector: FarmSector.hewan, unlockRequirements: ["Jagung"]),
  FarmItem(id: 26, name: "Kambing", assetPath: "assets/images/goat.png", cycleDuration: 450, baseIncome: 400, baseIncomeKey: 10.0, sector: FarmSector.hewan, unlockRequirements: ["Tomat"]),
  FarmItem(id: 27, name: "Lebah", assetPath: "assets/images/bee.png", cycleDuration: 150, baseIncome: 100, baseIncomeKey: 2.5, sector: FarmSector.hewan, unlockRequirements: ["Stroberi"]),

  // --- TOKO (Bahan Olahan) ---
  FarmItem(id: 31, name: "Tepung", assetPath: "assets/images/flour.png", cycleDuration: 200, baseIncome: 150, baseIncomeKey: 4.0, sector: FarmSector.toko, unlockRequirements: ["Gandum"]),
  FarmItem(id: 32, name: "Gula", assetPath: "assets/images/sugar.png", cycleDuration: 180, baseIncome: 130, baseIncomeKey: 3.5, sector: FarmSector.toko, unlockRequirements: ["Jagung"]),
  FarmItem(id: 33, name: "Keju Kambing", assetPath: "assets/images/goat_cheese.png", cycleDuration: 350, baseIncome: 450, baseIncomeKey: 12.0, sector: FarmSector.toko, unlockRequirements: ["Kambing"]),
  FarmItem(id: 34, name: "Mentega", assetPath: "assets/images/butter.png", cycleDuration: 250, baseIncome: 300, baseIncomeKey: 8.0, sector: FarmSector.toko, unlockRequirements: ["Sapi"]),

  // --- PABRIK ---
  FarmItem(id: 41, name: "Lilin Lebah", assetPath: "assets/images/wax.png", cycleDuration: 300, baseIncome: 250, baseIncomeKey: 6.0, sector: FarmSector.pabrik, unlockRequirements: ["Lebah"]),
  FarmItem(id: 42, name: "Selimut", assetPath: "assets/images/blanket.png", cycleDuration: 600, baseIncome: 800, baseIncomeKey: 20.0, sector: FarmSector.pabrik, unlockRequirements: ["Domba"]),
  FarmItem(id: 43, name: "Celana Panjang", assetPath: "assets/images/pants.png", cycleDuration: 500, baseIncome: 650, baseIncomeKey: 15.0, sector: FarmSector.pabrik, unlockRequirements: ["Domba"]),
  FarmItem(id: 44, name: "Kaos Kaki", assetPath: "assets/images/socks.png", cycleDuration: 350, baseIncome: 400, baseIncomeKey: 10.0, sector: FarmSector.pabrik, unlockRequirements: ["Domba"]),

  // --- DAPUR (Produk Jadi) ---
  FarmItem(id: 51, name: "Pai Apel", assetPath: "assets/images/apple_pie.png", cycleDuration: 600, baseIncome: 1200, baseIncomeKey: 25.0, sector: FarmSector.dapur, unlockRequirements: ["Apel", "Tepung"]),
  FarmItem(id: 52, name: "Biskuit Country", assetPath: "assets/images/biscuit.png", cycleDuration: 450, baseIncome: 900, baseIncomeKey: 18.0, sector: FarmSector.dapur, unlockRequirements: ["Tepung", "Mentega"]),
  FarmItem(id: 53, name: "Kue Stroberi", assetPath: "assets/images/strawberry_cake.png", cycleDuration: 800, baseIncome: 2000, baseIncomeKey: 40.0, sector: FarmSector.dapur, unlockRequirements: ["Stroberi", "Tepung", "Mentega"]),
  FarmItem(id: 54, name: "Kentang Goreng", assetPath: "assets/images/fries.png", cycleDuration: 300, baseIncome: 500, baseIncomeKey: 10.0, sector: FarmSector.dapur, unlockRequirements: ["Kentang"]),
];
