import 'package:flutter/material.dart';
import 'core/services/background_service.dart';
import 'features/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.initialize();

  FlutterError.onError = (FlutterErrorDetails details) {
    // log error production
  };

  runApp(const DriverOptimizerApp());

  Future.delayed(const Duration(seconds: 1), () {
    BackgroundService.initialize();
  });
}

class DriverOptimizerApp extends StatelessWidget {
  const DriverOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Optimizer',
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}