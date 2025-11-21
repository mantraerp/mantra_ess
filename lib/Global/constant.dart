import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

double deviceWidth = 0.0;
double deviceHeight = 0.0;
double deviceHeightWithoutSafeArea = 0.0;

double topSpaceFromNavigationbar = 50;

//Cookies
Map<String, String> cookies = {};
Map<String, String> headers = {
  "content-type": "application/x-www-form-urlencoded",
};

const String ApplicationTitle = 'Mantra Ess';

/* Route Name */
const String ScreenDashboard = '/DashboardPage';

/* User defaults values */
const String NUDMantraEmail = "nudMantraEmail";
const String NUDMantraPass = "nudMantraPass";

const String NUDMantraTempID = "nudMantraTempID";

/* Colour */
const Color appWhite = Colors.white;
const Color appGray = Color.fromARGB(255, 76, 92, 101);
const Color appBlack = Colors.black;
const Color appGrayDark = Color.fromARGB(255, 110, 110, 109); //Text Colour
const Color appMantraBlue = Colors.black;
const Color appBlue100 = Color(0xffcddaff);
const Color appRed = Color(0xffEF4D56);
const Color appGreen = Color.fromARGB(255, 202, 248, 232);
const Color appBlue = Color.fromARGB(255, 176, 193, 241);
const Color appGrey800 = Color(0xff919191);
const Color appText = Color(0xff25272C);
const Color appYellow = Color(0xffFFCE6E);

/* Image */
const String IMGLoader = "assets/MantraLogo.png";

/* Message */
const String Msg_InternetConnection = 'Check your internet connection';
const String Msg_Res_Issue_In_Signup = 'There is some issue please try again.';

/* Global Variable */
late final SharedPreferences prefsGlobal;

final String ALLOWED_SCREEN = 'allowed_screens';
final String SID = 'sid';
Map<dynamic,dynamic> globle_user_detail = {};
const String CachedPurchaseOrders = "cached_po_list";
