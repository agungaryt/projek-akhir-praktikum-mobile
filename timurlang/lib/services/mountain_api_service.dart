// ============================================================================
// 🌐 [HTTP REQUEST & REST API SERVICE - DATA GUNUNG]
// ----------------------------------------------------------------------------
// File: mountain_api_service.dart
// Sesuai Modul V: HTTP Request (Package http, JSON parsing, async/await)
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:http/http.dart' as http;
import '../models/mountain.dart';
import 'database_service.dart';

class MountainApiService {
  static final MountainApiService instance = MountainApiService._internal();
  MountainApiService._internal();

  /// Mendapatkan Base URL API secara cerdas berdasarkan platform
  /// - Web / Windows / Desktop : http://localhost:3000/api
  /// - Android Emulator         : http://10.0.2.2:3000/api
  /// - Real Device / Default    : http://localhost:3000/api (bisa dikustomisasi)
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  String _baseUrl = defaultBaseUrl;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Mengambil daftar semua gunung dari REST API
  /// Menggunakan http.get() dan jsonDecode()
  /// Jika API tidak aktif, otomatis fallback ke SQLite lokal (offline-first)
  Future<List<Mountain>> fetchMountains({String? search, String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse('$_baseUrl/mountains').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      debugPrint('📡 Fetching Mountains from API: $uri');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? [];
        final mountains = dataList.map((item) => Mountain.fromMap(item as Map<String, dynamic>)).toList();
        
        debugPrint('✅ Berhasil mengambil ${mountains.length} gunung dari API');
        
        // Simpan ke SQLite lokal sebagai cache offline
        try {
          await DatabaseService.instance.upsertMountains(mountains);
        } catch (_) {}

        return mountains;
      } else {
        debugPrint('⚠️ API Response Error ${response.statusCode}: ${response.body}');
        return await _fallbackLocal(search: search);
      }
    } catch (e) {
      debugPrint('⚠️ API Connection failed ($e). Falling back to local database...');
      return await _fallbackLocal(search: search);
    }
  }

  /// Mengambil detail satu gunung dari REST API
  Future<Mountain?> fetchMountainById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/mountains/$id');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        if (data != null) {
          return Mountain.fromMap(data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Fetch Mountain by ID failed: $e');
    }

    // Fallback ke lokal
    return await DatabaseService.instance.getMountainById(id);
  }

  /// Fallback mengambil data dari SQLite lokal jika server API sedang tidak aktif
  Future<List<Mountain>> _fallbackLocal({String? search}) async {
    if (search != null && search.isNotEmpty) {
      return await DatabaseService.instance.searchMountains(search);
    }
    return await DatabaseService.instance.getAllMountains();
  }
}
