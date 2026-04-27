import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatelessWidget {
  final String name;
  final String production;
  final double progress;
  final bool isLocked;
  final String? lockPrice;
  final IconData icon;
  final VoidCallback onUnlock;

  const FarmListItem({
    required this.name,
    required this.production,
    this.progress = 0.0,
    this.isLocked = false,
    this.lockPrice,
    required this.icon,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLocked ? Colors.white10 : AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: Icon(isLocked ? Icons.lock : icon, color: isLocked ? Colors.grey : AppColors.primaryGreen),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    Text("PRODUKSI: $production", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              if (isLocked)
                ElevatedButton(
                  onPressed: onUnlock,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(lockPrice ?? "Buka"),
                ),
            ],
          ),
          if (!isLocked) ...[
            const SizedBox(height: 12),
            LinearPercentIndicator(
              lineHeight: 6.0,
              percent: progress,
              barRadius: const Radius.circular(10),
              progressColor: AppColors.primaryGreen,
              backgroundColor: Colors.white10,
              padding: EdgeInsets.zero,
            ),
          ]
        ],
      ),
    );
  }
}
