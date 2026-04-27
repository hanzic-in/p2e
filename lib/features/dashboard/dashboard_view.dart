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
            TycoonHeader(bCoin: prov.bCoin, key: prov.key, special: prov.special),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: prov.myFarms.length,
                itemBuilder: (context, index) {
                  final farm = prov.myFarms[index];
                  return FarmListItem(
                    item: farm,
                    onTap: () {
                      if (farm.status == ProductionStatus.idle) {
                        prov.startProduction(index);
                      } else if (farm.status == ProductionStatus.ready) {
                        prov.claimResult(index);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
