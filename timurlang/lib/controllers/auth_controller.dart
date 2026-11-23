// ============================================================================
// 🎮 [GETX CONTROLLER - AUTHENTICATION & SESSION]
// ----------------------------------------------------------------------------
// File: auth_controller.dart
// Sesuai Modul VIII: GetX State Management, Reactive Rx, Obx, & Navigation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/routes.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final _authService = AuthService.instance;

  // State Reaktif
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = true.obs;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    restoreSession();
  }

  /// Memulihkan sesi pengguna dari local storage
  Future<void> restoreSession() async {
    isLoading.value = true;
    try {
      final user = await _authService.restoreSession();
      currentUser.value = user;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Login menggunakan GetX
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Harap isi email dan kata sandi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final result = await _authService.login(
        email: email.trim(),
        password: password,
        rememberMe: rememberMe.value,
      );

      if (result.success) {
        currentUser.value = _authService.currentUser;
        Get.snackbar(
          'Berhasil Masuk',
          'Selamat datang kembali, ${currentUser.value?.namaLengkap}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade800,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        Get.snackbar(
          'Gagal Masuk',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Register pengguna baru menggunakan GetX
  Future<bool> register({
    required String namaLengkap,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (namaLengkap.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Semua bidang wajib diisi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Peringatan',
        'Konfirmasi kata sandi tidak cocok.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final result = await _authService.register(
        namaLengkap: namaLengkap.trim(),
        email: email.trim(),
        password: password,
      );

      if (result.success) {
        currentUser.value = _authService.currentUser;
        Get.snackbar(
          'Pendaftaran Berhasil',
          'Akun berhasil dibuat. Selamat datang di TimurLang!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade800,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.home);
        return true;
      } else {
        Get.snackbar(
          'Gagal Mendaftar',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
        );
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout menggunakan GetX
  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
    Get.snackbar(
      'Keluar',
      'Anda telah keluar dari akun.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueGrey.shade800,
      colorText: Colors.white,
    );
  }
}
