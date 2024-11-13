import 'package:attandance_app/Auth/helper_function.dart';
import 'package:attandance_app/Auth/login_screen.dart';
import 'package:attandance_app/Auth/usermodel.dart';
import 'package:attandance_app/admin/admin_panel.dart';
import 'package:attandance_app/userPanel/user.dart';
import 'package:attandance_app/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If the user is logged in, fetch user data from Firestore
      final firebaseuser = user.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseuser)
          .get()
          .then((value) async {
        UserModel userModel =
            UserModel.fromMap(value.data() as Map<String, dynamic>);

        String role = userModel.category.toString();
        String name = userModel.fullName.toString();

        await HelperFunction.saveUserLoggedInStatus(true);
        await HelperFunction.saveUserEmail(user.email ?? '');
        await HelperFunction.saveUserNameSp(name);

        // Check if the user is an admin or student
        if (role == 'Admin') {
          nextScreenReplace(context, AdminPanel());
        } else {
          if (user.emailVerified) {
            nextScreenReplace(context, const UserPanel());
          } else {
            nextScreen(context, const UserPanel());
          }
        }
      });
    } else {
      // If the user is not logged in, navigate to the login screen
      nextScreenReplace(context, const LogInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
