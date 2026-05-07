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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlowCapsule(Icons.stars_rounded, special.toStringAsFixed(4), AppColors.primaryGreen, "SPECIAL"),
          _buildGlowCapsule(Icons.monetization_on, bCoin.toStringAsFixed(1), Colors.amber, "B-COIN"),
          _buildGlowCapsule(Icons.vpn_key_rounded, keyCoin.toStringAsFixed(1), Colors.cyanAccent, "KEY"),
        ],
      ),
    );
  }

  Widget _buildGlowCapsule(IconData icon, String value, Color color, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label, 
              style: TextStyle(
                color: color.withOpacity(0.6), 
                fontSize: 8, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 0.5
              )
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900, 
                      fontSize: 13
                    )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
