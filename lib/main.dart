import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './features/dashboard/provider/dashboard_provider.dart';
import './features/dashboard/dashboard_view.dart';

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
      theme: ThemeData.dark(),
      home: DashboardView(),
    );
  }
}
