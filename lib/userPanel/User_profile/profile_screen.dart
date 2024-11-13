import 'package:attandance_app/Auth/login_screen.dart';
import 'package:attandance_app/userPanel/User_profile/update_profile.dart';
import 'package:attandance_app/widget/Appcolor.dart';
import 'package:attandance_app/widget/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Auth/services/auth_services.dart';
import 'helper_function.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthServices authServices = AuthServices();
  String userName = '';
  String userEmail = '';
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String id = FirebaseAuth.instance.currentUser!.uid;
  gettingUserData() async {
    await HelperFunction.getUserNameSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    await HelperFunction.getUserEmailSF().then((value) {
      setState(() {
        userEmail = value!;
      });
    });
  }

  // Fetch user scores from Firestore

  @override
  void initState() {
    gettingUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColors.Appbacground,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.camera_alt,
                  color: const Color(0xFFFF0000), size: 34.0),
              onPressed: () {
                nextScreen(
                  context,
                  UpdateProfile(),
                );
              }),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: id)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return SizedBox(
                  height: 400,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.network(
                          documentSnapshot['profilepic'],
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  "Name:",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15.0, color: Colors.black),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  documentSnapshot['fullName'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15.0, color: Colors.black),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Email:",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15.0, color: Colors.black),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  documentSnapshot['email'].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15.0, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: SizedBox(
                            width: 200,
                            child: Material(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.Appbacground,
                              child: MaterialButton(
                                onPressed: () async {
                                  firebaseAuth.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => LogInScreen()),
                                      (route) => false);
                                },
                                child: Center(
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
