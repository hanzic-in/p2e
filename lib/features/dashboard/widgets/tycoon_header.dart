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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: const Border(
          bottom: BorderSide(color: AppColors.primaryGreen, width: 2),
          top: BorderSide(color: Colors.white10, width: 1),
          left: BorderSide(color: Colors.white10, width: 1),
          right: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Row(
        children: [
          // SPECIAL
          _buildStat(special.toStringAsFixed(2), AppColors.primaryGreen, "SPEC"),
          
          Container(width: 1, height: 30, color: Colors.white10),          
          // B-COIN
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white.withOpacity(0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        bCoin.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),
                  const Text("B-COIN BALANCE", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.white10),         
          // KEY
          _buildStat(keyCoin.toStringAsFixed(0), Colors.cyanAccent, "KEYS"),
        ],
      ),
    );
  }

  Widget _buildStat(String value, Color color, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8)),
        ],
      ),
    );
  }
}
