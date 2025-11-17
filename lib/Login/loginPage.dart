import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mantra_ess/Global/appWidget.dart';
import 'package:mantra_ess/Global/apiCall.dart';
import 'package:mantra_ess/Global/constant.dart';
import 'package:mantra_ess/Login/OTPPage.dart';
import 'package:mantra_ess/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ import this

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  bool serviceCall = false;
  bool showPassword = false;
  bool rememberMe = false; // ✅ new flag

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // ✅ load saved email/password if rememberMe was true
  }

  // ✅ Load saved credentials
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final savedRemember = prefs.getBool('remember_me') ?? false;

    if (savedRemember) {
      setState(() {
        txtEmail.text = savedEmail ?? '';
        txtPassword.text = savedPassword ?? '';
        rememberMe = savedRemember;
      });
    }
  }

  // ✅ Save or clear credentials
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', txtEmail.text);
      await prefs.setString('saved_password', txtPassword.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf6f8fb), Color(0xFFdce3f0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(child: _buildLoginForm(context)),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/MantraLogo.png', width: 160, height: 120),
          const SizedBox(height: 40),

          Text(
            "Welcome Back",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          const Text("Sign in to continue",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 40),

          // Email
          TextFormField(
            controller: txtEmail,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: txtEmail.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  txtEmail.clear();
                  setState(() {});
                },
              )
                  : null,
              labelText: "Email",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Password
          TextFormField(
            controller: txtPassword,
            obscureText: !showPassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
              labelText: "Password",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ✅ Remember Me checkbox
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                activeColor: const Color(0xFF3E64FF),
                onChanged: (bool? value) {
                  setState(() {
                    rememberMe = value ?? false;
                  });
                },
              ),
              const Text(
                "Remember Me",
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E64FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: serviceCall ? null : () => actLoginCall(context),
              child: serviceCall
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                "Login",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void actLoginCall(BuildContext context) async {
    if (serviceCall) return;

    setState(() => serviceCall = true);

    prefsGlobal.setString(NUDMantraEmail, txtEmail.text);
    prefsGlobal.setString(NUDMantraPass, txtPassword.text);

    apiLogin().then((response) async {
      setState(() => serviceCall = false);

      if (response.runtimeType == bool) {
        setState(() {});
      } else {
        await _saveCredentials();

        var allKeys = response.keys;
        if (allKeys.contains('tmp_id')) {
          prefsGlobal.setString(NUDMantraTempID, response['tmp_id']);
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => OTPPage()),
          );
        } else {
          String cookie = "";
          for (var key in response.keys) {
            if (!['message', 'full_name', 'home_page'].contains(key)) {
              if (cookie.isNotEmpty) cookie += ";";
              cookie += "$key=${response[key]!}";
            }
          }
          headers['Cookie'] = cookie;
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => dashboard()),
          );
        }
      }
    });
  }
}
