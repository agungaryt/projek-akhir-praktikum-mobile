// ============================================================================
// 💾 [MODUL VI - DATABASE LOKAL (SQLITE OFFLINE-FIRST STORAGE)]
// ----------------------------------------------------------------------------
// 📍 LETAK CODINGAN DATABASE LOKAL:
//    File: lib/services/database_service.dart
//    Nama File Database Fisik di HP: 'timurlang.db' (didefinisikan di AppConstants.dbName)
//
// 🔌 CARA MENGHUBUNGKAN / INISIALISASINYA:
//    1. Singleton Pattern:
//       Menggunakan 'DatabaseService.instance' agar hanya ada 1 koneksi database
//       yang aktif di seluruh aplikasi (mencegah memory leak & lock database).
//    2. Jalur Penyimpanan (Path):
//       Memanggil 'getDatabasesPath()' untuk mendapatkan direktori database aman
//       bawaan Android/iOS, lalu digabungkan menjadi: path/timurlang.db
//    3. Pembukaan Database (openDatabase):
//       Membuka file SQLite dengan 'openDatabase(path, version: 8, onCreate: _onCreate)'.
//    4. Pembuatan Tabel Pertama Kali (_onCreate):
//       Jika database baru dibuat, fungsi '_onCreate' otomatis dieksekusi untuk
//       menjalankan query 'CREATE TABLE' untuk 5 tabel utama:
//       - 'users'             : Akun pendaki (nama, email, password hash SHA-256)
//       - 'mountains'         : Master data gunung (offline cache 50 gunung)
//       - 'simaksi_permits'   : Tiket/Izin pendakian yang dipesan user
//       - 'user_personal_data': Data identitas KTP & domisili pendaki
//       - 'medical_profiles'  : Data rekam medis, golongan darah, kontak darurat
//    5. Inisialisasi Data Awal (Seeding):
//       Method '_seedMountains' otomatis mengisi 50 data gunung awal ke tabel
//       'mountains' saat pertama kali aplikasi di-install.
//
// 🎯 CARA PENGGUNAAN DI CONTROLLER / SCREEN LAIN:
//    final _db = DatabaseService.instance;
//    await _db.getAllMountains(); // Read
//    await _db.insertSimaksiPermit(permit); // Create
//    await _db.updatePermitStatus(id, status); // Update
//    await _db.deletePermit(id); // Delete
// ============================================================================

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../config/constants.dart';
import '../data/seed_data.dart';
import '../models/user.dart';
import '../models/mountain.dart';
import '../models/simaksi_permit.dart';
import '../models/user_personal_data.dart';
import '../models/medical_profile.dart';

class DatabaseService {
  // Variabel penampung instance database SQLite di memori
  static Database? _database;

  // --------------------------------------------------------------------------
  // 🔌 1. SINGLETON PATTERN: Menjamin hanya ada 1 instance DatabaseService
  // --------------------------------------------------------------------------
  static final DatabaseService instance = DatabaseService._internal();

  // Konstruktor private agar kelas tidak bisa di-instansiasi sembarangan (harus lewat .instance)
  DatabaseService._internal();

