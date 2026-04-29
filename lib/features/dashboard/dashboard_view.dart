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
      length: FarmSector.values.length + 1,
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
                  tabs: [
                    ...FarmSector.values.map((sector) {
                      return Tab(text: sector.name.toUpperCase());
                    }).toList(),
                    const Tab(
                      icon: Icon(Icons.local_shipping_rounded, size: 20),
                    ),
                  ],
                ),
              ),

              // (Isi list setiap sektor)
              Expanded(
                child: TabBarView(
                  children: [
                    ...FarmSector.values.map((sector) {
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
                                prov.startUnlock(farm.id);
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
                          onUpgrade: () => _showUpgradePopup(context, farm, prov),
                          onSell: isLocked ? () {} : () => _showSellDialog(context, farm.id, prov),
                        );
                      },
                    );
                  }).toList(),
                    DefaultTabController(
                      length: 5,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                            child: TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.center,
                              indicatorColor: Colors.transparent,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white24,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2),
                              tabs: [            
                                const Tab(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.directions_boat_filled_rounded, color: Colors.amber, size: 22),
                                       SizedBox(height: 4),
                                      Text("URGENT"),
                                    ],
                                  ),
                                ),
                                const Tab(text: "AFRIKA"),
                                const Tab(text: "ASIA"),
                                const Tab(text: "EROPA"),
                                const Tab(text: "AS"),
                              ],
                            ),
                          ),
                          // ISI HALAMAN
                          const Expanded(
                            child: TabBarView(
                              children: [
                                      SingleChildScrollView(
                                        padding: const EdgeInsets.all(20),
                                        child: _buildUrgentCard(prov),
                                      ),
                                Center(child: Text("AFRIKA", style: TextStyle(color: Colors.white10))),
                                Center(child: Text("ASIA", style: TextStyle(color: Colors.white10))),
                                Center(child: Text("EROPA", style: TextStyle(color: Colors.white10))),
                                Center(child: Text("AS", style: TextStyle(color: Colors.white10))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    // --- KARTU EDDIE (URGENT) ---
  Widget _buildUrgentCard(DashboardProvider prov) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(height: 80, width: 80, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.face, color: Colors.amber, size: 40)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Eagle Eye Eddie", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Eddie berangkat dalam", style: TextStyle(color: Colors.white38, fontSize: 10)),
                    const Text("7h 15m", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, minimumSize: const Size(double.infinity, 35)),
                      onPressed: () {},
                      child: const Text("Muat dan Kirim", style: TextStyle(color: Colors.white, fontSize: 11)),
                    )
                  ],
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white10)),
          const Text("Eddie membeli", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 15),
          
          // --- WRAP BUAT ROMBONGAN ITEM ---
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: [
              // Nanti ini di-loop dari Provider, sekarang dummy dulu
              _orderItem("🌾", "543", true),
              _orderItem("🥕", "541", false),
              _orderItem("🍎", "1.3K", true),
              _orderItem("🌽", "200", false),
              _orderItem("🥚", "50", true),
            ],
          ),
          
          const SizedBox(height: 25),
          const Text("Hadiah dari Eddie", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
              const SizedBox(width: 5),
              const Text("495K", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              const Icon(Icons.vpn_key, color: Colors.amber, size: 18),
              const SizedBox(width: 5),
              const Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _orderItem(String emoji, String amount, bool isEnough) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(color: isEnough ? Colors.white : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }

  // --- HELPER FUNCTIONS ---
  void _handleTap(FarmItem farm, DashboardProvider prov, BuildContext context) {
    if (farm.status == ProductionStatus.locked) {
      if (prov.canBeUnlocked(farm)) prov.startUnlock(farm.id);
      else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syarat belum terpenuhi")));
    } else {
      if (farm.status == ProductionStatus.idle) prov.startProduction(farm.id);
      else if (farm.status == ProductionStatus.ready) prov.claimResult(farm.id);
    }
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

void _showUpgradePopup(BuildContext context, FarmItem farm, DashboardProvider prov) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(farm.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white24))
            ],
          ),
          const SizedBox(height: 10),
          Image.asset(farm.assetPath, height: 70), 
          const SizedBox(height: 15),
          Text("TINGKATKAN KE LVL ${farm.level + 1}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tingkatkan level produksi untuk meningkatkan volume pendapatan", 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
          
          const SizedBox(height: 25),
          Row(
            children: [
              _infoTile("DURASI PENINGK.", "${farm.level * 60}s", Icons.timer_outlined),
              const SizedBox(width: 15),
              _infoTile("BIAYA PENINGK.", "${farm.upgradePrice.toInt()}", Icons.monetization_on_outlined),
            ],
          ),

          const SizedBox(height: 25),
          const Text("PRODUKSI TINGKAT LANJUT", 
            style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 15),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Icon(Icons.access_time_filled, color: Colors.amber, size: 16),
                  const SizedBox(height: 5),
                  Text("${farm.nextLevelProductionTime}s",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text("DURASI", style: TextStyle(color: Colors.white24, fontSize: 8)),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                children: [
                  Image.asset(farm.assetPath, height: 16),
                  const SizedBox(height: 5),
                  Text("${farm.nextStockYield}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text("HASIL", style: TextStyle(color: Colors.white24, fontSize: 8)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
              ),
              onPressed: () {
                prov.startUpgrade(farm.id);
                Navigator.pop(context);
              },
              child: const Text("TINGKATKAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    ),
  );
}

  Widget _infoTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.amber, size: 14),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            )
          ],
        ),
      ),
    );
  }

}
