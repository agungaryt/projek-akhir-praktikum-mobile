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

  // Inisialisasi database factory untuk web platform........
  if (kIsWeb) {
    try {
      DatabaseService.initForWeb();
    } catch (e) {
      debugPrint('⚠️ Error initForWeb: $e');
    }
  }

  // ============================================================================
  // 💾 [MODUL VI - DATABASE LOKAL: INISIALISASI & KONEKSI SQLITE SAAT STARTUP]
  // ----------------------------------------------------------------------------
  // Lokasi File Service: lib/services/database_service.dart
  // Nama Database: timurlang.db
  // Cara Kerja Inisiasi:
  // 1. Memanggil DatabaseService.instance.database (Singleton Pattern).
  // 2. Baris ini mengecek apakah file database 'timurlang.db' sudah ada di storage HP.
  // 3. Jika belum ada, openDatabase() akan otomatis mengeksekusi _onCreate()
  //    untuk membuat seluruh tabel (users, mountains, simaksi_permits, dll)
  //    dan mengisi 50 data awal gunung (_seedMountains).
  // 4. Jika sudah ada, koneksi database langsung dibuka dan siap dipakai.
  // ============================================================================
  try {
    await DatabaseService.instance.database;
    debugPrint('✅ [SQLITE] Database lokal berhasil diinisialisasi & terkoneksi!');
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