  /// Khusus platform Web: menggunakan ffi web database factory
  static void initForWeb() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    }
  }

  // --------------------------------------------------------------------------
  // 🔌 2. GETTER DATABASE (LAZY INITIALIZATION):
  //    Jika database sudah terbuka, langsung kembalikan.
  //    Jika belum terbuka, panggil _initDatabase() untuk membuka koneksi.
  // --------------------------------------------------------------------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --------------------------------------------------------------------------
  // 🔌 3. METODE INISIALISASI DATABASE & PEMBUKAAN FILE SQLITE
  //    - Mengambil lokasi direktori penyimpanan lokal (getDatabasesPath)
  //    - Menggabungkan path dengan nama database 'timurlang.db'
  //    - Membuka database dengan openDatabase()
  // --------------------------------------------------------------------------
  Future<Database> _initDatabase() async {
    final String path;
    if (kIsWeb) {
      path = AppConstants.dbName;
    } else {
      // Mengambil direktori folder database bawaan OS (Android/iOS)
      final dbPath = await getDatabasesPath();
      // Menggabungkan folder dengan nama file: /data/user/0/.../databases/timurlang.db
      path = join(dbPath, AppConstants.dbName);
    }

    // Membuka database dengan parameter: path, version, dan callback onCreate/onUpgrade
    final db = await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Pastikan data awal gunung terisi (Seeding)
    try {
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM mountains'),
          ) ??
          0;
      if (count < 50) {
        await _seedMountains(db);
      }
    } catch (_) {}

    return db;
  }

  // --------------------------------------------------------------------------
  // 🔌 4. CALLBACK _onCreate: DIJALANKAN OTOMATIS SAAT DATABASE BARU DIBUAT
  //    Mengeksekusi DDL (CREATE TABLE) untuk 5 tabel SQLite aplikasi.
  // --------------------------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    // ------------------------------------------------------------------------
    // TABEL 1: users (Penyimpanan Akun Pengguna / Pendaki)
    // ------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nama_lengkap TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        foto_profil_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ------------------------------------------------------------------------
    // TABEL 2: mountains (Master Data 50 Gunung & Offline Caching API)
    // ------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE mountains (
        id TEXT PRIMARY KEY,
        nama_gunung TEXT NOT NULL,
        elevasi_mdpl INTEGER NOT NULL,
        tingkat_bahaya TEXT NOT NULL,
        sumber_air_tersedia INTEGER NOT NULL,
        status_jalur TEXT NOT NULL,
        koordinat_lat REAL NOT NULL,
        koordinat_long REAL NOT NULL,
        deskripsi TEXT,
        foto_url TEXT,
        kuota_harian INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // ------------------------------------------------------------------------
    // TABEL 3: simaksi_permits (Penyimpanan Tiket & Izin Pendakian)
    // ------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE simaksi_permits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        gunung_id TEXT NOT NULL,
        basecamp_id TEXT,
        tanggal_naik TEXT NOT NULL,
        tanggal_turun TEXT NOT NULL,
        jumlah_anggota INTEGER NOT NULL,
        status_izin TEXT NOT NULL,
        block_hash TEXT NOT NULL,
        previous_hash TEXT NOT NULL,
        nonce INTEGER NOT NULL,
        nama_gunung TEXT,
        nama_basecamp TEXT,
        total_biaya REAL,
        matauang TEXT,
        data_anggota TEXT,
        alasan_pembatalan TEXT,
        opsi_pembatalan TEXT,
        rekening_refund TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (gunung_id) REFERENCES mountains(id)
      )
    ''');

    // ------------------------------------------------------------------------
    // TABEL 4: user_personal_data (Data Identitas KTP & Domisili Pendaki)
    // ------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE user_personal_data (
        id TEXT PRIMARY KEY,
        user_id TEXT UNIQUE NOT NULL,
        kewarganegaraan TEXT NOT NULL,
        jenis_identitas TEXT NOT NULL,
        nomor_ktp TEXT NOT NULL,
        file_ktp_url TEXT,
        nama_lengkap TEXT NOT NULL,
        nama_belakang TEXT,
        tanggal_lahir TEXT NOT NULL,
        jenis_kelamin TEXT NOT NULL,
        no_telepon TEXT NOT NULL,
        no_telepon_darurat TEXT NOT NULL,
        surel TEXT NOT NULL,
        berat_badan REAL,
        tinggi_badan REAL,
        provinsi TEXT NOT NULL,
        kota_kabupaten TEXT NOT NULL,
        kecamatan TEXT NOT NULL,
        kelurahan TEXT NOT NULL,
        alamat TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // ------------------------------------------------------------------------
    // TABEL 5: medical_profiles (Data Rekam Medis & Kontak Darurat Pendaki)
    // ------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE medical_profiles (
        id TEXT PRIMARY KEY,
        user_id TEXT UNIQUE NOT NULL,
        golongan_darah TEXT NOT NULL,
        riwayat_penyakit TEXT NOT NULL,
        alergi TEXT NOT NULL,
        kontak_darurat_nama TEXT NOT NULL,
        kontak_darurat_telepon TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Seed master data gunung agar database langsung terisi 50 gunung
    await _seedMountains(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Pastikan seluruh tabel penting tersedia jika versi berubah
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_personal_data (
          id TEXT PRIMARY KEY,
          user_id TEXT UNIQUE NOT NULL,
          kewarganegaraan TEXT NOT NULL,
          jenis_identitas TEXT NOT NULL,
          nomor_ktp TEXT NOT NULL,
          file_ktp_url TEXT,
          nama_lengkap TEXT NOT NULL,
          nama_belakang TEXT,
          tanggal_lahir TEXT NOT NULL,
          jenis_kelamin TEXT NOT NULL,
          no_telepon TEXT NOT NULL,
          no_telepon_darurat TEXT NOT NULL,
          surel TEXT NOT NULL,
          berat_badan REAL,
          tinggi_badan REAL,
          provinsi TEXT NOT NULL,
          kota_kabupaten TEXT NOT NULL,
          kecamatan TEXT NOT NULL,
          kelurahan TEXT NOT NULL,
          alamat TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // 🔌 5. INITIAL SEEDING: Mengisi Data Master Awal ke Tabel 'mountains'
  //    Dijalankan saat database pertama kali di-create, memastikan 50 gunung
  //    tersimpan di SQLite lokal sehingga aplikasi langsung bisa dipakai offline.
  // --------------------------------------------------------------------------
  Future<void> _seedMountains(Database db) async {
    final batch = db.batch();
    for (final mountainData in SeedData.initialMountains) {
      batch.insert(
        'mountains',
        mountainData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    debugPrint(
      '✅ Seeded ${SeedData.initialMountains.length} mountains to local database',
    );
  }

  // ==========================================================================
  // 👤 [OPERASI CRUD 1] - TABEL USERS (Autentikasi & Akun Pendaki)
  // ==========================================================================

  /// [C - CREATE / INSERT]: Menyimpan akun pendaki baru ke tabel 'users'
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// [R - READ / QUERY]: Mengambil data akun berdasarkan ID (Primary Key)
  Future<User?> getUserById(String id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  /// [R - READ / QUERY]: Mengambil data akun berdasarkan Email (untuk proses Login)
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  /// [U - UPDATE]: Memperbarui profil akun pendaki
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// [D - DELETE]: Menghapus akun user dari tabel 'users'
  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================================
  // 🏔️ [OPERASI CRUD 2] - TABEL MOUNTAINS (Katalog & Offline Cache Data Gunung)
  // ==========================================================================

  /// [R - READ ALL]: Mengambil seluruh 50 data gunung dari SQLite lokal (A-Z)
  Future<List<Mountain>> getAllMountains() async {
    final db = await database;
    final results = await db.query('mountains', orderBy: 'nama_gunung ASC');
    return results.map((map) => Mountain.fromMap(map)).toList();
  }

  /// [R - READ SINGLE]: Mengambil detail 1 gunung berdasarkan ID
  Future<Mountain?> getMountainById(String id) async {
    final db = await database;
    final results = await db.query(
      'mountains',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Mountain.fromMap(results.first);
  }

  /// [C - CREATE / INSERT]: Menyimpan 1 data gunung ke SQLite
  Future<int> insertMountain(Mountain mountain) async {
    final db = await database;
    return await db.insert(
      'mountains',
      mountain.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// [C/U - UPSERT BATCH]: Sinkronisasi data dari REST API ke SQLite (Offline Caching)
  /// Menggunakan batch.insert dengan replace jika data sudah ada
  Future<void> upsertMountains(List<Mountain> list) async {
    final db = await database;
    final batch = db.batch();
    for (final m in list) {
      batch.insert(
        'mountains',
        m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// [R - SEARCH]: Mencari gunung menggunakan query LIKE pada SQLite
  Future<List<Mountain>> searchMountains(String query) async {
    final db = await database;
    final q = '%$query%';
    final results = await db.query(
      'mountains',
      where: 'nama_gunung LIKE ? OR deskripsi LIKE ?',
      whereArgs: [q, q],
      orderBy: 'nama_gunung ASC',
    );
    return results.map((m) => Mountain.fromMap(m)).toList();
  }

  // ==========================================================================
  // 🎫 [OPERASI CRUD 3] - TABEL SIMAKSI PERMITS (Tiket / Perizinan Pendakian)
  // ==========================================================================

  /// [C - CREATE / INSERT]: Menyimpan tiket izin pendakian baru ke SQLite
  Future<int> insertSimaksiPermit(SimaksiPermit permit) async {
    final db = await database;
    return await db.insert(
      'simaksi_permits',
      permit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// [R - READ WITH JOIN]: Mengambil riwayat izin SIMAKSI milik pengguna tertentu
  /// Menggunakan query JOIN ke tabel mountains untuk mendapatkan nama gunung terkini
  Future<List<SimaksiPermit>> getPermitsByUserId(String userId) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT p.*, m.nama_gunung as join_nama_gunung
      FROM simaksi_permits p
      LEFT JOIN mountains m ON p.gunung_id = m.id
      WHERE p.user_id = ?
      ORDER BY p.created_at DESC
    ''',
      [userId],
    );

    return results.map((map) {
      final mutable = Map<String, dynamic>.from(map);
      if (mutable['nama_gunung'] == null &&
          mutable['join_nama_gunung'] != null) {
        mutable['nama_gunung'] = mutable['join_nama_gunung'];
      }
      return SimaksiPermit.fromMap(mutable);
    }).toList();
  }

  /// [R - READ SINGLE]: Mengambil detail 1 izin SIMAKSI berdasarkan ID tiket
  Future<SimaksiPermit?> getPermitById(String id) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT p.*, m.nama_gunung as join_nama_gunung
      FROM simaksi_permits p
      LEFT JOIN mountains m ON p.gunung_id = m.id
      WHERE p.id = ?
      LIMIT 1
    ''',
      [id],
    );

    if (results.isEmpty) return null;
    final mutable = Map<String, dynamic>.from(results.first);
    if (mutable['nama_gunung'] == null && mutable['join_nama_gunung'] != null) {
      mutable['nama_gunung'] = mutable['join_nama_gunung'];
    }
    return SimaksiPermit.fromMap(mutable);
  }

  /// [R - READ BY HASH / QR]: Mengambil tiket SIMAKSI untuk scanning QR Code di pos pendakian
  Future<SimaksiPermit?> getPermitByHash(String hash) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT p.*, m.nama_gunung as join_nama_gunung
      FROM simaksi_permits p
      LEFT JOIN mountains m ON p.gunung_id = m.id
      WHERE p.block_hash = ? OR p.id = ?
      LIMIT 1
    ''',
      [hash, hash],
    );

    if (results.isEmpty) return null;
    final mutable = Map<String, dynamic>.from(results.first);
    if (mutable['nama_gunung'] == null && mutable['join_nama_gunung'] != null) {
      mutable['nama_gunung'] = mutable['join_nama_gunung'];
    }
    return SimaksiPermit.fromMap(mutable);
  }

  /// [U - UPDATE STATUS]: Memperbarui status izin tiket di SQLite (misal: 'Aktif', 'Selesai')
  Future<int> updatePermitStatus(String id, String status) async {
    final db = await database;
    return await db.update(
      'simaksi_permits',
      {'status_izin': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// [U - UPDATE CANCELLATION]: Memperbarui data pembatalan / pengajuan refund tiket di SQLite
  Future<int> updatePermitCancellation({
    required String id,
    required String opsi,
    required String alasan,
    String? rekening,
  }) async {
    final db = await database;
    return await db.update(
      'simaksi_permits',
      {
        'status_izin': 'Dibatalkan',
        'opsi_pembatalan': opsi,
        'alasan_pembatalan': alasan,
        'rekening_refund': rekening,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// [D - DELETE]: Menghapus tiket SIMAKSI dari database SQLite
  Future<int> deletePermit(String id) async {
    final db = await database;
    return await db.delete('simaksi_permits', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================================
  // 📋 [OPERASI CRUD 4] - TABEL USER PERSONAL DATA (Identitas KTP & Domisili)
  // ==========================================================================

  /// [R - READ]: Mengambil profil data diri pendaki berdasarkan user_id
  Future<UserPersonalData?> getPersonalDataByUserId(String userId) async {
    final db = await database;
    final results = await db.query(
      'user_personal_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserPersonalData.fromMap(results.first);
  }

  /// [C/U - CREATE / UPDATE]: Menyimpan data diri pendaki (Insert atau Replace)
  Future<int> savePersonalData(UserPersonalData data) async {
    final db = await database;
    return await db.insert(
      'user_personal_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// [D - DELETE]: Menghapus data pribadi pendaki
  Future<int> deletePersonalData(String userId) async {
    final db = await database;
    return await db.delete(
      'user_personal_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==========================================================================
  // 🩺 [OPERASI CRUD 5] - TABEL MEDICAL PROFILES (Rekam Medis & Kontak Darurat)
  // ==========================================================================

  /// [R - READ]: Mengambil data kesehatan pendaki berdasarkan user_id
  Future<MedicalProfile?> getMedicalProfileByUserId(String userId) async {
    final db = await database;
    final results = await db.query(
      'medical_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return MedicalProfile.fromMap(results.first);
  }

  /// [C/U - CREATE / UPDATE]: Menyimpan profil medis & kontak darurat (Insert / Replace)
  Future<int> saveMedicalProfile(MedicalProfile profile) async {
    final db = await database;
    return await db.insert(
      'medical_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Aliases & Helper Methods
  Future<List<SimaksiPermit>> getPermitsByUser(String userId) async {
    return getPermitsByUserId(userId);
  }

  Future<int> updatePermit(SimaksiPermit permit) async {
    return insertSimaksiPermit(permit);
  }

  Future<UserPersonalData?> getPersonalData(String userId) async {
    return getPersonalDataByUserId(userId);
  }

  Future<MedicalProfile?> getMedicalProfile(String userId) async {
    return getMedicalProfileByUserId(userId);
  }

  Future<int> insertMedicalProfile(MedicalProfile profile) async {
    return saveMedicalProfile(profile);
  }

  Future<int> updateMedicalProfile(MedicalProfile profile) async {
    return saveMedicalProfile(profile);
  }

  Future<String?> getLastPermitHash() async {
    final db = await database;
    final results = await db.query(
      'simaksi_permits',
      columns: ['block_hash'],
      where: 'block_hash IS NOT NULL',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first['block_hash'] as String?;
  }

  Future<Map<String, dynamic>?> getBasecampById(String id) async {
    return null;
  }

  Future<List<dynamic>> getRegisteredBasecampsByMountain(String mountainId) async {
    return [];
  }

  Future<List<SimaksiPermit>> getAllPermitsForBasecamp({String? gunungId, String? basecampId}) async {
    return [];
  }

  Future<({bool success, String message})> cancelPermitByUser({
    required String permitId,
    required String reason,
  }) async {
    final permit = await getPermitById(permitId) ?? await getPermitByHash(permitId);
    if (permit == null) {
      return (success: false, message: 'Tiket tidak ditemukan.');
    }
    if (!permit.isCancellableByUser) {
      return (
        success: false,
        message: 'Tiket tidak dapat dibatalkan (Status: ${permit.statusIzin}).',
      );
    }
    final updated = permit.copyWith(
      statusIzin: AppConstants.statusDibatalkanPendaki,
      alasanPembatalan: 'Inisiatif Pendaki: $reason',
      opsiPembatalan: 'cancelled_no_refund',
    );
    await updatePermit(updated);
    return (
      success: true,
      message: 'Tiket berhasil dibatalkan.',
    );
  }

  Future<({bool success, String message})> requestRefund({
    required String permitId,
    String? bankOrWallet,
    String? bankName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    final permit = await getPermitById(permitId) ?? await getPermitByHash(permitId);
    if (permit == null) {
      return (success: false, message: 'Tiket tidak ditemukan.');
    }
    final provider = bankOrWallet ?? bankName ?? 'Bank';
    final rekeningInfo = '$provider - $accountNumber a/n $accountHolder';
    final updated = permit.copyWith(
      statusIzin: AppConstants.statusRefundDiajukan,
      rekeningRefund: rekeningInfo,
    );
    await updatePermit(updated);
    return (
      success: true,
      message: 'Pengajuan refund berhasil dikirim.',
    );
  }

  Future<({bool success, String message})> reschedulePermit({
    required String permitId,
    required DateTime newTanggalNaik,
    required DateTime newTanggalTurun,
  }) async {
    final permit = await getPermitById(permitId) ?? await getPermitByHash(permitId);
    if (permit == null) {
      return (success: false, message: 'Tiket tidak ditemukan.');
    }
    final updated = permit.copyWith(
      tanggalNaik: newTanggalNaik,
      tanggalTurun: newTanggalTurun,
      statusIzin: AppConstants.statusRescheduled,
    );
    await updatePermit(updated);
    return (
      success: true,
      message: 'Jadwal pendakian berhasil diubah.',
    );
  }
}
