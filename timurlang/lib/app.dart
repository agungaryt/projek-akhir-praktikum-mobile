import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'config/routes.dart';

// Bindings (Modul VIII: GetX Bindings & Dependency Injection)
import 'bindings/initial_binding.dart';
import 'bindings/auth_binding.dart';
import 'bindings/mountain_binding.dart';
import 'bindings/simaksi_binding.dart';
import 'bindings/profile_binding.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/mountain/mountain_list_screen.dart';
import 'screens/mountain/mountain_detail_screen.dart';
import 'screens/simaksi/simaksi_form_screen.dart';
import 'screens/simaksi/simaksi_payment_screen.dart';
import 'screens/simaksi/simaksi_ticket_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/compass/compass_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/personal_data_screen.dart';
import 'screens/profile/medical_profile_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TimurLang',
      theme: AppTheme.auraTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.register,
          page: () => const RegisterScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
          binding: InitialBinding(),
        ),
        GetPage(
          name: AppRoutes.mountainList,
          page: () => const MountainListScreen(),
          binding: MountainBinding(),
        ),
        GetPage(
          name: AppRoutes.mountainDetail,
          page: () => const MountainDetailScreen(),
          binding: MountainBinding(),
        ),
        GetPage(
          name: AppRoutes.simaksiForm,
          page: () => const SimaksiFormScreen(),
          binding: SimaksiBinding(),
        ),
        GetPage(
          name: AppRoutes.simaksiPayment,
          page: () => const SimaksiPaymentScreen(),
          binding: SimaksiBinding(),
        ),
        GetPage(
          name: AppRoutes.simaksiTicket,
          page: () => const SimaksiTicketScreen(),
          binding: SimaksiBinding(),
        ),
        GetPage(
          name: AppRoutes.map,
          page: () => const MapScreen(),
        ),
        GetPage(
          name: AppRoutes.weather,
          page: () => const WeatherScreen(),
        ),
        GetPage(
          name: AppRoutes.compass,
          page: () => const CompassScreen(),
        ),
        GetPage(
          name: AppRoutes.profile,
          page: () => const ProfileScreen(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: AppRoutes.personalData,
          page: () => const PersonalDataScreen(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: AppRoutes.medicalProfile,
          page: () => const MedicalProfileScreen(),
          binding: ProfileBinding(),
        ),
      ],
    );
  }
}
