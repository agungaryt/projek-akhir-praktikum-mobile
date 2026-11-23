// ============================================================================
// 👤 [GETX CONTROLLER - PROFILE, PERSONAL DATA & MEDICAL]
// ----------------------------------------------------------------------------
// File: profile_controller.dart
// Sesuai Modul VI (SQLite) & Modul VIII (GetX State Management)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_personal_data.dart';
import '../models/medical_profile.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find<ProfileController>();

  final _db = DatabaseService.instance;

  final Rx<UserPersonalData?> personalData = Rx<UserPersonalData?>(null);
  final Rx<MedicalProfile?> medicalProfile = Rx<MedicalProfile?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      loadProfileData(auth.currentUser.value!.id);
    }
  }

  Future<void> loadProfileData(String userId) async {
    isLoading.value = true;
    try {
      final pData = await _db.getPersonalDataByUserId(userId);
      final mData = await _db.getMedicalProfileByUserId(userId);
      personalData.value = pData;
      medicalProfile.value = mData;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> savePersonalData(UserPersonalData data) async {
    isLoading.value = true;
    try {
      await _db.savePersonalData(data);
      personalData.value = data;
      Get.snackbar(
        'Berhasil Disimpan',
        'Data pribadi Anda berhasil diperbarui di database lokal.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Gagal Menyimpan',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveMedicalProfile(MedicalProfile profile) async {
    isLoading.value = true;
    try {
      await _db.saveMedicalProfile(profile);
      medicalProfile.value = profile;
      Get.snackbar(
        'Berhasil Disimpan',
        'Data profil medis berhasil diperbarui di database lokal.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Gagal Menyimpan',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
