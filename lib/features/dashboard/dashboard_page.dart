import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/gps_service.dart';
import '../../core/services/network_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isRunning = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> toggleService() async {
    final service = FlutterBackgroundService();

    if (isRunning) {
      service.invoke('stopService');
    } else {
      await service.startService();
    }

    setState(() {
      isRunning = !isRunning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                'Driver Optimizer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'GPS & Network Stabilizer',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E293B),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isRunning
                          ? Icons.shield
                          : Icons.shield_outlined,
                      size: 80,
                      color: isRunning
                          ? Colors.greenAccent
                          : Colors.white54,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      isRunning
                          ? 'PROTECTION ACTIVE'
                          : 'SERVICE STOPPED',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      isRunning
                          ? 'GPS & Network optimized'
                          : 'Tap start to activate',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: 'GPS Accuracy',
                      value:
                          '${GPSService.accuracy.toStringAsFixed(0)} m',
                      icon: Icons.gps_fixed,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _infoCard(
                      title: 'Ping',
                      value:
                          '${NetworkService.pingMs} ms',
                      icon: Icons.network_ping,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      title: 'Speed',
                      value:
                          '${GPSService.speed.toStringAsFixed(0)} km/h',
                      icon: Icons.speed,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _infoCard(
                      title: 'Network',
                      value: NetworkService.isConnected
                          ? 'ONLINE'
                          : 'OFFLINE',
                      icon: Icons.wifi,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: toggleService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning
                        ? Colors.redAccent
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    isRunning
                        ? 'STOP SERVICE'
                        : 'START SERVICE',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.greenAccent,
            size: 28,
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}