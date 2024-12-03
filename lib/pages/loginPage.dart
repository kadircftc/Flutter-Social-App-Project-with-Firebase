// ignore_for_file: file_names, avoid_print, no_leading_underscores_for_local_identifiers, unused_element, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/createAccount.dart';
import 'package:socialapp/pages/forgotPassword.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isLoading = false;
  bool passwordVisibility = true;

  String? mail, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        pageElements(),
        _loadingAnimation(),
      ]),
    );
  }

  Widget _loadingAnimation() {
    if (isLoading) {
      return const Positioned(
          left: 285, top: 50, child: CircularProgressIndicator());
    } else {
      return const Center();
    }
  }

  Form pageElements() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 60),
        children: [
          const SizedBox(
            height: 100,
          ),
          const FlutterLogo(
            size: 90.0,
          ),
          const SizedBox(
            height: 80.0,
          ),
          TextFormField(
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Email Adresi Giriniz...",
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
              mail = value;
            },
          ),
          const SizedBox(
            height: 40,
          ),
          TextFormField(
            obscureText: passwordVisibility,
            decoration: const InputDecoration(
              hintText: "Şifre Giriniz...",
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
              password = value;
            },
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  passwordVisibility = !passwordVisibility;
                });
              },
              icon: Icon(passwordVisibility
                  ? Icons.visibility_off
                  : Icons.visibility)),
          const SizedBox(
            height: 50,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    onPressed: () {
                      _login();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Giriş Yap",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => const CreateAccount()));
                      },
                      child: Container(
                          color: Colors.white,
                          child: const Text(
                            "Hesabınız yok mu? Hemen Kaydolun!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()));
                      },
                      child: Container(
                          color: Colors.white,
                          child: const Text(
                            "Şifremi Unuttum!",
                            style: TextStyle(
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          )),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  _signInWithGoogle() async {
    var _authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      UserModel? user = await _authService.googleSignIn();

      if (user != null) {
        UserModel? firestoreUser =
            await FirestoreService().getUserById(user.id);
        var token = await messaging.getToken();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.id)
            .update({"token": token});

        if (firestoreUser == null) {
          FirestoreService().createuser(
              id: user.id,
              email: user.mail,
              username: user.name,
              photoUrl: user.avatar);
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      if (error is FirebaseAuthException) {
        showWarning(errorCode: error.code);
      }
    }
  }

  void _login() async {
    var _authService = Provider.of<AuthService>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      try {
        UserModel? user = await _authService.signInWithEmail(mail!, password!);
        var token = await messaging.getToken();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.id)
            .update({"token": token});
      } catch (error) {
        if (error is FirebaseAuthException) {
          setState(() {
            isLoading = false;
          });
          showWarning(errorCode: error.code);
        }
      }
    }
  }

  showWarning({errorCode}) {
    String errorMessage = "";

    if (errorCode == "invalid-email") {
      errorMessage = "Geçersiz Email!";
    } else if (errorCode == "user-disabled") {
      errorMessage =
          "Kullanıcı Haklarını İhlal Ettiğiniz için Hesabınız Devre Dışı Bırakılmış!";
    } else if (errorCode == "user-not-found") {
      errorMessage = "Kullanıcı Bulunamadı!";
    } else if (errorCode == "wrong-password") {
      errorMessage = "Yanlış Parola!";
    }
    var snackBar = SnackBar(
      content: Text(errorMessage),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
