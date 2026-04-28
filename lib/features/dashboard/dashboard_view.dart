import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/dashboard_provider.dart';
import './widgets/tycoon_header.dart';
import './widgets/farm_list_item.dart';
import './models/farm_item_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ad_banner_carousel.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DashboardProvider>(context);
    
    return DefaultTabController(
      length: FarmSector.values.length,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SafeArea(
          child: Column(
            children: [
              TycoonHeader(bCoin: prov.bCoin, keyCoin: prov.keyCoin, special: prov.special),
              const AdBannerCarousel(),

              // TAB NAVIGASI
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  indicatorColor: AppColors.primaryGreen,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: Colors.white24,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                  tabs: FarmSector.values.map((sector) {
                    return Tab(text: sector.name.toUpperCase());
                  }).toList(),
                ),
              ),

              // (Isi list setiap sektor)
              Expanded(
                child: TabBarView(
                  children: FarmSector.values.map((sector) {
                    final sectorItems = prov.myFarms.where((f) => f.sector == sector).toList();

                    if (sectorItems.isEmpty) {
                      return const Center(
                        child: Text("Belum ada aset di sektor ini", style: TextStyle(color: Colors.white24)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: sectorItems.length,
                      itemBuilder: (context, index) {
                        final farm = sectorItems[index];
                        final canOpen = prov.canBeUnlocked(farm);
                        final isLocked = farm.status == ProductionStatus.locked;

                        return FarmListItem(
                          item: farm,
                          allItems: prov.myFarms, 
                          onTap: () {
                            if (isLocked) {
                              if (canOpen) {
                                prov.unlockFarm(farm.id);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text("Syarat belum terpenuhi: ${farm.unlockRequirements.join(', ')}"),
                                  ),
                                );
                              }
                            } else {
                              if (farm.status == ProductionStatus.idle) {
                                prov.startProduction(farm.id);
                              } else if (farm.status == ProductionStatus.ready) {
                                prov.claimResult(farm.id);
                              }
                            }
                          },
                          onUpgrade: isLocked ? () {} : () => prov.upgradeFarm(farm.id),
                          onSell: isLocked ? () {} : () => _showSellDialog(context, farm.id, prov),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL JUAL ---
  void _showSellDialog(BuildContext context, int farmId, DashboardProvider prov) {
    int amountToSell = 1;
    var farm = prov.myFarms.firstWhere((f) => f.id == farmId);
    if (farm.stock == 0) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_checkout, color: AppColors.primaryGreen, size: 50),
                const SizedBox(height: 16),
                Text("PASAR ${farm.name.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Text("$amountToSell", style: const TextStyle(color: AppColors.primaryGreen, fontSize: 40, fontWeight: FontWeight.bold)),
                Slider(
                  value: amountToSell.toDouble(),
                  min: 1,
                  max: farm.stock.toDouble(),
                  activeColor: AppColors.primaryGreen,
                  onChanged: (val) => setDialogState(() => amountToSell = val.toInt()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    prov.sellStock(farmId, amountToSell);
                    Navigator.pop(context);
                  },
                  child: const Text("KONFIRMASI JUAL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
