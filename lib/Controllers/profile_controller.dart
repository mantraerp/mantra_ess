import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mantra_ess/Models/profile_model.dart';

import '../Global/apiCall.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  void saveEmployeeCode() async {
    final res = await apiGetUserProfile();
    if (res is UserProfileResponse) {
      box.write('employee_code', res.data.employeeCode);
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
