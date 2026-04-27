import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 80, color: AppColors.primaryGreen),
            SizedBox(height: 20),
            Text("CITY WALLET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            SizedBox(height: 10),
            Text("Minimum penarikan: 50.000 B-Coins", style: TextStyle(color: AppColors.textGray)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: Text("TARIK SALDO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
