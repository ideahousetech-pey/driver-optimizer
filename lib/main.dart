import 'dart:ui'; // ← tambahkan untuk PlatformDispatcher
import 'package:flutter/material.dart';
import 'core/services/background_service.dart';
import 'features/dashboard/dashboard_page.dart';

/// Flag global agar DashboardPage tahu apakah service siap
bool isBackgroundServiceReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- Error handler global (SOLUSI NO.4) ----------
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Background isolate error: $error');
    debugPrint('Stack trace: $stack');
    // Return true agar error tidak mematikan aplikasi utama (meskipun isolate mungkin sudah mati)
    return true;
  };

  try {
    await BackgroundService.initialize();
    isBackgroundServiceReady = true;
    debugPrint('BackgroundService berhasil diinisialisasi');
  } catch (e, stackTrace) {
    debugPrint('Gagal inisialisasi BackgroundService: $e');
    debugPrint(stackTrace.toString());
  }

  runApp(const DriverOptimizerApp());
}

class DriverOptimizerApp extends StatelessWidget {
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