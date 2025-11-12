import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Models/profile_model.dart';

import '../Global/apiCall.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  Rx<UserProfileData>? profileData;

  void saveEmployeeCode() async {
    final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
    final res = await apiGetEmployeeData(phoneNumber);
    print(res);

    if (res is UserProfileResponse) {
      profileData = res.data.obs;
      box.write('employee_code', res.data.employeeCode);
      box.write('user_email',res.data.email);
    }
    print(box);
  }

  Map<String, String> getImageHeaders() {
    final sid = box.read(SID);
    return {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'};
  }
}
