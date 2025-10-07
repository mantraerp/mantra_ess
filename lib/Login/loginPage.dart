import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/AppWidget.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Login/OTPPage.dart';
import 'package:mantra_ess/dashboard.dart';


class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  _loginPageState createState() => _loginPageState();
}
class _loginPageState extends State<loginPage> {

  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  bool serviceCall = false;
  bool showPassword = true;

  @override
  void initState() {
    super.initState();

    showPassword = true;
    _fillIDPassword();
  }

  _fillIDPassword() async {

    txtEmail.text="ravi.patel@mantratec.com";
    txtPassword.text="Mantra@123";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: appWhite,
      body: screenDesign(context),
    );
  }

  Widget screenDesign(BuildContext context){

    return Center(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: <Widget> [
          const SizedBox(height: 40.0),
          Image.asset('assets/MantraLogo.png',width: deviceWidth,height: 120.0),
          const SizedBox(height: 30.0),
          TextFormField(
            controller: txtEmail,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    txtEmail.clear();
                  }),
              labelText: "Enter your email",
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(
                ),
              ),
            ),
            validator: (val) {
              if(val!.isEmpty) {
                return "Email cannot be empty";
              }else{
                return null;
              }
            },
            keyboardType: TextInputType.emailAddress,
          ) ,
          const SizedBox(height: 30.0),
          TextFormField(
            obscureText: showPassword,
            controller: txtPassword,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    if(showPassword)
                      {
                        showPassword = false;
                      }else{
                      showPassword = true;
                    }
                    setState(() {

                    });
                  }),
              labelText: "Enter your password",
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(
                ),
              ),
              //fillColor: Colors.green
            ),
            validator: (val) {
              if(val!.isEmpty) {
                return "Password cannot be empty";
              }else{
                return null;
              }
            },
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 50.0),
          SizedBox(
            height: 50,
            width: 150,
            child: MaterialButton(
              height: 40.0,
              minWidth: 135.0,
              color: Colors.white,
              textColor: appBlack,
              shape: RoundedRectangleBorder(side: const BorderSide(
                  color: appBlack,
                  width: 0.5,
                  style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(5)),
              onPressed: ()
              {
                // if(txtEmail.text.isEmpty)
                // {
                //   showAlert(deskApplicationTitle, "Please enter your email ID.");
                // }
                // else if(txtPassword.text.isEmpty)
                // {
                //   showAlert(deskApplicationTitle, "Please enter your password.");
                // }
                // else
                // {
                      actLoginCall(context);
                // }
              },
              child:serviceCall ?
              const SizedBox(height: 20,width: 20,
                child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(appGrayDark)),)
                  : mantraLabel('Login', 18,appGray, TextAlign.left, FontWeight.w500, 1),
            ),
          ),
          const SizedBox(height: 60.0,),
        ],
      ),
    );
  }

  void actLoginCall(BuildContext context) async {

    if(serviceCall){return;}
    setState(() {serviceCall = true;});

    prefsGlobal.setString(NUDMantraEmail, txtEmail.text);
    prefsGlobal.setString(NUDMantraPass, txtPassword.text);
    apiLogin().then((response)
    {
      serviceCall = false;
      if (response.runtimeType==bool)
      {
        setState(() {});
      }
      else
      {
        var allKeys = response.keys;

        if(allKeys.contains('tmp_id'))
        {
          prefsGlobal.setString(NUDMantraTempID, response['tmp_id']);
          Navigator.push(
              context,
              CupertinoPageRoute(builder: (
                  context) => OTPPage()));
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

          Navigator.push(
              context,
              CupertinoPageRoute(builder: (
                  context) => dashboard()));
        }
      }
    });
  }
}