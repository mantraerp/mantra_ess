import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/webService.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

const jsonGlobal = JsonCodec();
final navigatorKey = GlobalKey<NavigatorState>();





Future<bool> apiLogin() async {

  //login
  final String phoneNumber = prefsGlobal.getString(NUDMantraEmail)!;
  final String otp = prefsGlobal.getString(NUDMantraPass)!;

  final response = await http.post(Uri.parse("$Login?usr=$phoneNumber&pwd=$otp"));

  int statusCode = response.statusCode;
  if(statusCode != 200) {
    return false;
  } else {
    var jsonDecoding = jsonDecode(response.body);
    prefsGlobal.setString(NUDMantraUserName, jsonDecoding['full_name']);
    updateCookie(response);
    return true;
  }
}
void setCookieFunction(String rawCookie) {
  if (rawCookie.isNotEmpty) {
    var keyValue = rawCookie.split('=');
    if (keyValue.length == 2) {
      var key = keyValue[0].trim();
      var value = keyValue[1];

      // ignore keys that aren't cookies
      if (key == 'path' || key == 'expires') {
        return;
      }
      cookies[key] = value;
    }
  }
}
void updateCookie(http.Response response) {

  String allSetCookie = response.headers['set-cookie']!;
  var setCookies = allSetCookie.split(',');
  for (var setCookie in setCookies) {
    var cookies = setCookie.split(';');
    for (var cookie in cookies) {
      setCookieFunction(cookie);
    }
  }
  headers['Cookie'] = generateCookieHeader();
}

String generateCookieHeader() {
  String cookie = "";
  for (var key in cookies.keys) {
    if (cookie.isNotEmpty) {
      cookie += ";";
    }
    cookie += "$key=${cookies[key]!}";
  }
  return cookie;
}

