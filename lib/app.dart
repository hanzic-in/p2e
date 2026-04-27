import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_view.dart';
import 'features/missions/mission_view.dart';
import 'features/wallet/wallet_view.dart';
import 'core/constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardView(),
    MissionView(),
    WalletView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textGray,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: "Farm"),
          BottomNavigationBarItem(icon: Icon(Icons.paid), label: "Dapatkan"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Dompet"),
        ],
      ),
    );
  }
}
