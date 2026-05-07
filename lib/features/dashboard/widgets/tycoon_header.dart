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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNeonStat(special.toStringAsFixed(2), AppColors.primaryGreen, "SPECIAL"),
          _buildNeonStat(bCoin.toStringAsFixed(0), Colors.amber, "B-COIN"),
          _buildNeonStat(keyCoin.toStringAsFixed(0), Colors.cyanAccent, "KEYS"),
        ],
      ),
    );
  }

  Widget _buildNeonStat(String value, Color color, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kecil di atas
        Text(
          label, 
          style: TextStyle(color: color.withOpacity(0.6), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
        const SizedBox(height: 2),
        // Angka Koin
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        // Garis Neon Glow di bawah angka
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 2,
          width: 25,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.8), blurRadius: 8, spreadRadius: 1),
            ],
          ),
        ),
      ],
    );
  }
}
