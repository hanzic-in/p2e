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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        children: [
          _buildGlassStat(Icons.stars_rounded, special.toStringAsFixed(2), AppColors.primaryGreen),
          _buildVerticalDivider(),
          _buildGlassStat(Icons.monetization_on, bCoin.toStringAsFixed(0), Colors.amber),
          _buildVerticalDivider(),
          _buildGlassStat(Icons.vpn_key_rounded, keyCoin.toStringAsFixed(0), Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _buildGlassStat(IconData icon, String value, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16, shadows: [
                Shadow(color: color.withOpacity(0.5), blurRadius: 8),
              ]),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.05),
    );
  }
}
