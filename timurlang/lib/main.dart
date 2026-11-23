import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/mountain_controller.dart';
import 'controllers/simaksi_controller.dart';
import 'controllers/profile_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale formatting untuk tanggal (Indonesia)
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('⚠️ Error init locale: $e');
  }

  // Inisialisasi database factory untuk web platform
  if (kIsWeb) {
    try {
      DatabaseService.initForWeb();
    } catch (e) {
      debugPrint('⚠️ Error initForWeb: $e');
    }
  }

  // Pre-inisialisasi database lokal (SQLite - Modul VI)
  try {
    await DatabaseService.instance.database;
  } catch (e) {
    debugPrint('⚠️ Error inisialisasi SQLite: $e');
  }

  // Inisialisasi Notifikasi Lokal (Modul VII)
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('⚠️ Error inisialisasi Notifikasi: $e');
  }

  // Dependency Injection GetX (Modul VIII)
  Get.put(AuthController(), permanent: true);
  Get.put(MountainController(), permanent: true);
  Get.put(SimaksiController(), permanent: true);
  Get.put(ProfileController(), permanent: true);

  runApp(const MainApp());
}
