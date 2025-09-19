import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/webService.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'AppWidget.dart';

const jsonGlobal = JsonCodec();
final navigatorKey = GlobalKey<NavigatorState>();



dynamic _handleFailResponse(dynamic response){

  try {
    dynamic jsonParseValue = jsonDecode(response.body);
    if (jsonParseValue.keys.contains("message")) {
      if (jsonParseValue["message"].keys.contains("message")) {
        showAlert(ApplicationTitle, jsonParseValue["message"]["message"]);
      }
    }
    else if (jsonParseValue.keys.contains("exception")) {
      showAlert(ApplicationTitle, jsonParseValue["exception"]);
    }
    else {
      showAlert(ApplicationTitle, "Issue to operation.");
    }
    return false;
  }
  catch (val)
  {
    showAlert(ApplicationTitle,"Error: $val");
    return false;
  }
}


Future<dynamic> apiLogin() async {

  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final String otp = prefsGlobal.getString(NUDMantraPass)!;

  final response = await http.post(Uri.parse("$URLLogin?user=$phoneNumber&pwd=$otp"));
  int statusCode = response.statusCode;

  if(statusCode == 200) {
    return jsonDecode(response.body);
  }
  else
  {
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
  final response = await http.post(Uri.parse("$URLOTPVerification?user=$phoneNumber&pwd=$pwd&otp=$OTP&tmp_id=$tmp_id"));
  int statusCode = response.statusCode;

  if(statusCode == 200) {
    return jsonDecode(response.body);
  }
  else
  {
    return _handleFailResponse(response);
  }
}

Future<dynamic> apiGetDashboardMenu() async {

  final response = await http.post(Uri.parse(URLGetMenu),headers:headers);
  int statusCode = response.statusCode;

  if(statusCode == 200) {
    return jsonDecode(response.body);
  }
  else
  {
    return _handleFailResponse(response);
  }
}
