// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiSA2AMDXrCst-SNQy4M154DEwpImJ0rM',
    appId: '1:227826840780:web:dd280ff058a494f9ea7e69',
    messagingSenderId: '227826840780',
    projectId: 'socialapp-4db20',
    authDomain: 'socialapp-4db20.firebaseapp.com',
    storageBucket: 'socialapp-4db20.appspot.com',
    measurementId: 'G-XW7579VLJP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlMNVitBG_vCHdBA5K0omUegzr4Jk6kvs',
    appId: '1:227826840780:android:97b14e8d364236b9ea7e69',
    messagingSenderId: '227826840780',
    projectId: 'socialapp-4db20',
    storageBucket: 'socialapp-4db20.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOi6GdZhOq9cdL5KvPs1B9sd-6jWjgXt4',
    appId: '1:227826840780:ios:110ceb60856eae8aea7e69',
    messagingSenderId: '227826840780',
    projectId: 'socialapp-4db20',
    storageBucket: 'socialapp-4db20.appspot.com',
    iosClientId: '227826840780-n8vjgdtmkg9ui8prnsq9sp660olltdev.apps.googleusercontent.com',
    iosBundleId: 'com.example.socialapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDOi6GdZhOq9cdL5KvPs1B9sd-6jWjgXt4',
    appId: '1:227826840780:ios:04e26764a91ffa00ea7e69',
    messagingSenderId: '227826840780',
    projectId: 'socialapp-4db20',
    storageBucket: 'socialapp-4db20.appspot.com',
    iosClientId: '227826840780-hoo00gcp26a7phg2b7ni5ntsjh66ngpa.apps.googleusercontent.com',
    iosBundleId: 'com.example.socialapp.RunnerTests',
  );
}
