import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../widgets/status_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool running = false;

  void toggleService() async {
    final service = FlutterBackgroundService();

    if (running) {
      service.invoke("stopService");
    } else {
      service.startService();
    }

    setState(() {
      running = !running;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Optimizer')),
      body: Column(
        children: [
          StatusCard(
            title: "Service",
            value: running ? "Running" : "Stopped",
            color: running ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: toggleService,
            child: Text(running ? "STOP" : "START"),
          )
        ],
      ),
    );
  }
}