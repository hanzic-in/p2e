import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/dashboard_provider.dart';
import '../models/building_model.dart';
import '../../../core/constants/app_colors.dart';

class CityGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final building = provider.slots[index];

        return GestureDetector(
          onTap: () => _showBuildMenu(context, index, provider),
          child: Container(
            decoration: BoxDecoration(
              color: building == null ? AppColors.cardBg : AppColors.primaryNeon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: building == null ? Colors.white10 : AppColors.primaryNeon,
              ),
            ),
            child: building == null
                ? const Icon(Icons.add, color: Colors.white24)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_city, color: AppColors.primaryNeon, size: 30),
                      const SizedBox(height: 5),
                      Text(
                        building.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 8, color: Colors.white),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showBuildMenu(BuildContext context, int slotIndex, DashboardProvider provider) {
    if (provider.slots[slotIndex] != null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CONSTRUCTION MENU",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // List gedung dari model
              ...buildingList.map((b) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.build_circle, color: AppColors.primaryNeon),
                    ),
                    title: Text(b.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      "+${b.addedHashrate} koin/sec",
                      style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNeon,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Di sini nanti tempat logic iklan
                        provider.buildStructure(slotIndex, b);
                        Navigator.pop(context);
                      },
                      child: Text("${b.adRequired} ADS"),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
