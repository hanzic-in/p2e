import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MissionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("DAPATKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _missionItem("Tugas Pemula", "Install AstraPay & Register", "5.000", Icons.star),
                    _missionItem("Member Elite", "Mainkan Game Top War (Lv.10)", "25.000", Icons.emoji_events), // SUDAH FIX
                    _missionItem("Survey Harian", "Isi Survey Cepat 2 Menit", "1.500", Icons.description), // SUDAH FIX
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missionItem(String title, String desc, String reward, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 30),
          SizedBox(width: 15),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(desc, style: TextStyle(color: AppColors.textGray, fontSize: 11)),
            ],
          )),
          Text(reward, style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
