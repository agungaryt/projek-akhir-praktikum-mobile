// ============================================================================
// 🏔️ [GETX CONTROLLER - MOUNTAINS (API & LOCAL CACHE)]
// ----------------------------------------------------------------------------
// File: mountain_controller.dart
// Sesuai Modul V (HTTP Request) & Modul VIII (GetX State Management)
// ============================================================================

import 'package:get/get.dart';
import '../models/mountain.dart';
import '../services/mountain_api_service.dart';

class MountainController extends GetxController {
  static MountainController get to => Get.find<MountainController>();

  final _apiService = MountainApiService.instance;

  // State Reaktif
  final RxList<Mountain> allMountains = <Mountain>[].obs;
  final RxList<Mountain> filteredMountains = <Mountain>[].obs;
  final Rx<Mountain?> selectedMountain = Rx<Mountain?>(null);
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedGrade = ''.obs;
  final RxString selectedStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMountains();
  }

  /// Mengambil data gunung dari REST API (Modul V)
  /// Dilengkapi fallback otomatis ke SQLite lokal (Modul VI)
  Future<void> fetchMountains() async {
    isLoading.value = true;
    try {
      final list = await _apiService.fetchMountains(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value.isNotEmpty ? selectedStatus.value : null,
      );
      allMountains.assignAll(list);
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  /// Set query pencarian
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Set filter tingkat kesulitan
  void setGradeFilter(String grade) {
    if (selectedGrade.value == grade) {
      selectedGrade.value = '';
    } else {
      selectedGrade.value = grade;
    }
    _applyFilters();
  }

  /// Set filter status jalur
  void setStatusFilter(String status) {
    if (selectedStatus.value == status) {
      selectedStatus.value = '';
    } else {
      selectedStatus.value = status;
    }
    _applyFilters();
  }

  /// Menerapkan filter pencarian, status, dan tingkat kesulitan
  void _applyFilters() {
    var result = List<Mountain>.from(allMountains);

    // Filter Search
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      result = result.where((m) =>
        m.namaGunung.toLowerCase().contains(q) ||
        (m.deskripsi != null && m.deskripsi!.toLowerCase().contains(q))
      ).toList();
    }

    // Filter Grade
    if (selectedGrade.value.isNotEmpty) {
      result = result.where((m) =>
        m.tingkatBahaya.toLowerCase().contains(selectedGrade.value.toLowerCase())
      ).toList();
    }

    // Filter Status Jalur
    if (selectedStatus.value.isNotEmpty) {
      result = result.where((m) =>
        m.statusJalur.toLowerCase() == selectedStatus.value.toLowerCase()
      ).toList();
    }

    filteredMountains.assignAll(result);
  }

  /// Menerapkan filter dengan kriteria lengkap (Search, Grade, Sumber Air, Elevasi)
  void filterMountainsWithCriteria({
    String? search,
    String? grade,
    bool? sumberAir,
    int? minElevasi,
    int? maxElevasi,
  }) {
    if (search != null) searchQuery.value = search;
    selectedGrade.value = grade ?? '';

    var result = List<Mountain>.from(allMountains);

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      result = result.where((m) =>
        m.namaGunung.toLowerCase().contains(q) ||
        (m.deskripsi != null && m.deskripsi!.toLowerCase().contains(q))
      ).toList();
    }

    if (selectedGrade.value.isNotEmpty) {
      result = result.where((m) =>
        m.tingkatBahaya.toLowerCase().contains(selectedGrade.value.toLowerCase())
      ).toList();
    }

    if (sumberAir != null) {
      result = result.where((m) => m.sumberAirTersedia == sumberAir).toList();
    }

    if (minElevasi != null) {
      result = result.where((m) => m.elevasiMdpl >= minElevasi).toList();
    }

    if (maxElevasi != null) {
      result = result.where((m) => m.elevasiMdpl <= maxElevasi).toList();
    }

    filteredMountains.assignAll(result);
  }

  /// Reset semua filter
  void resetFilters() {
    searchQuery.value = '';
    selectedGrade.value = '';
    selectedStatus.value = '';
    _applyFilters();
  }

  /// Pilih gunung untuk detail
  void selectMountain(Mountain mountain) {
    selectedMountain.value = mountain;
  }
}
