import 'package:flutter/material.dart';
import './models/mission_model.dart';
import '../../core/constants/app_colors.dart';

class MissionDetailView extends StatelessWidget {
  final Mission mission;

  const MissionDetailView({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(mission.title.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Atas
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(mission.bannerUrl, 
                height: 180, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.white10, height: 180)),
            ),
            const SizedBox(height: 25),
            const Text("LANGKAH MISI", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
            const SizedBox(height: 15),
            
            ...mission.steps.map((step) => _buildStepCard(step)).toList(),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("MULAI MISI SEKARANG", 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(MissionStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryGreen,
                child: Text("${step.order}", 
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(step.title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Text("+${step.reward}", 
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 36, top: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.description, 
                  style: const TextStyle(color: AppColors.textGray, fontSize: 12, height: 1.5)),
                
                if (step.type == 'screenshot') ...[
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.05),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen, size: 18),
                            SizedBox(width: 8),
                            Text("KIRIM BUKTI SCREENSHOT", 
                              style: TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                if (step.exampleImageUrl != null) ...[
                  const SizedBox(height: 15),
                  const Text("LIHAT CONTOH GAMBAR:", 
                    style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(step.exampleImageUrl!, 
                      height: 120, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.white10, height: 120, child: const Icon(Icons.image_not_supported, color: Colors.white24))),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
