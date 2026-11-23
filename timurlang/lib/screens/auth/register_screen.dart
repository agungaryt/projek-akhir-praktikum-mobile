// ============================================
// TimurLang - Register Screen
// Modul VIII: GetX State Management (Obx, Controller)
// Preserving Original Aura Travel Design System & Plus Jakarta Sans Font
// ============================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final AuthController auth = Get.find<AuthController>();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    auth.register(
      namaLengkap: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================================
      // 🎨 [1. GANTI WARNA BACKGROUND HALAMAN REGISTER DI SINI]
      // 👉 Ganti `AppTheme.background` (Contoh: Colors.white, Colors.blue.shade50)
      // ============================================================================
      backgroundColor: AppTheme.background, // 👈 UBAH WARNA BACKGROUND REGISTER
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================================
              // 🎨 [2. GANTI WARNA TOMBOL KEMBALI / BACK BUTTON]
              // 👉 Ganti `color: AppTheme.surface` (warna kotak)
              // 👉 Ganti `color: AppTheme.textPrimary` (warna ikon panah)
              // ====================================================================
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.surface, // 👈 UBAH WARNA KOTAK TOMBOL BACK
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border), // 👈 UBAH BORDER TOMBOL BACK
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary, // 👈 UBAH WARNA IKON PANAH BACK
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              Text(
                'Daftar Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary, // 👈 UBAH WARNA JUDUL "Daftar Akun"
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Buat akun baru untuk mulai menjelajah & mendaki',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textSecondary, // 👈 UBAH WARNA SUBJUDUL
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // ====================================================================
              // 🎨 [3. GANTI WARNA KARTU FORM CONTAINER REGISTER]
              // 👉 Ganti `color: AppTheme.surface` (Contoh: Colors.white)
              // ====================================================================
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surface, // 👈 UBAH WARNA KARTU FORM REGISTER
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border, width: 1.2), // 👈 UBAH BORDER KARTU
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lengkap Field
                      CustomTextField(
                        controller: _namaCtrl,
                        label: 'Nama Lengkap',
                        hint: 'Sesuai Kartu Identitas / KTP',
                        prefixIcon: Icons.person_outline,
                        validator: (val) => Validators.required(val, 'Nama lengkap'),
                      ),

                      // Email Field
                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Alamat Email',
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.email,
                      ),

                      // Password Field
                      CustomTextField(
                        controller: _passwordCtrl,
                        label: 'Kata Sandi',
                        hint: 'Minimal 6 karakter',
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: Validators.password,
                      ),

                      // Konfirmasi Password Field
                      CustomTextField(
                        controller: _confirmCtrl,
                        label: 'Konfirmasi Kata Sandi',
                        hint: 'Ketik ulang kata sandi',
                        isPassword: true,
                        prefixIcon: Icons.lock_clock_outlined,
                        validator: (val) => Validators.confirmPassword(val, _passwordCtrl.text),
                      ),
                      const SizedBox(height: 12),

                      // Tombol Daftar
                      // ==============================================================
                      // 🎨 [4. GANTI WARNA TOMBOL "DAFTAR AKUN" DI SINI]
                      // 👉 Ganti `colors: [AppTheme.primary, AppTheme.secondary]`
                      // ==============================================================
                      Obx(() => Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary], // 👈 UBAH WARNA TOMBOL REGISTER DI SINI
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3), // 👈 WARNA BAYANGAN TOMBOL
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: auth.isLoading.value ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: auth.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Daftar Akun',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white, // 👈 WARNA TEKS TOMBOL
                                  ),
                                ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==================================================================
              // 🎨 [5. GANTI WARNA TEKS LINK "MASUK DI SINI"]
              // ==================================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textSecondary, // 👈 WARNA TEKS "Sudah punya akun?"
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primary, // 👈 UBAH WARNA LINK "Masuk" (Contoh: Colors.blue)
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
