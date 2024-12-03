// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers, file_names, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/services/authService.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "Şifremi Sıfırla",
          style: TextStyle(fontFamily: 'SF'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 90),
        children: [
          isLoading
              ? LinearProgressIndicator(
                  color: Theme.of(context).primaryColorDark,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                )
              : const SizedBox(
                  height: 0.0,
                ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email Adresi Giriniz...",
                    labelText: "Email:",
                    errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                    prefixIcon: Icon(Icons.mail),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email alanı boş bırakılamaz!";
                    } else if (!value.contains("@")) {
                      return "Lütfen bir email adresi giriniz!";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: _sifreyiSifirla,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Şifremi Sıfırla",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sifreyiSifirla() async {
    var _formState = _formKey.currentState;
    var _authService = Provider.of<AuthService>(context, listen: false);
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        isLoading = true;
      });

      try {
        await _authService.resetPassword(email);

        Navigator.pop(context);
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        if (error is FirebaseAuthException) {
          showWarning(errorCode: error.code);
        }
      }
    }
  }

  showWarning({errorCode}) {
    String errorMessage = "";
    if (errorCode == "invalid-email") {
      errorMessage = "Geçersiz mail!";
    } else if (errorCode == "user-not-found") {
      errorMessage = "Böyle bir kullanıcı bulunmuyor!";
    }

    var snackBar = SnackBar(
      content: Text(errorMessage),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
