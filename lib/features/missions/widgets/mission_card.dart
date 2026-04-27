import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../mission_detail_view.dart';
import '../../../../core/constants/app_colors.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MissionDetailView(mission: mission),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Logo + Title + Reward
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      mission.logoUrl,
                      width: 45, height: 45, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.white10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mission.title.toUpperCase(), 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      "+${mission.totalReward}",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)
                    ),
                  ),
                ],
              ),
            ),
            // Banner Utama
            Container(
              width: double.infinity,
              height: 180,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  mission.bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white10,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
