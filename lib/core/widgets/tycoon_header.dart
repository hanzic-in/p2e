import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/dashboard/provider/tycoon_provider.dart';
import '../constants/app_colors.dart';

class TycoonHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TycoonProvider>(
      builder: (context, prov, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(color: AppColors.cardBg, border: Border(bottom: BorderSide(color: Colors.white10))),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _coinDisplay(prov.special.toStringAsFixed(3), "Special", AppColors.primaryNeon),
                _coinDisplay(prov.bCoin.toStringAsFixed(1), "B-Coin", Colors.amber),
                _coinDisplay(prov.key.toStringAsFixed(1), "Key", Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _coinDisplay(String amount, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}
