import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../core/services/background_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isRunning = false;

  Future<void> startService() async {
    try {
      final service = FlutterBackgroundService();

      bool running = await service.isRunning();
      if (running) {
        debugPrint("Already running");
        return;
      }

      // PERMISSION
      final location = await Permission.location.request();
      final notification = await Permission.notification.request();

      if (!location.isGranted || !notification.isGranted) {
        debugPrint("Permission denied");
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      await BackgroundService.initialize();

      await Future.delayed(const Duration(milliseconds: 300));

      await service.startService();

      setState(() => isRunning = true);

    } catch (e) {
      debugPrint("START ERROR: $e");
    }
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");

    setState(() => isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Optimizer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRunning ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isRunning ? "Service Running" : "Service Stopped",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isRunning ? null : startService,
              child: const Text("START"),
            ),

            ElevatedButton(
              onPressed: isRunning ? stopService : null,
              child: const Text("STOP"),
            ),
          ],
        ),
      ),
    );
  }
}