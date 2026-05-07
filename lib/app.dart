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
          bottom: MediaQuery.of(context).viewPadding.bottom > 0 
              ? MediaQuery.of(context).viewPadding.bottom 
              : 15,
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), 
                blurRadius: 10, 
                offset: const Offset(0, 5)
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primaryGreen,
              unselectedItemColor: AppColors.textGray,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 10,
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
