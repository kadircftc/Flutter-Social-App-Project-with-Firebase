import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/firebase_options.dart';
import 'package:socialapp/routing/routing.dart';
import 'package:socialapp/services/authService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SociaApp',
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('SociaApp'),
            actions: [
              Switch(
                value: _isDarkMode,
                onChanged: (value) => _toggleTheme(),
              ),
            ],
          ),
          body: const Routing(),
        ),
      ),
    );
  }
}
