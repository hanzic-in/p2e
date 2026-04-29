import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './features/dashboard/provider/dashboard_provider.dart';
import 'features/mining/provider/mining_provider.dart';
import './core/constants/app_colors.dart';
import './app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => MiningProvider()),
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
      title: 'Bullish Farm',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.darkBg,
      ),
      home: MainNavigation(),
    );
  }
}
