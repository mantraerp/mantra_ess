import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mantra_ess/Login/loginPage.dart';
import 'package:mantra_ess/Models/attendance_model.dart';
import 'package:mantra_ess/Models/profile_model.dart';
import 'package:mantra_ess/SerialNumberDetails/ShowSerialNumberDetails.dart';

import '../Login/loginPage.dart';
import '../SerialNumberDetails/ErrorMessage.dart';
import 'appWidget.dart';

const jsonGlobal = JsonCodec();
final navigatorKey = GlobalKey<NavigatorState>();
final box = GetStorage();

dynamic _handleFailResponse(dynamic response) {
  try {
    dynamic jsonParseValue = jsonDecode(response.body);
    if (jsonParseValue.keys.contains("message")) {
      if (jsonParseValue["message"].keys.contains("message")) {
        showAlert(ApplicationTitle, jsonParseValue["message"]["message"]);
      }
    } else if (jsonParseValue.keys.contains("exception")) {
      showAlert(ApplicationTitle, jsonParseValue["exception"]);
    } else {
      showAlert(ApplicationTitle, "Issue to operation.");
    }
    return false;
  } catch (val) {
    showAlert(ApplicationTitle, "Error: $val");
    return false;
  }
}

Future<dynamic> apiLogin() async {
  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final String otp = prefsGlobal.getString(NUDMantraPass)!;

  final response = await http.post(
    Uri.parse("$URLLogin?user=$phoneNumber&pwd=$otp"),
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final res = jsonDecode(response.body);
    if (res.keys.contains('allowed_screens')) {
      box.write(ALLOWED_SCREEN, res['allowed_screens']);
      box.write(SID, res['sid']);
    }
    return res;
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiLogout() async {
  final sid = box.read(SID);
  final response = await http.post(
    Uri.parse(URLLogout),
    headers: {'Cookie': 'sid=$sid'},
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    Get.offAll(loginPage());
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiOTPVerification(String OTP) async {
  // var data = {
  //   "user": prefsGlobal.getString(NUDMantraEmail)!,
  //   "pwd": prefsGlobal.getString(NUDMantraPass)!,
  //   "otp":OTP,
  //   "tmp_id":prefsGlobal.getString(NUDMantraTempID)!
  // };
  //
  // final response = await http.post(Uri.parse(URLOTPVerification),body: jsonEncode(data));

  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final String pwd = prefsGlobal.getString(NUDMantraPass)!;
  final String tmp_id = prefsGlobal.getString(NUDMantraTempID)!;

  // final response = await http.post(Uri.parse("$URLOTPVerification?"),body: jsonEncode(data));
  final response = await http.post(
    Uri.parse(
      "$URLOTPVerification?user=$phoneNumber&pwd=$pwd&otp=$OTP&tmp_id=$tmp_id",
    ),
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiGetDashboardMenu() async {
  final response = await http.post(Uri.parse(URLGetMenu), headers: headers);
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiGetUserProfile() async {
  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final response = await http.get(
    Uri.parse('$URLGetProfile?user=$phoneNumber'),
    headers: headers,
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final UserProfileResponse res = userProfileResponseFromJson(response.body);
    return res;
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiGetAttendance(String fromDate, String toDate) async {
  final String employeeCode = box.read('employee_code');
  final response = await http.get(
    Uri.parse(
      '$URLGetAttendance?employee_code=$employeeCode&from_date=$fromDate&to_date=$toDate',
    ),
    headers: headers,
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final AttendanceResponse res = attendanceResponseFromJson(response.body);
    return res;
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiSalarySlipList() async {
  String url =
      "http://192.168.11.66:8011/api/method/erp_mobile.api.masterdata.get_salary_slips?employee_code=HR-EMP-00002&from_date=01-04-2025&to_date=31-03-2026";

  // final response = await http.post(Uri.parse(url),headers:headers);
  final response = await http.get(Uri.parse(url));

  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'];
  } else {
    return _handleFailResponse(response);
  }
}

//Get SerialNumber Api
Future<dynamic> apiTrackSerialNumber(String serialNumber) async {
  String url =
      "http://192.168.11.66:8017/api/method/erp_mobile.api.serial_no.track_serial_number?serial_no=$serialNumber";

  // final response = await http.post(Uri.parse(url),headers:headers);
  final sid = box.read(SID);
  final response = await http.get(Uri.parse(url),headers: {'Cookie': 'sid=$sid'});

  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final data = json.decode(response.body);
    return data['message'];
  } else {
    return _handleFailResponse(response);
  }
}

//Get Batch Number
Future<dynamic> apiTrackBatchNumber(String batchNumber) async {
  String url =
      "http://192.168.11.66:8017/api/method/erp_mobile.api.serial_no.track_batch_details?batch_no=$batchNumber";

  // final response = await http.post(Uri.parse(url),headers:headers);
  final sid = box.read(SID);
  final response = await http.get(Uri.parse(url),headers: {'Cookie': 'sid=$sid'});

  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final data = json.decode(response.body);
    return data['message'];
  } else {
    return _handleFailResponse(response);
  }
}

//Check The Serial Or Batch
Future<String?> apiCheckSerialOrBatchType(String number) async {
  try {
    String url =
        "http://192.168.11.66:8017/api/method/erp_mobile.api.serial_no.check_serial_or_batch?number=$number";

    final sid = box.read(SID);
    final response = await http.get(Uri.parse(url),headers: {'Cookie': 'sid=$sid'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["message"] != null &&
          data["message"]["type"] != null &&
          (data["message"]["type"] == "serial" || data["message"]["type"] == "batch")) {
        return data["message"]["type"];
      } else {
        // Navigate to ErrorPage
        return "Serial Or Batch Number is not found";
      }
    } else {
      // Server error → ErrorPage
      return "Serial and Batch Number is not found";
    }
  } catch (e) {
    // Exception → ErrorPage
    return "Serial and Batch number is not found";
  }
}


//Policy List API
Future<Map<String, dynamic>?> apiPolicyList() async {
  try {
    String url = "http://192.168.11.66:8017/api/method/erp_mobile.api.policy.get_policies";

    final sid = box.read(SID);
    final response = await http.get(Uri.parse(url),headers: {'Cookie': 'sid=$sid'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {"error": "Failed with status ${response.statusCode}"};
    }
  } catch (e) {
    return {"error": "No Data found for this API: $e"};
  }
}

//Policy Details Open Api
Future<Map<String, dynamic>> apifetchPolicyDetails(String policyName) async {
  try{
    String url =
        "http://192.168.11.66:8017/api/method/erp_mobile.api.policy.get_policy_details?policy=$policyName";

    // final response = await http.post(Uri.parse(url),headers:headers);
    final sid = box.read(SID);
    final response = await http.get(Uri.parse(url),headers: {'Cookie': 'sid=$sid'});

    int statusCode = response.statusCode;

    if (statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      return _handleFailResponse(response);
    }
  } catch (e) {
    throw Exception("Error fetching data: $e");
  }
}

//Get Holiday Lists
Future<Map<String, dynamic>?> apiHolidayList() async {
  final String EmployeeCode = box.read('employee_code');
  try {
    String url = "http://192.168.11.66:8017/api/method/erp_mobile.api.holiday.get_holidays?employee_code=$EmployeeCode";

    final sid = box.read(SID);
    final response = await http.get(Uri.parse(url),headers: {'Cookie': 'sid=$sid'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {"error": "Failed with status ${response.statusCode}"};
    }
  } catch (e) {
    return {"error": "No Data found for this API: $e"};
  }
}


