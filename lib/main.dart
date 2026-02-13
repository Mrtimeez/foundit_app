import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foundit/authentication/login_screen.dart';
import 'package:foundit/authentication/signup.dart';
import 'package:foundit/authentication/warpper.dart';
import 'package:foundit/view/homepage.dart';
import 'navigation_bar.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Found it',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Wrapper(),

      // initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainNavigation(),

      },

    );
  }
}

