// ============================================
// TimurLang - Login Screen
// Modul VIII: GetX State Management (Obx, Controller)
// Preserving Original Aura Travel Design System & Plus Jakarta Sans Font
// ============================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  final AuthController auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================================
      // 🎨 [1. GANTI WARNA BACKGROUND HALAMAN LOGIN DI SINI]
      // ----------------------------------------------------------------------------
      // 👉 Ganti `AppTheme.background` di bawah ini jika penguji minta ganti warna background!
      // Contoh pilihan warna cepat:
      //   - Colors.white            (Putih bersih)
      //   - Colors.blue.shade50     (Biru sangat muda)
      //   - Colors.amber.shade50    (Kuning gading muda)
      //   - const Color(0xFF1E293B) (Dark mode / gelap elegan)
      // ============================================================================
      backgroundColor: AppTheme.background, // 👈 UBAH WARNA BACKGROUND LOGIN DI SINI
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ====================================================================
                  // 🎨 [2. GANTI WARNA KOTAK LOGO / ICON LOGIN DI SINI]
                  // --------------------------------------------------------------------
                  // 👉 Ganti `color: AppTheme.surface` (background kotak)
                  // 👉 Ganti `color: AppTheme.border` (garis tepi border kotak)
                  // ====================================================================
                  Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface, // 👈 UBAH WARNA BACKGROUND KOTAK LOGO
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.border, width: 1.2), // 👈 UBAH BORDER KOTAK LOGO
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_timurlang.png',
                      fit: BoxFit.contain,
                      // ==============================================================
                      // 🎨 [3. GANTI WARNA IKON LOGO LOGIN DI SINI]
                      // --------------------------------------------------------------
                      // 👉 Ganti `color: AppTheme.primary` di bawah (Contoh: Colors.blue, Colors.orange, Colors.red)
                      // ==============================================================
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.terrain_rounded,
                        size: 40,
                        color: AppTheme.primary, // 👈 UBAH WARNA IKON LOGO DI SINI
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ==================================================================
                  // 🎨 [4. GANTI WARNA TEKS JUDUL "TimurLang"]
                  // ==================================================================
                  Text(
                    'TimurLang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary, // 👈 UBAH WARNA JUDUL DI SINI (Contoh: Colors.blue, Colors.green)
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ==================================================================
                  // 🎨 [5. GANTI WARNA TEKS SUBJUDUL]
                  // ==================================================================
                  Text(
                    'Masuk ke akun Anda untuk melanjutkan',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textSecondary, // 👈 UBAH WARNA SUBJUDUL DI SINI
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ====================================================================
                  // 🎨 [6. GANTI WARNA KARTU FORM CONTAINER DI SINI]
                  // --------------------------------------------------------------------
                  // 👉 Ganti `color: AppTheme.surface` (Contoh: Colors.white, Colors.grey.shade100)
                  // 👉 Ganti `color: AppTheme.border` (Garis border kartu)
                  // ====================================================================
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.surface, // 👈 UBAH WARNA KARTU FORM DI SINI
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
                          // Email Field
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            hint: 'nama@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),

                          // Password Field
                          CustomTextField(
                            controller: _passwordCtrl,
                            label: 'Kata Sandi',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: Validators.password,
                          ),

                          // Remember Me Checkbox
                          Obx(() => Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                // ====================================================
                                // 🎨 [7. GANTI WARNA CHECKBOX "INGAT SAYA"]
                                // ====================================================
                                child: Checkbox(
                                  value: auth.rememberMe.value,
                                  activeColor: AppTheme.primary, // 👈 WARNA CHECKBOX AKTIF
                                  checkColor: Colors.white, // 👈 WARNA CENTANG DI DALAM CHECKBOX
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  side: const BorderSide(
                                    color: AppTheme.border, // 👈 WARNA BORDER CHECKBOX
                                    width: 1.5,
                                  ),
                                  onChanged: (val) {
                                    auth.rememberMe.value = val ?? false;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  auth.rememberMe.value = !auth.rememberMe.value;
                                },
                                child: Text(
                                  'Ingat Saya',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.textPrimary, // 👈 WARNA TEKS INGAT SAYA
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          )),
                          const SizedBox(height: 20),

                          // ==================================================================
                          // 🎨 [8. GANTI WARNA TOMBOL "MASUK" DI SINI]
                          // ------------------------------------------------------------------
                          // 👉 Tombol ini menggunakan gradien LinearGradient:
                          //    - Ganti `colors: [AppTheme.primary, AppTheme.secondary]`
                          //    - Contoh Biru:   `colors: [Colors.blue, Colors.lightBlue]`
                          //    - Contoh Merah:  `colors: [Colors.red, Colors.deepOrange]`
                          //    - Contoh Oranye: `colors: [Colors.orange, Colors.amber]`
                          //    - Contoh Solid:  `colors: [Colors.teal, Colors.teal]`
                          // ==================================================================
                          Obx(() => Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.secondary], // 👈 UBAH WARNA TOMBOL MASUK DI SINI
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
                              onPressed: auth.isLoading.value ? null : _handleLogin,
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
                                      'Masuk',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white, // 👈 WARNA TEKS TOMBOL MASUK (Putih)
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
                  // 🎨 [9. GANTI WARNA TEKS LINK "DAFTAR SEKARANG"]
                  // ==================================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textSecondary, // 👈 WARNA TEKS "Belum punya akun?"
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: Text(
                          'Daftar Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primary, // 👈 UBAH WARNA TEKS LINK DAFTAR DI SINI (Contoh: Colors.blue)
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
        ),
      ),
    );
  }
}
