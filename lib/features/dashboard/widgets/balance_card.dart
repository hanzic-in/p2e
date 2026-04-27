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
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text("TOTAL EARNINGS", style: TextStyle(color: AppColors.textGray, fontSize: 10, letterSpacing: 1.5)),
          SizedBox(height: 8),
          Text(
            balance.toStringAsFixed(2),
            style: GoogleFonts.orbitron(
              color: AppColors.primaryGreen,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text("B-Coins", style: TextStyle(color: AppColors.primaryGreen.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
}
