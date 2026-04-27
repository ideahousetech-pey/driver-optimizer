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
      // Request permission
      final location = await Permission.location.request();
      final notification = await Permission.notification.request();

      if (!location.isGranted || !notification.isGranted) {
        debugPrint("Permission ditolak");
        return;
      }

      // Init service
      await BackgroundService.initialize();

      // Start service
      final service = FlutterBackgroundService();
      bool isServiceRunning = await service.isRunning();

      if (!isServiceRunning) {
        service.startService();
      }

      setState(() {
        isRunning = true;
      });

      debugPrint("Service started");
    } catch (e) {
      debugPrint("ERROR START SERVICE: $e");
    }
  }

  Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");

    setState(() {
      isRunning = false;
    });

    debugPrint("Service stopped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Optimizer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRunning ? Colors.green[200] : Colors.red[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isRunning ? "Service Running" : "Service Stopped",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isRunning ? null : startService,
              child: const Text("START"),
            ),

            const SizedBox(height: 10),

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