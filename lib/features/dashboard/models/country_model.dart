import './order_model.dart';

enum Continent { afrika, asia, eropa, as }

class CountryOrder {
  final String id;
  final String name;
  final String flagAsset;
  final Continent continent;
  final double unlockCost;
  final double upgradeCost;
  final Duration deliveryTime;
  
  bool isUnlocked;
  int level;
  List<OrderItem> requiredItems;
  int rewardKeyMin;
  int rewardKeyMax;

  CountryOrder({
    required this.id, required this.name, required this.flagAsset,
    required this.continent, required this.unlockCost, required this.upgradeCost,
    required this.deliveryTime, this.isUnlocked = false, this.level = 1,
    this.requiredItems = const [], this.rewardKeyMin = 1, this.rewardKeyMax = 10,
  });
}
