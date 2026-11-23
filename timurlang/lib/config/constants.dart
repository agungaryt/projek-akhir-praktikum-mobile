// ============================================
// TimurLang - Constants Configuration
// ============================================

class AppConstants {
  // App Info
  static const String appName = 'TimurLang';
  static const String appTagline = 'Perizinan & Keselamatan Pendakian Terpadu';
  static const String appVersion = '1.0.0';

  // Database (SQLite)
  static const String dbName = 'timurlang.db';
  static const int dbVersion = 8;

  // Session
  static const String userIdKey = 'user_id';
  static const String rememberMeKey = 'remember_me';

  // API Config (Data Gunung REST API)
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
  static const String apiBaseUrlLocal = 'http://localhost:3000/api';

  // Midtrans Payment Gateway
  static bool get midtransIsProduction =>
      midtransServerKey.startsWith('Mid-') &&
      !midtransServerKey.startsWith('SB-');
  static const String midtransServerKey = 'SB-Mid-server-ggpA~I8KRa3j6U9d4~Urilpf';
  static const String midtransClientKey = 'SB-Mid-client-DSuywWCiN0pxVMZKepEY2_UW';
  static String get midtransSnapUrl => midtransIsProduction
      ? 'https://app.midtrans.com/snap/v1/transactions'
      : 'https://app.sandbox.midtrans.com/snap/v1/transactions';
  static String get midtransApiBaseUrl => midtransIsProduction
      ? 'https://api.midtrans.com/v2'
      : 'https://api.sandbox.midtrans.com/v2';

  // Operational Hours
  static const int operationalStartHour = 8;
  static const int operationalEndHour = 18;
  static const int sunsetWarningMinutes = 120; // 2 jam sebelum

  // Currency Rates (mock offline)
  static const Map<String, double> defaultCurrencyRates = {
    'IDR': 1.0,
    'USD': 0.0000625,
    'EUR': 0.0000575,
    'GBP': 0.0000494,
  };

  // Timezone offsets
  static const Map<String, int> timezoneOffsets = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'UTC': 0,
  };

  // Mountain Grades
  static const List<String> mountainGrades = [
    'Grade 1 - Mudah',
    'Grade 2 - Sedang',
    'Grade 3 - Sulit',
    'Grade 4 - Sangat Sulit',
    'Grade 5 - Ekstrem',
  ];

  // Permit Statuses
  static const String statusTerdaftar = 'Terdaftar';
  static const String statusDiajukan = 'Diajukan';
  static const String statusTervalidasi = 'Tervalidasi';
  static const String statusRescheduled = 'Rescheduled';
  static const String statusDiJalur = 'Di Jalur';
  static const String statusSelesai = 'Selesai';
  static const String statusDibatalkan = 'Dibatalkan';
  static const String statusDibatalkanBasecamp = 'Dibatalkan Basecamp';
  static const String statusDibatalkanPendaki = 'Dibatalkan Pendaki';
  static const String statusRefundDiajukan = 'Refund Diajukan';
  static const String statusRefundSelesai = 'Refund Selesai';
  static const String statusDitolak = 'Ditolak';
}
