import 'dart:async';
import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() {
    runApp(const DriverOptimizerApp());
  }, (error, stack) {
    debugPrint("GLOBAL ERROR: $error");
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