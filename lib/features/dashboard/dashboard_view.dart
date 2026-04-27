import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/dashboard_provider.dart';
import './widgets/tycoon_header.dart';
import './widgets/farm_list_item.dart';
import './models/farm_item_model.dart';
import '../../core/constants/app_colors.dart';

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
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text("Jual ${farm.name}", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Jumlah: $amountToSell / ${farm.stock}", style: const TextStyle(color: Colors.white70)),
              Slider(
                value: amountToSell.toDouble(),
                min: 1,
                max: farm.stock.toDouble(),
                activeColor: AppColors.primaryGreen,
                onChanged: (val) => setDialogState(() => amountToSell = val.toInt()),
              ),
              Text("Hasil: ${amountToSell * 10} B-Coin", style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
            ElevatedButton(
              onPressed: () {
                prov.sellStock(index, amountToSell);
                Navigator.pop(context);
              },
              child: const Text("JUAL"),
            ),
          ],
        ),
      ),
    );
  }
}
