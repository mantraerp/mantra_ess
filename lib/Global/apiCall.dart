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
import 'package:mantra_ess/Models/purchase_order_model.dart';
import 'package:mantra_ess/Models/sales_order_model.dart';

import 'appWidget.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

const jsonGlobal = JsonCodec();
final navigatorKey = GlobalKey<NavigatorState>();
final box = GetStorage();



Future<File?> downloadAndSavePDF(String slipName) async {
  try {
    // Request storage permission
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();

      // If still denied, ask again (once more)
      if (!status.isGranted) {
        showAlert("Permission Required",
            "Storage permission is needed to download the PDF.");
        await Permission.storage.request(); // Ask again
        status = await Permission.storage.status;
      }

      if (!status.isGranted) {
        showAlert("", "Storage permission denied");

      }
    }

    // Get a safe directory for all Android versions
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = await getExternalStorageDirectory();
    }
    downloadsDir ??= await getApplicationDocumentsDirectory();

    // Sanitize filename
    final fileName =
        "${slipName.replaceAll(RegExp(r'[<>:\"/\\\\|?*]'), '_')}.pdf";
    final savePath = "${downloadsDir.path}/$fileName";

    // Read session ID
    final sid = box.read(SID);
    final pdfUrl = "$DownloadSalarySlip?salary_slip=$slipName";

    // Download PDF using Dio
    final dio = Dio();
    await dio.download(
      pdfUrl,
      savePath,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Cookie': 'sid=$sid',
          'Accept': 'application/pdf',
        },
      ),
    );
    await OpenFilex.open(savePath);
    return File(savePath);
  } catch (e) {
    showAlert("", "Failed to download PDF\n$e");
    return null;
  }
}



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
    Uri.parse(URLLogin),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "user": phoneNumber,
      "pwd": otp,
    }),
  );

  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final res = jsonDecode(response.body);
    if (res.keys.contains('allowed_screens')) {
      box.write(ALLOWED_SCREEN, res['allowed_screens']);
      box.write(SID, res['sid']);
    }

    await apiGetEmployeeData(phoneNumber);
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
  final sid = box.read(SID);
  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final String pwd = prefsGlobal.getString(NUDMantraPass)!;
  final String tmp_id = prefsGlobal.getString(NUDMantraTempID)!;


  final response = await http.post(
      Uri.parse(
        "$URLOTPVerification?user=$phoneNumber&pwd=$pwd&otp=$OTP&tmp_id=$tmp_id",
      ),
      headers:{'Cookie': 'sid=$sid', "Content-Type": "application/json",},
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiGetDashboardMenu() async {
  final sid = box.read(SID);
  final response = await http.post(Uri.parse(URLGetMenu), headers:{'Cookie': 'sid=$sid', "Content-Type": "application/json",});
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiGetUserProfile() async {
  final sid = box.read(SID);
  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final response = await http.get(
    Uri.parse('$URLGetProfile?user=$phoneNumber'),
    headers:{'Cookie': 'sid=$sid', "Content-Type": "application/json"},
  );
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final UserProfileResponse res = userProfileResponseFromJson(response.body);
    return res;
  } else {
    return _handleFailResponse(response);
  }
}
Future<dynamic> apiGetEmployeeData(String userEmail) async {
  final sid = box.read(SID);
  final String url = "$URLGetProfile?user=$userEmail";

  final response = await http.get(Uri.parse(url),  headers:{'Cookie': 'sid=$sid', "Content-Type": "application/json"});

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status_code'] == 200) {
      // Save entire response data in global map
      globle_user_detail = data['data'];

      return globle_user_detail;
    } else {
      return _handleFailResponse(response);
    }
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




String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.year}";
}

Future<dynamic> apiSalarySlipList({DateTime? fromDate, DateTime? toDate}) async {
  final String EmployeeCode = globle_user_detail['employee_code'];
  final sid = box.read(SID);
  final String fromDateStr = fromDate != null ? formatDate(fromDate) : '';
  final String toDateStr = toDate != null ? formatDate(toDate) : '';
  String baseUrl = "$URLGetSalarySlip?employee_code=$EmployeeCode&from_date=$fromDateStr&to_date=$toDateStr";

  // Build query parameters dynamically

  // ✅ Build final URL
  Uri url = Uri.parse(baseUrl);

  final response = await http.get(url, headers:{'Cookie': 'sid=$sid', "Content-Type": "application/json"});
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'];
  } else {
    return _handleFailResponse(response);
  }
}


Future<dynamic> apiGetPurchaseOrders(String fromDate, String toDate, int start) async {

    String baseUrl = "$GetPurchaseOrders?from_date=$fromDate&to_date=$toDate&start=$start";
    final response = await http.get(
      Uri.parse(
       baseUrl
      ),
      headers: headers,
    );

    final statusCode = response.statusCode;

    if (statusCode == 200) {
      final PurchaseOrderResponse res = purchaseOrderResponseFromJson(response.body);

      return res;
    } else {
      return _handleFailResponse(response);
    }

}


Future<dynamic> apiGetSalesOrders(String fromDate, String toDate, int start) async {

  String baseUrl = "$GetPurchaseOrders?from_date=$fromDate&to_date=$toDate&start=$start";
  final response = await http.get(
    Uri.parse(
        baseUrl
    ),
    headers: headers,
  );

  final statusCode = response.statusCode;

  if (statusCode == 200) {
    final SalesOrderResponse res = SalesOrderResponseFromJson(response.body);

    return res;
  } else {
    return _handleFailResponse(response);
  }

}