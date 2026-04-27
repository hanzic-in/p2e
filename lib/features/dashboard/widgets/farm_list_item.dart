import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';

class FarmListItem extends StatelessWidget {
  final String name;
  final String production;
  final double progress;
  final bool isLocked;
  final String? lockPrice;

  const FarmListItem({
    required this.name,
    required this.production,
    this.progress = 0.0,
    this.isLocked = false,
    this.lockPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLocked ? Colors.white10 : Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Tanaman/Hewan
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
                child: Icon(isLocked ? Icons.lock : Icons.grass, color: isLocked ? Colors.grey : Colors.lime),
              ),
              const SizedBox(width: 15),
              // Info Produksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5),
                    Text("PRODUKSI: $production", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              // Tombol Aksi
              isLocked 
                ? ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: Text("Buka $lockPrice"),
                  )
                : const Icon(Icons.pets, color: Colors.white24),
            ],
          ),
          const SizedBox(height: 15),
          // Progress Bar (Loading Produksi)
          if (!isLocked)
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: progress,
              barRadius: const Radius.circular(10),
              progressColor: Colors.limeAccent,
              backgroundColor: Colors.white10,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
