// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyByegXYeKPzvN0xeS3LF2O4L3tsF4z765g',
    appId: '1:311849989234:web:4c30ed7e49cb58216e3eeb',
    messagingSenderId: '311849989234',
    projectId: 'campus-life-assistant-ap-5b1ae',
    authDomain: 'campus-life-assistant-ap-5b1ae.firebaseapp.com',
    storageBucket: 'campus-life-assistant-ap-5b1ae.firebasestorage.app',
    measurementId: 'G-3NNP7Q0CQM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDoNWCaXhRztVJWwyPHCJmpBr66o7Mddtk',
    appId: '1:311849989234:android:8851881a429624bc6e3eeb',
    messagingSenderId: '311849989234',
    projectId: 'campus-life-assistant-ap-5b1ae',
    storageBucket: 'campus-life-assistant-ap-5b1ae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoixRqYECvS01soNZPgES4y8uXI2_m_Do',
    appId: '1:311849989234:ios:efc635dd112b6bd56e3eeb',
    messagingSenderId: '311849989234',
    projectId: 'campus-life-assistant-ap-5b1ae',
    storageBucket: 'campus-life-assistant-ap-5b1ae.firebasestorage.app',
    iosBundleId: 'com.example.campusLifeAssistantApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBoixRqYECvS01soNZPgES4y8uXI2_m_Do',
    appId: '1:311849989234:ios:efc635dd112b6bd56e3eeb',
    messagingSenderId: '311849989234',
    projectId: 'campus-life-assistant-ap-5b1ae',
    storageBucket: 'campus-life-assistant-ap-5b1ae.firebasestorage.app',
    iosBundleId: 'com.example.campusLifeAssistantApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyByegXYeKPzvN0xeS3LF2O4L3tsF4z765g',
    appId: '1:311849989234:web:f4445d1006008bec6e3eeb',
    messagingSenderId: '311849989234',
    projectId: 'campus-life-assistant-ap-5b1ae',
    authDomain: 'campus-life-assistant-ap-5b1ae.firebaseapp.com',
    storageBucket: 'campus-life-assistant-ap-5b1ae.firebasestorage.app',
    measurementId: 'G-W495WH8FHL',
  );
}
