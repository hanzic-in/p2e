import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/dashboard_provider.dart';
import './widgets/balance_card.dart';
import './widgets/farm_list_item.dart';
import '../../core/constants/app_colors.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("BULLISH FARM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              Consumer<DashboardProvider>(
                builder: (context, prov, _) => BalanceCard(balance: prov.balance, hashrate: 0),
              ),
              const SizedBox(height: 25),
              const Text("PERTANIAN", style: TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: Consumer<DashboardProvider>(
                  builder: (context, prov, _) => ListView.builder(
                    itemCount: prov.myFarms.length,
                    itemBuilder: (context, index) {
                      final farm = prov.myFarms[index];
                      return FarmListItem(
                        name: farm.name,
                        production: farm.productionLabel,
                        icon: farm.icon,
                        isLocked: farm.isLocked,
                        lockPrice: farm.unlockPrice > 0 ? "${farm.unlockPrice.toInt()}" : null,
                        progress: (DateTime.now().millisecondsSinceEpoch % (farm.cycleDuration * 1000)) / (farm.cycleDuration * 1000),
                        onUnlock: () => prov.unlockFarm(index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
