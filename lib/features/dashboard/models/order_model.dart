import 'dart:math';

class UrgentOrder {
  final String id;
  final String buyerName;
  final String buyerImage;
  final List<OrderItem> requiredItems;
  final double rewardCoin;
  final int rewardKey;
  final Duration deliveryDuration;
  DateTime? deliveryStartTime;

  UrgentOrder({
    required this.id,
    required this.buyerName,
    required this.buyerImage,
    required this.requiredItems,
    required this.rewardCoin,
    required this.rewardKey,
    required this.deliveryDuration,
  });
}

class OrderItem {
  final String itemName;
  final String assetPath;
  final int amount;

  OrderItem({required this.itemName, required this.assetPath, required this.amount});
}
