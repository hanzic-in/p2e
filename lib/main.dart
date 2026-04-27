import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './features/dashboard/provider/dashboard_provider.dart';
import './features/dashboard/dashboard_view.dart';
import './core/constants/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.darkBg,
      ),
      home: MainNavigation(),
    );
  }
}

// KONTROLER NAVIGASI
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardView(),
    Center(child: Text("INDUSTRIAL MISSION", style: TextStyle(color: Colors.white))),
    Center(child: Text("CITY WALLET", style: TextStyle(color: Colors.white))),
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
