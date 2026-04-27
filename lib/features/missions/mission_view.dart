import 'package:flutter/material.dart';
import './widgets/mission_card.dart';
import './models/mission_model.dart';
import '../../core/constants/app_colors.dart';

class MissionView extends StatelessWidget {
  final List<Mission> missions = [
    Mission(
      title: "Solusiku",
      logoUrl: "https://via.placeholder.com/100",
      bannerUrl: "https://via.placeholder.com/400x200/2ecc71/ffffff?text=KHUSUS+PENGGUNA+BARU",
      reward: 161,
    ),
    Mission(
      title: "Adapundi",
      logoUrl: "https://via.placeholder.com/100",
      bannerUrl: "https://via.placeholder.com/400x200/3498db/ffffff?text=PINJAMAN+CEPAT",
      reward: 150,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("DAPATKAN POIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: missions.length,
                itemBuilder: (context, index) => MissionCard(mission: missions[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
