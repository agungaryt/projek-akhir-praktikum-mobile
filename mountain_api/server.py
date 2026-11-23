#!/usr/bin/env python3
"""
============================================================================
🏔️ TimurLang - Mountain REST API Server (Python)
============================================================================
Server API RESTful alternatif berbasis Python standard library (tanpa pip install).
Menjalankan server HTTP dengan fitur:
- CORS support penuh untuk Flutter Web, Android, iOS, & Desktop
- GET /api/mountains (dengan filter ?search=, ?status=)
- GET /api/mountains/:id
- GET /api/health

Cara Menjalankan:
  python server.py
============================================================================
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import re
import urllib.parse

PORT = 3000
DATA_FILE = os.path.join(os.path.dirname(__file__), "mountains.json")

# ============================================================================
# 🔑 [API KEY SERVER DEFINITION]
# Token rahasia yang harus dikirimkan oleh Flutter app melalui header 'x-api-key'
# Sesuai teori Modul V Halaman 9 (Autentikasi API Key via HTTP Header)
# ============================================================================
EXPECTED_API_KEY = "timurlang_api_key_sec_2026"

try:
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        mountains = json.load(f)
    print(f"✅ Berhasil memuat {len(mountains)} data gunung dari mountains.json")
    print(f"🔑 API Key server aktif: '{EXPECTED_API_KEY}'")
except Exception as e:
    print(f"❌ Gagal membaca mountains.json: {e}")
    mountains = []

class MountainApiHandler(BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, x-api-key")

    def _send_json(self, status_code, data):
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self._send_cors_headers()
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2, ensure_ascii=False).encode("utf-8"))

    def do_OPTIONS(self):
        self.send_response(204)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = urllib.parse.parse_qs(parsed.query)

        # ====================================================================
        # 🔑 [LOGIKA SERVER MEMBACA & MEMVALIDASI API KEY DARI CLIENT]
        # --------------------------------------------------------------------
        # 1. Server mengambil nilai dari header 'x-api-key' pada request
        # 2. Server memeriksa apakah API Key sesuai dengan EXPECTED_API_KEY
        # 3. Server mencatat log keberhasilan autentikasi
        # ====================================================================
        client_api_key = self.headers.get("x-api-key")
        if client_api_key:
            if client_api_key == EXPECTED_API_KEY:
                print(f"🔑 [AUTH OK] Client terautentikasi dengan API Key yang valid.")
            else:
                print(f"⚠️ [AUTH WARN] Client mengirim API Key tidak cocok: '{client_api_key}'")

        if path in ["/", "/api/health"]:
            return self._send_json(200, {
                "status": "success",
                "message": "TimurLang Mountain API is running (Python)",
                "total_mountains": len(mountains),
                "api_key_status": "Valid" if client_api_key == EXPECTED_API_KEY else "Optional/Public",
                "endpoints": [
                    "GET /api/mountains",
                    "GET /api/mountains?search={keyword}",
                    "GET /api/mountains/{id}"
                ]
            })

        # Match /api/mountains/:id
        detail_match = re.match(r"^/api/mountains/([^/]+)$", path)
        if detail_match:
            mid = detail_match.group(1).lower()
            found = next((m for m in mountains if m.get("id", "").lower() == mid), None)
            if found:
                return self._send_json(200, {"status": "success", "data": found})
            else:
                return self._send_json(404, {"status": "error", "message": f"Gunung '{mid}' tidak ditemukan"})

        if path == "/api/mountains":
            res = list(mountains)
            if "search" in query:
                q = query["search"][0].lower().strip()
                res = [m for m in res if q in m.get("nama_gunung", "").lower() or q in m.get("deskripsi", "").lower()]
            if "status" in query:
                st = query["status"][0].lower()
                res = [m for m in res if m.get("status_jalur", "").lower() == st]
            return self._send_json(200, {
                "status": "success",
                "total": len(res),
                "data": res
            })

        return self._send_json(404, {"status": "error", "message": f"Endpoint '{path}' tidak ditemukan"})

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), MountainApiHandler)
    print("=" * 52)
    print(f"🚀 TimurLang Mountain REST API Server (Python) aktif!")
    print(f"📡 URL Lokal    : http://localhost:{PORT}/api/mountains")
    print(f"📱 URL Emulator : http://10.0.2.2:{PORT}/api/mountains")
    print("=" * 52)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer dihentikan.")
