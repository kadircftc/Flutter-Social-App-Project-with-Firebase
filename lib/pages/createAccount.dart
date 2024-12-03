// ignore_for_file: file_names, avoid_print, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String username, mail, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Hesap Oluştur"),
        centerTitle: true,
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
                  autocorrect: true,
                  decoration: const InputDecoration(
                    hintText: "Kullanıcı Adı Giriniz...",
                    labelText: "Kullanıcı Adı:",
                    errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Kullanıcı Adı alanı boş bırakılamaz!";
                    } else if (value.trim().length < 6 ||
                        value.trim().length > 15) {
                      return "Kullanıcı Adı en az 6 en fazla 15 karakterden oluşmalı!!";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    username = value!;
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
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
                    mail = value!;
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Şifre Giriniz...",
                    labelText: "Şifre:",
                    prefixIcon: Icon(Icons.lock),
                    errorStyle: TextStyle(color: Colors.red, fontSize: 15),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Şifre alanı boş bırakılamaz!";
                    } else if (value.trim().length < 8) {
                      return "Şifre en az 8 karakterden oluşmalı!";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () {
                    _createAccount();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Hesap Oluştur",
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

  void _createAccount() async {
    var _formState = _formKey.currentState;
    var _authService = Provider.of<AuthService>(context, listen: false);
    if (_formState!.validate()) {
      _formState.save();
      setState(() {
        isLoading = true;
      });

      try {
        UserModel? user = await _authService.signUpWithEmail(mail, password);
        var token = await messaging.getToken();
        if (user != null) {
          FirestoreService().createuser(
              id: user.id, email: mail, username: username, token: token);
        }

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
    if (errorCode == "email-already-in-use") {
      errorMessage =
          "Girdiğiniz mail başka bir kullanıcı tarafından kullanılıyor!";
    } else if (errorCode == "invalid-email") {
      errorMessage = "Geçerisiz mail!";
    } else if (errorCode == "weak-password") {
      errorMessage = "Lütfen daha güçlü bir şifre oluşturun.!";
    } else {
      errorMessage = "Tanımlanamayan bir hata oluştu!";
    }

    var snackBar = SnackBar(
      content: Text(errorMessage),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
