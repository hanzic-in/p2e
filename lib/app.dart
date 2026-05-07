import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_view.dart';
import 'features/missions/mission_view.dart';
import 'features/mining/view/mining_view.dart';
import 'features/wallet/wallet_view.dart';

import 'core/constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    MissionView(),
    MiningView(),
    WalletView(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: bottomPadding > 10 ? bottomPadding : 20,
          ),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,

                  selectedItemColor: AppColors.primaryGreen,
                  unselectedItemColor: AppColors.textGray,

                  showSelectedLabels: true,
                  showUnselectedLabels: true,

                  selectedFontSize: 11,
                  unselectedFontSize: 11,

                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.agriculture_rounded),
                      label: 'Farm',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.paid_rounded),
                      label: 'Mission',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.memory_rounded),
                      label: 'Mining',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.wallet_rounded),
                      label: 'Wallet',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
