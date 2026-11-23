// ============================================================================
// 🔐 [AUTH SERVICE - OTENTIKASI PENGGUNA & SESSION PERSISTENCE]
// ----------------------------------------------------------------------------
// File: auth_service.dart
// Sesuai Modul VI: Local Storage (SharedPreferences & SQLite)
// Mengelola registrasi, login, hashing SHA-256, dan session pengguna
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/constants.dart';
import '../models/user.dart';
import '../utils/crypto_utils.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  final _db = DatabaseService.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Inisialisasi dan restore session pengguna dari SharedPreferences (Modul VI)
  Future<User?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.userIdKey);
      if (userId != null && userId.isNotEmpty) {
        final user = await _db.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          debugPrint('🔑 Sesi akun dipulihkan: ${user.namaLengkap} (${user.email})');
          return user;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Gagal restore session: $e');
    }
    return null;
  }

  /// Register pengguna baru
  Future<({bool success, String message})> register({
    required String namaLengkap,
    required String email,
    required String password,
  }) async {
    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        return (success: false, message: 'Email sudah terdaftar.');
      }

      final salt = CryptoUtils.generateSalt(email);
      final passwordHash = CryptoUtils.hashPassword(password, salt);
      final now = DateTime.now();

      final user = User(
        id: const Uuid().v4(),
        namaLengkap: namaLengkap,
        email: email.trim(),
        passwordHash: '$salt:$passwordHash',
        createdAt: now,
        updatedAt: now,
      );

      await _db.insertUser(user);
      _currentUser = user;

      // Simpan session ke SharedPreferences (Modul VI)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userIdKey, user.id);
      await prefs.setBool(AppConstants.rememberMeKey, true);

      return (success: true, message: 'Registrasi berhasil!');
    } catch (e) {
      return (success: false, message: 'Gagal mendaftar: ${e.toString()}');
    }
  }

  /// Login pengguna
  Future<({bool success, String message})> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        return (success: false, message: 'Email atau password salah.');
      }

      // Verifikasi Password Hash
      final parts = user.passwordHash.split(':');
      if (parts.length != 2) {
        return (success: false, message: 'Format kredensial tidak valid.');
      }

      final salt = parts[0];
      final expectedHash = parts[1];
      final inputHash = CryptoUtils.hashPassword(password, salt);

      if (inputHash != expectedHash) {
        return (success: false, message: 'Email atau password salah.');
      }

      _currentUser = user;

      // Simpan session ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString(AppConstants.userIdKey, user.id);
        await prefs.setBool(AppConstants.rememberMeKey, true);
      } else {
        await prefs.remove(AppConstants.userIdKey);
      }

      return (success: true, message: 'Login berhasil!');
    } catch (e) {
      return (success: false, message: 'Gagal login: ${e.toString()}');
    }
  }

  /// Logout pengguna dan bersihkan session
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.rememberMeKey);
  }

  /// Perbarui data profil pengguna
  Future<({bool success, String message})> updateProfile({
    required String namaLengkap,
    String? fotoProfilUrl,
  }) async {
    if (_currentUser == null) {
      return (success: false, message: 'User tidak ditemukan');
    }
    final updated = _currentUser!.copyWith(
      namaLengkap: namaLengkap,
      fotoProfilUrl: fotoProfilUrl ?? _currentUser!.fotoProfilUrl,
      updatedAt: DateTime.now(),
    );
    await _db.updateUser(updated);
    _currentUser = updated;
    return (success: true, message: 'Profil berhasil diperbarui');
  }
}
