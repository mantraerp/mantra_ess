import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


double  deviceWidth = 0.0;
double  deviceHeight = 0.0;
double  deviceHeightWithoutSafeArea = 0.0;

double topSpaceFromNavigationbar = 50;


//Cookies
Map<String, String> cookies = {};
Map<String, String> headers = {
    "content-type": "application/x-www-form-urlencoded"
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
const Color appGrayDark = Color.fromARGB(255, 110, 110, 109);//Text Colour
const Color appMantraBlue = Colors.black;

/* Image */
const String IMGLoader = "assets/MantraLogo.png";

/* Message */
const String Msg_InternetConnection = 'Check your internet connection';
const String Msg_Res_Issue_In_Signup = 'There is some issue please try again.';

/* Global Variable */
late final SharedPreferences prefsGlobal;
