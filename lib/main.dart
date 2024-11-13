import 'package:attandance_app/Auth/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDNLcuehXLKFM9Xjpx33cGVtvT67HXwiDQ",
    appId: "1:374523963270:android:5d765dd68411117c81ee07",
    messagingSenderId: "374523963270",
    projectId: "attandance-app-f6dce",
    storageBucket: "attandance-app-f6dce.firebasestorage.app",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      // home:  Driver_Dashboard(),
    );
  }
}
