import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isRunning = false;

  bool networkOnline = false;

  double gpsAccuracy = 0;
  double speed = 0;

  StreamSubscription? _serviceStream;

  @override
  void initState() {
    super.initState();

    _listenService();
  }

  @override
  void dispose() {
    _serviceStream?.cancel();
    super.dispose();
  }

  void _listenService() {
    _serviceStream = FlutterBackgroundService()
        .on('update')
        .listen((event) {
      if (event == null) return;

      if (!mounted) return;

      setState(() {
        gpsAccuracy =
            (event['accuracy'] ?? 0).toDouble();

        speed =
            (event['speed'] ?? 0).toDouble();

        networkOnline =
            event['network'] ?? false;
      });
    });
  }

  Future<void> toggleService() async {
    final service = FlutterBackgroundService();

    if (isRunning) {
      service.invoke('stopService');
    } else {
      await service.startService();
    }

    if (!mounted) return;

    setState(() {
      isRunning = !isRunning;
    });
  }

  Widget _statusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.gps_fixed,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Driver Optimizer',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GPS & Network Stabilizer',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: toggleService,
        icon: Icon(
          isRunning
              ? Icons.stop_circle
              : Icons.play_circle_fill,
        ),
        label: Text(
          isRunning
              ? 'STOP SERVICE'
              : 'START SERVICE',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isRunning
                  ? Colors.red
                  : Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 24),

              _buildStartButton(),

              const SizedBox(height: 24),

              _statusCard(
                title: 'GPS Accuracy',
                value:
                    '${gpsAccuracy.toStringAsFixed(1)} m',
                icon: Icons.gps_fixed,
                color: Colors.green,
              ),

              const SizedBox(height: 16),

              _statusCard(
                title: 'Speed',
                value:
                    '${speed.toStringAsFixed(1)} km/h',
                icon: Icons.speed,
                color: Colors.orange,
              ),

              const SizedBox(height: 16),

              _statusCard(
                title: 'Network Status',
                value:
                    networkOnline
                        ? 'ONLINE'
                        : 'OFFLINE',
                icon:
                    networkOnline
                        ? Icons.wifi
                        : Icons.wifi_off,
                color:
                    networkOnline
                        ? Colors.green
                        : Colors.red,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}