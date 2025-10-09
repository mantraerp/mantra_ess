import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mantra_ess/Controllers/profile_controller.dart';
import 'package:mantra_ess/Global/constant.dart';

class DashboardController extends GetxController {
  RxList<String> dashboardCards = RxList.empty();
  final profileController = Get.find<ProfileController>();
  final box = GetStorage();

  void getDashboardCards() {
    List<String> allowedScreens = (box.read(ALLOWED_SCREEN) as List)
        .cast<String>();
    dashboardCards.value = allowedScreens;
  }

  @override
  void onInit() {
    super.onInit();
    getDashboardCards();
    profileController.saveEmployeeCode();
  }
}
