import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/appWidget.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Global/webService.dart';
import 'loginPage.dart';
import 'package:mantra_ess/dashboard.dart';

class OTPPage extends StatefulWidget {
  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _txtCode = TextEditingController();
  bool serviceCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      body: serviceCall
          ? const Center(
        child: CircularProgressIndicator(color: appGray),
      )
          : SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/MantraLogo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),

            // Title
            Text(
              'Enter your verification code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appGray,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),

            // OTP TextField
            TextField(
              controller: _txtCode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "Enter 6-digit code",
                counterText: "",
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                  onPressed: _txtCode.clear,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_txtCode.text.isEmpty) {
                    showAlert(ApplicationTitle, 'Please enter code');
                  } else {
                    actOTPVerification();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Verify",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Resend Code Button
            TextButton.icon(
              onPressed: actResendCode,
              icon: const Icon(Icons.refresh, color: Colors.blueAccent),
              label: const Text(
                "Re-Send Code",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 20),

            // Change user option

          ],
        ),
      ),
    );
  }

  void actResendCode() {
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void actOTPVerification() async {
    if (serviceCall) return;
    setState(() => serviceCall = true);

    apiOTPVerification(_txtCode.text).then((response) {
      serviceCall = false;
      setState(() {});

      if (response.runtimeType != bool) {
        // ✅ OTP Verified Successfully
        String cookie = "";
        for (var key in response.keys) {
          if (!['message', 'full_name', 'home_page'].contains(key)) {
            if (cookie.isNotEmpty) cookie += ";";
            cookie += "$key=${response[key]!}";
          }
        }
        headers['Cookie'] = cookie;
        showAlert(ApplicationTitle, "OTP verified successfully!");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => dashboard()));
      } else {

      }
    }).catchError((error) {
      serviceCall = false;
      setState(() {});
      showAlert(ApplicationTitle, "Something went wrong. Please try again.");
    });
  }

  void actSendOTP() async {
  //   if (serviceCall) return;
  //   setState(() => serviceCall = true);
  //
  //   apiLogin().then((response) {
  //     serviceCall = false;
  //     setState(() {});
  //     if (response is String) {
  //       try {
  //         response = jsonDecode(response);
  //       } catch (e) {
  //         showAlert(ApplicationTitle, "Invalid server response.");
  //         return;
  //       }
  //     }
  //
  //     if (response.runtimeType != bool) {
  //       if (response.keys.contains('tmp_id')) {
  //         prefsGlobal.setString(NUDMantraTempID, response['tmp_id']);
  //         showAlert(ApplicationTitle, 'Resend OTP.');
  //       } else {
  //         String cookie = "";
  //         for (var key in response.keys) {
  //           if (!['message', 'full_name', 'home_page', 'sid'].contains(key)) {
  //             if (cookie.isNotEmpty) cookie += ";";
  //             cookie += "$key=${response[key]!}";
  //           }
  //         }
  //         headers['Cookie'] = cookie;
  //       }
  //     }
  //   });
  }
}
