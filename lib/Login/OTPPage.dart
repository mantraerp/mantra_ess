import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/appWidget.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'LoginPage.dart';

class OTPPage extends StatefulWidget {

  @override
  _OTPPageState createState() => _OTPPageState();
}
class _OTPPageState extends State<OTPPage> {

  final TextEditingController _txtCode = TextEditingController();
  bool loginCall = false;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: appWhite,
      body: screenDesign(context),
    );
  }

  Widget screenDesign(BuildContext context){

    if(loginCall){
      return Center(
          child:Image.asset(
            IMGLoader,
            height: 100.0,
            width: 100.0,
          )
      );
    }

    return Center(
      child:
      ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: <Widget> [
          const SizedBox(height: 80.0),
          Image.asset('assets/MantraLogo.png',width: deviceWidth,height: 120.0),
          const SizedBox(height: 30.0),
          mantraLabel('Enter your verification code', 18,appGray, TextAlign.left, FontWeight.w500, 1),
          const SizedBox(height: 50.0),
          TextFormField(
            controller: _txtCode,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _txtCode.clear();
                  }),
              // labelStyle:GoogleFonts.plusJakartaSans(
              //     fontWeight: FontWeight.w500,
              //     textStyle: const TextStyle(
              //       fontSize: 17,
              //       color: deskappNavigation,
              //     )
              // ),
              labelText: "Varification code",
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(
                ),
              ),
            ),
            validator: (val) {
              if(val!.isEmpty) {
                return "Varification code cannot be empty";
              }else{
                return null;
              }
            },
            keyboardType: TextInputType.number,
            // style:GoogleFonts.plusJakartaSans(
            //     fontWeight: FontWeight.w500,
            //     textStyle: const TextStyle(
            //       fontSize: 17,
            //       color: deskappNavigation,
            //     )
            // ),
          ),
          const SizedBox(height: 50.0),
          MaterialButton(
            height: 40.0,
            minWidth: 135.0,
            color: Colors.white,
            textColor: appGray,
            shape: RoundedRectangleBorder(side: const BorderSide(
                color: appGray,
                width: 0.5,
                style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(5)),
            onPressed: () {

              if(_txtCode.text.isEmpty)
              {
                showAlert(ApplicationTitle, 'Please enter code');
              }
              else
              {
                actOTPVerification();
              }
            },
            child: mantraLabel('Verify', 18,appGray, TextAlign.left, FontWeight.w500, 1),
          ),
          appButtonGray("Re-Send code",actResendCode,Alignment.center,100,40),
        ],
      ),
    );
  }

  void actResendCode(){

    String otpString = 'OTP will be sent on number ${prefsGlobal.getString(NUDMantraEmail)}.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: mantraLabel('Re-Send code', 18,appGray, TextAlign.left, FontWeight.w500, 1),
          content: mantraLabel(otpString, 18,appGray, TextAlign.left, FontWeight.w400, 3),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: mantraLabel('Re-Send', 12,appGray, TextAlign.center, FontWeight.w500, 1),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  loginCall = true;
                  actSendOTP();
                });
                //
              },
            ),
            TextButton(
              child: mantraLabel('Change number', 12,appGray, TextAlign.center, FontWeight.w500, 1),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: mantraLabel('Cancel', 12,appGray, TextAlign.center, FontWeight.w500, 1),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  void actOTPVerification() async {

    if(loginCall){
      return;
    }

    setState(() {
      loginCall = true;
    });

    final String tmp_id = prefsGlobal.getString(NUDMantraTempID)!;
    final String email = prefsGlobal.getString(NUDMantraEmail)!;
    final String pass = prefsGlobal.getString(NUDMantraPass)!;



    final response = await http.post(Uri.parse("$URLOTPVerification?user=$email&pwd=$pass&tmp_id=$tmp_id&otp=${_txtCode.text}"));
    var jsonData = json.decode(response.body);
    int statusCode = int.parse(jsonData["message"]["status_code"].toString());
    if(statusCode != 200)
    {
      setState(() {
        loginCall = false;
      });
      showAlert(ApplicationTitle, jsonData["message"]["message"]);
    }
    else
    {
      String cookie = "";
      for (var key in jsonData.keys)
      {
        if(!['message','full_name','home_page'].contains(key))
        {
          if (cookie.isNotEmpty) {
            cookie += ";";
          }
          cookie += "$key=${cookies[key]!}";
        }
      }

      print(cookie);




      loginCall = false;
      // _saveValues();
      // Navigator.push(
      //     context,
      //     CupertinoPageRoute(builder: (
      //         context) => NamePage()));
    }
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

  void actSendOTP() async {

    if(loginCall){
      return;
    }

    setState(() {loginCall = true;});

    // final String phoneNumber = prefsGlobal.getString(NUDBDPhoneNumber)!;
    // final response = await http.post(Uri.parse("$WSSendOTP?phoneNo=$phoneNumber"));
    // var jsonData = json.decode(response.body);
    // setState(() {
    //   loginCall = false;
    // });
    //
    //
    // if(jsonData["message"] == "False")
    // {
    //   showAlert(ApplicationTitle, "Please enter proper number");
    // }
    // else
    // {
    //   Fluttertoast.showToast(
    //       msg: "OTP Sent",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: appGreen,
    //       textColor: Colors.white,
    //       fontSize: 16.0
    //   );
    // }
  }
  _saveValues() async {
    // prefsGloble.setString(NUDBDOTP, _txtCode.text);
    // prefsGloble.setBool(NUDBDLogin, true);
    _txtCode.text = "";
  }
}

