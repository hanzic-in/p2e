import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TycoonHeader extends StatelessWidget {
  final double bCoin;
  final double keyCoin;
  final double special;

  const TycoonHeader({
    super.key,
    required this.bCoin, 
    required this.keyCoin, 
    required this.special
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // SPECIAL
          _buildSimpleStat("SPECIAL", special.toStringAsFixed(2), AppColors.primaryGreen),
          
          // Garis Pemisah
          Container(width: 1, height: 25, color: Colors.white10),
          
          // B-COIN
          _buildSimpleStat("B-COIN", bCoin.toStringAsFixed(1), Colors.amber),
          
          // Garis Pemisah
          Container(width: 1, height: 25, color: Colors.white10),
          
          // KEY
          _buildSimpleStat("KEY", keyCoin.toStringAsFixed(0), Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value, 
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)
        ),
        const SizedBox(height: 2),
        Text(
          label, 
          style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}
