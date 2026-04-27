import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/dashboard_provider.dart';
import './widgets/balance_card.dart';
import './widgets/city_grid.dart';
import '../../core/constants/app_colors.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text("BUITENZORG CITY", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 20),
              
              // Widget Saldo
              BalanceCard(balance: provider.balance, hashrate: provider.hashrate),
              
              SizedBox(height: 30),
              Text("CONSTRUCTION SLOTS", 
                style: TextStyle(color: AppColors.textGray, fontSize: 14)),
              SizedBox(height: 15),

              // Tempat Grid Kota
              Expanded(child: CityGrid()),

              // Tombol Bensin (Iklan Video)
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: () {
                    // Logic nonton iklan di sini nanti
                  },
                  child: Text("RECHARGE ENERGY (WATCH AD)", 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
