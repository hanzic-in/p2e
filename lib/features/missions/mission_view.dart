import 'package:flutter/material.dart';
import './widgets/mission_card.dart';
import './models/mission_model.dart';
import '../../core/constants/app_colors.dart';

class MissionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Mission> missions = [
      Mission(
        id: "1",
        title: "GOPAY",
        logoUrl: "https://cdn-icons-png.flaticon.com/512/10061/10061836.png",
        bannerUrl: "https://images.unsplash.com/photo-1611974714112-9e90098f98b9?q=80&w=800&auto=format&fit=crop",
        totalReward: 5000,
        steps: [MissionStep(title: "Install AstraPay", reward: 5000)],
      ),
      Mission(
        id: "2",
        title: "TOKOPEDIA",
        logoUrl: "https://cdn-icons-png.flaticon.com/512/825/825590.png",
        bannerUrl: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=800&auto=format&fit=crop",
        totalReward: 3500,
        steps: [MissionStep(title: "Buka Tokopedia", reward: 3500)],
      ),
    ];

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
