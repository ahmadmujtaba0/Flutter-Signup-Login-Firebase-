# Login-page-Flutter-
Flutter Signup/Login page With Firebase

A simple application design with flutter. Application is connected with Firebase to store and retrive user data data from firestore.





Code files are attached




main.dart 

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginPage.dart';


void main() async {
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
      title: 'Login / Signup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}





LoginPage.dart


