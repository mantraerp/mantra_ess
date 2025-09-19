import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/apiCall.dart';
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
  bool serviceCall = false;

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

    if(serviceCall){
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

    String otpString = 'OTP will be sent on ${prefsGlobal.getString(NUDMantraEmail)}.';

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
                  serviceCall = true;
                  actSendOTP();
                });
                //
              },
            ),
            TextButton(
              child: mantraLabel('Change user', 12,appGray, TextAlign.center, FontWeight.w500, 1),
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

    if(serviceCall){return;}
    setState(() {serviceCall = true;});

    apiOTPVerification(_txtCode.text).then((response)
    {
      serviceCall = false;
      setState(() {});
      if (response.runtimeType!=bool)
      {
          String cookie = "";
          for (var key in response.keys)
          {
            if(!['message','full_name','home_page'].contains(key))
            {
              if (cookie.isNotEmpty) {
                cookie += ";";
              }
              cookie += "$key=${response[key]!}";
            }
          }
          headers['Cookie']=cookie;
      }
    });
  }
  void actSendOTP() async {

    if(serviceCall){
      return;
    }
    setState(() {serviceCall = true;});
    apiLogin().then((response)
    {
      serviceCall = false;
      setState(() {});
      if (response.runtimeType!=bool)
      {
        var allKeys = response.keys;

        if(allKeys.contains('tmp_id'))
        {
          prefsGlobal.setString(NUDMantraTempID, response['tmp_id']);
          showAlert(ApplicationTitle, 'Resend OTP.');
        }
        else
        {
          String cookie = "";
          for (var key in response.keys)
          {
            if(!['message','full_name','home_page'].contains(key))
            {
              if (cookie.isNotEmpty) {
                cookie += ";";
              }
              cookie += "$key=${response[key]!}";
            }
          }
          headers['Cookie']=cookie;
        }
      }
    });
  }
}

