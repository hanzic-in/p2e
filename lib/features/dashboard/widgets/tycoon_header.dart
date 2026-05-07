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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOrbitalStat(Icons.stars_rounded, special.toStringAsFixed(2), AppColors.primaryGreen),
          _buildOrbitalStat(Icons.monetization_on, bCoin.toStringAsFixed(0), Colors.amber),
          _buildOrbitalStat(Icons.vpn_key_rounded, keyCoin.toStringAsFixed(0), Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _buildOrbitalStat(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.only(right: 12, left: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F24),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 1),
            ),
            child: Icon(icon, color: color, size: 16, shadows: [
              Shadow(color: color, blurRadius: 10),
            ]),
          ),
          const SizedBox(width: 8),
          // Angkanya
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
