import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double hashrate;

  const BalanceCard({required this.balance, required this.hashrate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryNeon.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "TOTAL MINING REWARD",
            style: TextStyle(color: AppColors.textGray, fontSize: 12, letterSpacing: 2),
          ),
          SizedBox(height: 10),
          Text(
            balance.toStringAsFixed(4),
            style: GoogleFonts.orbitron(
              color: AppColors.goldAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, color: AppColors.primaryNeon, size: 16),
              Text(
                "Rate: ${hashrate.toStringAsFixed(4)} / sec",
                style: TextStyle(color: AppColors.primaryNeon, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
