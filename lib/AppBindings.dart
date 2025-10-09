import 'package:get/get.dart';
import 'package:mantra_ess/Controllers/profile_controller.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
