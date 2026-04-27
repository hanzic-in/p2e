import 'package:flutter/material.dart';
import './widgets/mission_card.dart';
import './models/mission_model.dart';
import '../../core/constants/app_colors.dart';

class MissionView extends StatelessWidget {
  final List<Mission> missions = [
    Mission(
      title: "GOPAY",
      logoUrl: "https://cdn-icons-png.flaticon.com/512/10061/10061836.png",
      bannerUrl: "https://images.unsplash.com/photo-1611974714112-9e90098f98b9?q=80&w=800&auto=format&fit=crop",
      reward: 5000,
    ),
    Mission(
      title: "TOKOPEDIA",
      logoUrl: "https://cdn-icons-png.flaticon.com/512/825/825590.png",
      bannerUrl: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=800&auto=format&fit=crop",
      reward: 3500,
    ),
    Mission(
      title: "MOBILE LEGENDS",
      logoUrl: "https://cdn-icons-png.flaticon.com/512/8002/8002150.png",
      bannerUrl: "https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800&auto=format&fit=crop",
      reward: 12000,
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
