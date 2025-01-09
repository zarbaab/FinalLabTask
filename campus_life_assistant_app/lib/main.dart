import 'package:campus_life_assistant_app/AssignmentTrackerScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// For mobile platforms (Android/iOS)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:campus_life_assistant_app/login.dart';
import 'signup.dart';
import 'dashboardscreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Life Assistant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/assignments': (context) => const AssignmentTrackerScreen(),
      },
    );
  }
}
