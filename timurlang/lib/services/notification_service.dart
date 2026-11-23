// ============================================
// TimurLang - Notification Service
// Modul VII: Notification & LBS
// ============================================

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Function(String? payload)? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.payload);
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'timurlang_channel',
          'TimurLang Notifikasi',
          description: 'Notifikasi izin SIMAKSI dan pendakian',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }

    _initialized = true;
  }

  /// Menampilkan notifikasi instan (Immediate Notification - Modul VII)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'timurlang_channel',
      'TimurLang Notifikasi',
      channelDescription: 'Notifikasi izin SIMAKSI dan pendakian',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Notifikasi tiket SIMAKSI berhasil diterbitkan
  Future<void> showSimaksiNotification({
    required String namaGunung,
    required String permitId,
  }) async {
    await showNotification(
      id: permitId.hashCode,
      title: 'Tiket SIMAKSI Terbit! 🎫',
      body: 'Izin pendakian Anda untuk $namaGunung telah berhasil dibuat.',
      payload: permitId,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
