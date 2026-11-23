# 🏔️ TimurLang Mountain REST API

API RESTful mandiri untuk data gunung Indonesia dalam proyek **TimurLang (Sistem Informasi Perizinan & Keselamatan Pendakian Terpadu)**.

API ini dibuat untuk memenuhi ketentuan tugas praktikum pemrograman mobile mengenai **HTTP Request & REST API** (Modul V) serta integrasi dengan **GetX** (Modul VIII).

---

## 🚀 Cara Menjalankan Server API

Pilih salah satu (menggunakan Node.js atau Python):

### Opsi A: Menggunakan Node.js (Rekomendasi, tanpa install npm)
```bash
cd mountain_api
node server.js
```

### Opsi B: Menggunakan Python (Tanpa pip install)
```bash
cd mountain_api
python server.py
```

Server akan aktif di port **3000**:
- **Akses dari Web / Desktop / Browser**: `http://localhost:3000/api/mountains`
- **Akses dari Android Emulator**: `http://10.0.2.2:3000/api/mountains`

---

## 📡 Daftar Endpoint REST API

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/health` | Cek status kesehatan server API |
| `GET` | `/api/mountains` | Mengambil seluruh 50 data gunung Indonesia |
| `GET` | `/api/mountains?search={keyword}` | Pencarian gunung berdasarkan nama atau deskripsi |
| `GET` | `/api/mountains?status={Buka/Waspada/Tutup}` | Filter gunung berdasarkan status jalur |
| `GET` | `/api/mountains/:id` | Mengambil detail spesifik satu gunung berdasarkan ID (misal: `mtn-001`) |

---

## 📦 Struktur Data JSON Gunung

```json
{
  "id": "mtn-001",
  "nama_gunung": "Gunung Leuser",
  "elevasi_mdpl": 3119,
  "tingkat_bahaya": "Grade 4 - Sangat Sulit",
  "sumber_air_tersedia": 1,
  "status_jalur": "Buka",
  "koordinat_lat": 3.7431,
  "koordinat_long": 97.1558,
  "deskripsi": "Gunung tertinggi di Aceh dalam kawasan Taman Nasional Gunung Leuser...",
  "foto_url": "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800",
  "kuota_harian": 100,
  "created_at": "2026-01-01T00:00:00.000Z"
}
```

---

## 📱 Integrasi di Aplikasi Flutter

Di Flutter, modul HTTP Request menggunakan service:
- `lib/services/mountain_api_service.dart` (menggunakan package `http` & `jsonDecode`)
- `lib/controllers/mountain_controller.dart` (state management GetX reaktif `RxList<Mountain>`, `isLoading.obs`, `searchQuery.obs`)
- Dilengkapi fallback otomatis ke lokal (SQLite / cached data) jika server API sedang tidak dijalankan, sehingga aplikasi tetap berjalan lancar (offline-first).
