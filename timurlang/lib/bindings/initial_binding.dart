import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/mountain_controller.dart';
import '../controllers/simaksi_controller.dart';
import '../controllers/profile_controller.dart';

/// Inisialisasi controller utama untuk seluruh aplikasi (Modul VIII: GetX Bindings)
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<MountainController>(() => MountainController(), fenix: true);
    Get.lazyPut<SimaksiController>(() => SimaksiController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
