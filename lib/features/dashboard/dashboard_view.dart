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

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            TycoonHeader(bCoin: prov.bCoin, keyCoin: prov.keyCoin, special: prov.special),
            AdBannerCarousel(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: prov.myFarms.length,
                itemBuilder: (context, index) {
                  final farm = prov.myFarms[index];
                  return FarmListItem(
                    item: farm,
                    onTap: () {
                      if (farm.status == ProductionStatus.idle) prov.startProduction(index);
                      else if (farm.status == ProductionStatus.ready) prov.claimResult(index);
                    },
                    onUpgrade: () => prov.upgradeFarm(index),
                    onSell: () => _showSellDialog(context, index, prov),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showSellDialog(BuildContext context, int index, DashboardProvider prov) {
  int amountToSell = 1;
  var farm = prov.myFarms[index];
  if (farm.stock == 0) return;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
              Text(
                "PASAR ${farm.name.toUpperCase()}",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text("Stok tersedia: ${farm.stock} unit", style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 30),
            
              Text(
                "$amountToSell",
                style: const TextStyle(color: AppColors.primaryGreen, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryGreen,
                  thumbColor: AppColors.primaryGreen,
                  overlayColor: AppColors.primaryGreen.withOpacity(0.2),
                  valueIndicatorColor: AppColors.primaryGreen,
                ),
                child: Slider(
                  value: amountToSell.toDouble(),
                  min: 1,
                  max: farm.stock.toDouble(),
                  onChanged: (val) => setDialogState(() => amountToSell = val.toInt()),
                ),
              ),
              
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ESTIMASI PENDAPATAN", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("${amountToSell * 10} B-COIN", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("BATAL", style: TextStyle(color: Colors.white38)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        prov.sellStock(index, amountToSell);
                        Navigator.pop(context);
                      },
                      child: const Text("KONFIRMASI JUAL", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
