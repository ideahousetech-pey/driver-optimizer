import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint("FLUTTER ERROR: ${details.exception}");
  };

  runApp(const DriverOptimizerApp());
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