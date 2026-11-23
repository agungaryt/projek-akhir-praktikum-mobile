/**
 * ============================================================================
 * 🏔️ TimurLang - Mountain REST API Server (Node.js)
 * ============================================================================
 * Server API RESTful ringan untuk data gunung Indonesia tanpa dependensi eksternal (zero-npm).
 * Menjalankan server HTTP native dengan fitur:
 * - CORS support penuh untuk Flutter Web, Android, iOS, & Desktop
 * - GET /api/mountains (dengan filter ?search=, ?status=, ?sort=)
 * - GET /api/mountains/:id (detail gunung berdasarkan ID)
 * - GET /api/health (cek status server)
 * 
 * Cara Menjalankan:
 *   node server.js
 * Default Port: 3000 (dapat diubah via variabel PORT)
 * ============================================================================
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'mountains.json');

// Membaca database gunung dari mountains.json
let mountains = [];
try {
  const rawData = fs.readFileSync(DATA_FILE, 'utf-8');
  mountains = JSON.parse(rawData);
  console.log(`✅ Berhasil memuat ${mountains.length} data gunung dari mountains.json`);
} catch (err) {
  console.error('❌ Gagal membaca mountains.json:', err.message);
  process.exit(1);
}

// Helper untuk mengirim respon JSON
function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(data, null, 2));
}

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  // Handle CORS preflight
  if (method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    return res.end();
  }

  // Route: Cek Health / Root
  if (pathname === '/' || pathname === '/api/health') {
    return sendJson(res, 200, {
      status: 'success',
      message: 'TimurLang Mountain API is running',
      total_mountains: mountains.length,
      timestamp: new Date().toISOString(),
      endpoints: [
        'GET /api/mountains',
        'GET /api/mountains?search={keyword}',
        'GET /api/mountains/:id',
      ]
    });
  }

  // Route: GET /api/mountains/:id
  const detailMatch = pathname.match(/^\/api\/mountains\/([^\/]+)$/);
  if (method === 'GET' && detailMatch) {
    const id = detailMatch[1];
    const mountain = mountains.find(m => m.id.toLowerCase() === id.toLowerCase());
    if (mountain) {
      return sendJson(res, 200, {
        status: 'success',
        data: mountain,
      });
    } else {
      return sendJson(res, 404, {
        status: 'error',
        message: `Gunung dengan ID '${id}' tidak ditemukan`,
      });
    }
  }

  // Route: GET /api/mountains (dengan query search & filter)
  if (method === 'GET' && pathname === '/api/mountains') {
    let result = [...mountains];
    const { search, status, sort } = parsedUrl.query;

    if (search) {
      const q = search.toLowerCase().trim();
      result = result.filter(m =>
        m.nama_gunung.toLowerCase().includes(q) ||
        (m.deskripsi && m.deskripsi.toLowerCase().includes(q))
      );
    }

    if (status) {
      const st = status.toLowerCase();
      result = result.filter(m => m.status_jalur.toLowerCase() === st);
    }

    if (sort === 'elevasi_desc') {
      result.sort((a, b) => b.elevasi_mdpl - a.elevasi_mdpl);
    } else if (sort === 'elevasi_asc') {
      result.sort((a, b) => a.elevasi_mdpl - b.elevasi_mdpl);
    } else if (sort === 'nama_asc') {
      result.sort((a, b) => a.nama_gunung.localeCompare(b.nama_gunung));
    }

    return sendJson(res, 200, {
      status: 'success',
      total: result.length,
      data: result,
    });
  }

  // 404 Not Found
  return sendJson(res, 404, {
    status: 'error',
    message: `Endpoint '${pathname}' tidak ditemukan`,
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`🚀 TimurLang Mountain REST API Server aktif!`);
  console.log(`📡 URL Lokal    : http://localhost:${PORT}/api/mountains`);
  console.log(`📱 URL Emulator : http://10.0.2.2:${PORT}/api/mountains`);
  console.log(`====================================================`);
});
