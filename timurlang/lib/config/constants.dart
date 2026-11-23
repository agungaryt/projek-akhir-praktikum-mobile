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

  // ============================================================================
  // 🔑 [PENJELASAN & KONFIGURASI API KEY - SESUAI MODUL V HTTP REQUEST]
  // ----------------------------------------------------------------------------
  // ❓ APA ITU API KEY?
  // - API Key adalah token/string rahasia unik yang berfungsi sebagai "KTP digital"
  //   atau tanda pengenal aplikasi client saat memanggil REST API server.
  // - Sesuai Modul V (Halaman 9):
  //   "Beberapa API membutuhkan API key untuk autentikasi, yakni sebuah token
  //    khusus yang membuktikan bahwa penggunanya terdaftar dan berhak mengakses data."
  //
  // 📥 CARA MENGAMBIL / MENDAPATKAN API KEY:
  // 1. API Publik / Pihak Ketiga (Contoh: Midtrans, OpenWeather, TMDb):
  //    - Buka website dashboard provider (misal: dashboard.midtrans.com).
  //    - Login / Register akun developer.
  //    - Buka menu 'Settings' -> 'Access Keys' (Kunci Akses).
  //    - Salin 'Server Key' (untuk backend/HTTP auth) atau 'Client Key' (untuk frontend).
  // 2. Custom API Sendiri (Contoh: Mountain REST API Python di folder mountain_api):
  //    - Dibuat sendiri sebagai token autentikasi rahasia bersama (Shared Secret Token).
  //    - Client mengirim token via HTTP Header ('x-api-key'), dan server memvalidasinya.
  // ============================================================================

  // 1. API Config & API Key untuk Mountain REST API (Modul V)
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
  static const String apiBaseUrlLocal = 'http://localhost:3000/api';
  // API Key rahasia client untuk mengakses REST API Gunung
  static const String mountainApiKey = 'timurlang_api_key_sec_2026';

  // 2. Midtrans Payment Gateway API Keys
  static bool get midtransIsProduction =>
      midtransServerKey.startsWith('Mid-') &&
      !midtransServerKey.startsWith('SB-');
  // Server Key (Digunakan di HTTP Header 'Authorization: Basic <base64>' untuk verifikasi transaksi)
  static const String midtransServerKey = 'SB-Mid-server-ggpA~I8KRa3j6U9d4~Urilpf';
  // Client Key (Digunakan untuk inisialisasi pembayaran frontend/Snap)
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
