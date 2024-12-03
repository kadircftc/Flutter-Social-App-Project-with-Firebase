// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/loginPage.dart';
import 'package:socialapp/pages/mainPage.dart';
import 'package:socialapp/services/authService.dart';

class Routing extends StatelessWidget {
  const Routing({super.key});

  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder(
      stream: _authService.statusFollower,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Colors.black,
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          UserModel? activeUser = snapshot.data;
          _authService.activeUserId = activeUser!.id;
          return const MainPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
