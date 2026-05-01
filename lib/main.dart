import 'package:flutter/material.dart';

import 'core/services/background_service.dart';
import 'features/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BackgroundService.initialize();

  runApp(const DriverOptimizerApp());
}

class DriverOptimizerApp
    extends StatelessWidget {
  const DriverOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver Optimizer',
      theme: ThemeData.dark(),
      home: const DashboardPage(),
    );
  }
}