// ============================================================================
// 🎫 [GETX CONTROLLER - SIMAKSI PERMIT & BOOKING]
// ----------------------------------------------------------------------------
// File: simaksi_controller.dart
// Sesuai Modul VI (SQLite Local Storage) & Modul VIII (GetX State Management)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/simaksi_permit.dart';
import '../models/mountain.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../controllers/auth_controller.dart';

class SimaksiController extends GetxController {
  static SimaksiController get to => Get.find<SimaksiController>();

  final _db = DatabaseService.instance;

  final RxList<SimaksiPermit> permits = <SimaksiPermit>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<SimaksiPermit?> selectedPermit = Rx<SimaksiPermit?>(null);

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      loadUserPermits(auth.currentUser.value!.id);
    }
  }

  /// Memuat daftar tiket SIMAKSI milik user dari SQLite lokal (Modul VI)
  Future<void> loadUserPermits(String userId) async {
    isLoading.value = true;
    try {
      final list = await _db.getPermitsByUserId(userId);
      permits.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  /// Membuat izin SIMAKSI baru dan menyimpan ke SQLite lokal (Modul VI)
  Future<SimaksiPermit?> createPermit({
    required Mountain mountain,
    required DateTime tanggalNaik,
    required DateTime tanggalTurun,
    required int jumlahAnggota,
    required double totalBiaya,
    required String dataAnggotaJson,
    String? basecampName,
  }) async {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    if (user == null) {
      Get.snackbar(
        'Peringatan',
        'Harap masuk ke akun terlebih dahulu.',
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return null;
    }

    isLoading.value = true;
    try {
      final permitId = 'SIMAKSI-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final now = DateTime.now();

      final permit = SimaksiPermit(
        id: permitId,
        userId: user.id,
        gunungId: mountain.id,
        namaGunung: mountain.namaGunung,
        namaBasecamp: basecampName ?? 'Jalur Resmi ${mountain.namaGunung}',
        tanggalNaik: tanggalNaik,
        tanggalTurun: tanggalTurun,
        jumlahAnggota: jumlahAnggota,
        statusIzin: 'Disetujui',
        blockHash: permitId,
        previousHash: '',
        nonce: 0,
        totalBiaya: totalBiaya,
        matauang: 'IDR',
        dataAnggota: dataAnggotaJson,
        createdAt: now,
      );

      // Simpan ke SQLite lokal (Modul VI)
      await _db.insertSimaksiPermit(permit);
      permits.insert(0, permit);
      selectedPermit.value = permit;

      // Tampilkan Notifikasi (Modul VII)
      await NotificationService.instance.showSimaksiNotification(
        namaGunung: mountain.namaGunung,
        permitId: permit.id,
      );

      Get.snackbar(
        'Tiket Terbit! 🎫',
        'Izin SIMAKSI untuk ${mountain.namaGunung} berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );

      return permit;
    } catch (e) {
      Get.snackbar(
        'Gagal Membuat Izin',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Batalkan tiket SIMAKSI
  Future<void> cancelPermit({
    required String permitId,
    required String opsi,
    required String alasan,
    String? rekening,
  }) async {
    isLoading.value = true;
    try {
      await _db.updatePermitCancellation(
        id: permitId,
        opsi: opsi,
        alasan: alasan,
        rekening: rekening,
      );

      // Perbarui state reaktif
      final idx = permits.indexWhere((p) => p.id == permitId);
      if (idx != -1) {
        final current = permits[idx];
        permits[idx] = SimaksiPermit(
          id: current.id,
          userId: current.userId,
          gunungId: current.gunungId,
          namaGunung: current.namaGunung,
          namaBasecamp: current.namaBasecamp,
          tanggalNaik: current.tanggalNaik,
          tanggalTurun: current.tanggalTurun,
          jumlahAnggota: current.jumlahAnggota,
          statusIzin: 'Dibatalkan',
          blockHash: current.blockHash,
          previousHash: current.previousHash,
          nonce: current.nonce,
          totalBiaya: current.totalBiaya,
          matauang: current.matauang,
          dataAnggota: current.dataAnggota,
          createdAt: current.createdAt,
          alasanPembatalan: alasan,
          opsiPembatalan: opsi,
          rekeningRefund: rekening,
        );
      }

      Get.snackbar(
        'Tiket Dibatalkan',
        'Izin pendakian telah berhasil dibatalkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.shade800,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
