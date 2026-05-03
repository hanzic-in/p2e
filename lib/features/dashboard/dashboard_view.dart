import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/dashboard_provider.dart';
import './widgets/tycoon_header.dart';
import './widgets/farm_list_item.dart';
import './models/farm_item_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ad_banner_carousel.dart';
import './models/country_model.dart';

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

              // TAB Navigation
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

              // Isi list tiap sector
              Expanded(
                child: TabBarView(
                  children: [
                    ...FarmSector.values.map((sector) {
                    final sectorItems = prov.myFarms.where((f) => f.sector == sector).toList();

                    if (sectorItems.isEmpty) {
                      return const Center(
                        child: Text("There are no assets in this sector yet", style: TextStyle(color: Colors.white24)),
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
                                    content: Text("Conditions not met: ${farm.unlockRequirements.join(', ')}"),
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
                          Expanded(
                            child: TabBarView(
                              children: [
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: _buildUrgentCard(prov),
                                ),
                                _buildCountryPage(prov, Continent.afrika),
                                _buildCountryPage(prov, Continent.asia),
                                _buildCountryPage(prov, Continent.eropa),
                                _buildCountryPage(prov, Continent.as),
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

  // CARD (URGENT)
Widget _buildUrgentCard(DashboardProvider prov) {
  final order = prov.currentUrgentOrder;
  if (order == null) {
    return Center(
      child: ElevatedButton(
        onPressed: () => prov.generateRandomOrder(),
        child: const Text("SEARCH FOR NEW ORDERS"),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg, 
      borderRadius: BorderRadius.circular(24), 
      border: Border.all(color: Colors.white10)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 80, width: 80, 
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)), 
              child: const Icon(Icons.face, color: Colors.amber, size: 40)
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.buyerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Eddie leaves in", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  Text("${order.deliveryDuration.inHours}h", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, minimumSize: const Size(double.infinity, 35)),
                    onPressed: () {
                      // Logic kirim
                    },
                    child: const Text("Load and Send", style: TextStyle(color: Colors.white, fontSize: 11)),
                  )
                ],
              ),
            )
          ],
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white10)),
        const Text("Eddie bought", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 15),
        
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: order.requiredItems.map((item) {
            final farm = prov.myFarms.firstWhere((f) => f.name == item.itemName);    
            return _orderItem(
              item.assetPath, 
              item.amount.toString(), 
              farm.stock
            );
          }).toList(),
        ),
        
        const SizedBox(height: 25),
        const Text("Gifts from buyers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
            const SizedBox(width: 5),
            Text("${order.rewardCoin.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 20),
            const Icon(Icons.vpn_key, color: Colors.amber, size: 18),
            const SizedBox(width: 5),
            Text("${order.rewardKey}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    ),
  );
}

Widget _orderItem(String assetPath, String amountNeeded, int currentStock) {
  bool isEnough = currentStock >= int.parse(amountNeeded.replaceAll(RegExp(r'[^0-9]'), ''));

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnough ? Colors.white10 : Colors.redAccent.withOpacity(0.3)
          ),
        ),
        child: Image.asset(assetPath, height: 32, width: 32),
      ),
      const SizedBox(height: 6),
      Text(
        amountNeeded, 
        style: TextStyle(
          color: isEnough ? Colors.white : Colors.redAccent, 
          fontWeight: FontWeight.bold, 
          fontSize: 11
        )
      ),
      Text(
        "Stock: $currentStock", 
        style: TextStyle(
          color: isEnough ? Colors.white24 : Colors.redAccent.withOpacity(0.5), 
          fontSize: 9
        )
      ),
    ],
  );
}

  // HELPER FUNCTIONS
  void _handleTap(FarmItem farm, DashboardProvider prov, BuildContext context) {
    if (farm.status == ProductionStatus.locked) {
      if (prov.canBeUnlocked(farm)) prov.startUnlock(farm.id);
      else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conditions not met")));
    } else {
      if (farm.status == ProductionStatus.idle) prov.startProduction(farm.id);
      else if (farm.status == ProductionStatus.ready) prov.claimResult(farm.id);
    }
  }

  // MODAL Sell
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
                Text("MARKET ${farm.name.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                  child: const Text("CONFIRM SELL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
          const Text("Increase production levels to increase revenue volume", 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
          
          const SizedBox(height: 25),
          Row(
            children: [
              _infoTile("DURATION OF IMPROVEMENT.", "${farm.level * 60}s", Icons.timer_outlined),
              const SizedBox(width: 15),
              _infoTile("UPGRADE COSTS.", "${farm.upgradePrice.toInt()}", Icons.monetization_on_outlined),
            ],
          ),

          const SizedBox(height: 25),
          const Text("ADVANCED PRODUCTION", 
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
                  const Text("DURATION", style: TextStyle(color: Colors.white24, fontSize: 8)),
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
              child: const Text("UPGRADE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

  // FUNGSI LIST NEGARA
  Widget _buildCountryPage(DashboardProvider prov, Continent continent) {
    final listNegara = prov.countries.where((c) => c.continent == continent).toList();

    if (listNegara.isEmpty) {
      return const Center(
        child: Text(
          "There are no countries on this continent yet", 
          style: TextStyle(color: Colors.white10, fontSize: 12)
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: listNegara.length,
      itemBuilder: (context, index) {
        final negara = listNegara[index];
        return _buildCountryCard(negara, prov);
      },
    );
  }

  // FUNGSI DETAIL PESANAN
  Widget _buildCountryOrderDetails(CountryOrder negara, DashboardProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white10, height: 30),
        const Text("State Order", 
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 15),
        
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: negara.requiredItems.map((item) {
            final farm = prov.myFarms.firstWhere((f) => f.name == item.itemName);
            return _orderItem(item.assetPath, item.amount.toString(), farm.stock);
          }).toList(),
        ),

        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5))
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Logic kirim barang
                },
                child: const Text("LOAD AND SEND TO THE COUNTRY", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // FUNGSI KARTU NEGARA
  Widget _buildCountryCard(CountryOrder negara, DashboardProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    negara.flagAsset, 
                    fit: BoxFit.cover, 
                    errorBuilder: (c, e, s) => const Icon(Icons.flag, color: Colors.white24)
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${negara.level} LVL", style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(negara.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.vpn_key, color: Colors.amber, size: 16),
                  Text("${negara.rewardKeyMin}-${negara.rewardKeyMax}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 25),

          if (!negara.isUnlocked)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.white10)),
                ),
                onPressed: () => prov.unlockCountry(negara.id),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.amber, size: 14),
                    const SizedBox(width: 10),
                    Text("UNLOCK 💰 ${negara.unlockCost.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            _buildCountryOrderDetails(negara, prov),
        ],
      ),
    );
  }
}
