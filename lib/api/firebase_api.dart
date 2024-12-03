// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title:${message.notification?.title}');
  print('Body:${message.notification?.body}');
  print('Payload:${message.data}');
}

class FirebaseApi {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print("title:${message.notification?.title}");
  }

  Future<void> initNotifications() async {
    await messaging.requestPermission();
    final fCMToken = await messaging.getToken();
    print("Token:$fCMToken");
    FirebaseMessaging.onBackgroundMessage(
        (message) => handleBackgroundMessage(message));
  }
}
