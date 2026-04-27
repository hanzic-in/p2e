import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_view.dart';
import 'core/constants/app_colors.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title);
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.darkBg,
    body: Center(child: Text(title, style: TextStyle(color: Colors.white))),
  );
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar halaman
  final List<Widget> _pages = [
    DashboardView(),
    PlaceholderPage("INDUSTRIAL MISSION"), // Halaman Misi nanti
    PlaceholderPage("CITY WALLET"),      // Halaman WD nanti
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: AppColors.textGray,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: "City"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Mission"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
        ],
      ),
    );
  }
}
