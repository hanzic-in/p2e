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

  final List<Widget> _pages = [
    DashboardView(),
    MissionView(),
    MiningView(),
    WalletView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(15, 15, 15, 12),

        child: Container(
          height: 64,

          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),

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

                iconSize: 24,

                selectedFontSize: 11,
                unselectedFontSize: 10,

                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),

                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),

                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.agriculture_rounded),
                    ),
                    label: "Farm",
                  ),

                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.paid_rounded),
                    ),
                    label: "Mission",
                  ),

                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.memory_rounded),
                    ),
                    label: "Mining",
                  ),

                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Icon(Icons.wallet_rounded),
                    ),
                    label: "Wallet",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
