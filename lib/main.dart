import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Login/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'Global/constant.dart';
import 'dart:io';



class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}


void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(MaterialApp (
    title: "Mantra",
    home: const LaunchScreen(),
    navigatorKey: navigatorKey,
    routes: <String, WidgetBuilder> {
      '/LoginPage': (BuildContext context) => loginPage(),
    },
    debugShowCheckedModeBanner:false,
    theme: ThemeData(
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
      ),
    ),
  )
  );
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});
  @override
  LaunchScreenState createState() => LaunchScreenState();
}
class LaunchScreenState extends State<LaunchScreen>
{
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  startTimer() async {
    prefsGlobal = await SharedPreferences.getInstance();

    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }
  void navigationPage() async {

    // full screen width and height
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    // height without SafeArea
    var padding = MediaQuery.of(context).padding;
    deviceHeightWithoutSafeArea = deviceHeight - padding.top - padding.bottom;

    // full screen width and height
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    //Reset because every time it require to login and check in internet connection screen
    // prefsGloble.setBool(deskNUDBFFLogin, false);
    //
    // var isDisLogin = prefsGloble.getBool(NUDDISLogin);
    // if(isDisLogin==null)
    // {
    //   prefsGloble.setBool(NUDDISLogin, false);
    // }
    //
    // var isDisLoginCheck = prefsGloble.getBool(NUDDISLogin);
    // if(isDisLoginCheck==true)
    // {
    //   Navigator.of(context).pushReplacementNamed('/DashboardPageDistributor');
    // }
    // else
    // {
    //   var isLogin = prefsGloble.getBool(NUDBDLogin);
    //   if(isLogin==null){
    //     prefsGloble.setBool(NUDBDLogin, false);
    //   }
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    // }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      body: SafeArea(
        top: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 10.0),
              Image(
                image: AssetImage("assets/MantraLogo.png"),
                height: 50,
                width: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}