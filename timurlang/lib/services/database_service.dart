// ============================================================================
// 💾 [KODINGAN DATABASE LOKAL - SQLITE (OFFLINE-FIRST)]
// ----------------------------------------------------------------------------
// File: database_service.dart
// Penjelasan:
// - Menggunakan package 'sqflite' & 'sqflite_common_ffi_web' (Modul VI Local Storage)
// - Berfungsi sebagai penyimpanan basis data lokal (SQLite) pada perangkat
// - Menyimpan tabel: users, mountains, simaksi_permits, user_personal_data,
//   medical_profiles
// - Mendukung operasi CRUD lokal penuh
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
  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  static void initForWeb() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path;
    if (kIsWeb) {
      path = AppConstants.dbName;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, AppConstants.dbName);
    }

    final db = await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Pastikan data awal gunung terisi
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

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel users
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

    // 2. Tabel mountains
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

    // 3. Tabel simaksi_permits
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

    // 4. Tabel user_personal_data
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

    // 5. Tabel medical_profiles
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

    // Seed master data gunung
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
  // 👤 CRUD USER
  // ==========================================================================
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================================
  // 🏔️ CRUD MOUNTAINS (Data Gunung)
  // ==========================================================================
  Future<List<Mountain>> getAllMountains() async {
    final db = await database;
    final results = await db.query('mountains', orderBy: 'nama_gunung ASC');
    return results.map((map) => Mountain.fromMap(map)).toList();
  }

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

  Future<int> insertMountain(Mountain mountain) async {
    final db = await database;
    return await db.insert(
      'mountains',
      mountain.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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
  // 🎫 CRUD SIMAKSI PERMITS
  // ==========================================================================
  Future<int> insertSimaksiPermit(SimaksiPermit permit) async {
    final db = await database;
    return await db.insert(
      'simaksi_permits',
      permit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<int> updatePermitStatus(String id, String status) async {
    final db = await database;
    return await db.update(
      'simaksi_permits',
      {'status_izin': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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

  Future<int> deletePermit(String id) async {
    final db = await database;
    return await db.delete('simaksi_permits', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================================
  // 📋 CRUD USER PERSONAL DATA
  // ==========================================================================
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

  Future<int> savePersonalData(UserPersonalData data) async {
    final db = await database;
    return await db.insert(
      'user_personal_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deletePersonalData(String userId) async {
    final db = await database;
    return await db.delete(
      'user_personal_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==========================================================================
  // 🩺 CRUD MEDICAL PROFILES
  // ==========================================================================
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
