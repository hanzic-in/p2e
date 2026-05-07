import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_view.dart';
import 'features/missions/mission_view.dart';
import 'features/mining/view/mining_view.dart';
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
    MiningView(),
    WalletView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom > 10 
              ? MediaQuery.of(context).viewPadding.bottom 
              : 20,
          left: 20,
          right: 20,
        ),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4), 
                blurRadius: 15, 
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primaryGreen,
              unselectedItemColor: AppColors.textGray,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.agriculture_rounded), label: "Farm"),
                BottomNavigationBarItem(icon: Icon(Icons.paid_rounded), label: "Mission"),
                BottomNavigationBarItem(icon: Icon(Icons.memory_rounded), label: "Mining"), 
                BottomNavigationBarItem(icon: Icon(Icons.wallet_rounded), label: "Wallet"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
