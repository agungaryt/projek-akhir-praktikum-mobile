import 'package:get/get.dart';
import '../controllers/simaksi_controller.dart';

class SimaksiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SimaksiController>(() => SimaksiController(), fenix: true);
  }
}
