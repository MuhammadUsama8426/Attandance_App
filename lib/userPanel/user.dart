// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:attandance_app/Auth/login_screen.dart';
import 'package:attandance_app/userPanel/User_profile/profile_screen.dart';
import 'package:attandance_app/userPanel/attandance_screen.dart';
import 'package:attandance_app/userPanel/helper_function.dart';
import 'package:attandance_app/userPanel/leave/leave_screen.dart';
import 'package:attandance_app/userPanel/view_attandance_screen.dart';
import 'package:attandance_app/widget/Appcolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserPanel extends StatefulWidget {
  const UserPanel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  // ignore: unused_field
  // ignore: unused_field
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _editProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    final user = _auth.currentUser;

    if (user != null && pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      String fileName = 'profile_images/${user.uid}.png';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(_profileImage!);

      String downloadUrl = await storageRef.getDownloadURL();
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );
    }
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(
              'specificUserId') // Replace 'specificUserId' with the actual document ID
          .get();

      if (snapshot.exists) {
        String name = snapshot.get('name'); // Retrieve the 'name' field
        String email = snapshot.get('email'); // Retrieve the 'email' field

        print('Name: $name');
        print('Email: $email');
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 3, 3, 3),
          iconTheme: const IconThemeData(
              color: Colors.white), // Set drawer icon color to white

          elevation: 0,
          title: Center(child: Text("Home Screen")),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        ),
        drawer: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          width: 255,
          child: ListView(
            children: [
              Container(
                color: AppColors.Appbacground,
                height: 150.0,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 130,
                        height: 130,
                        //child: Lottie.asset('assets/images/bus.json'),
                        child: Image.asset('assets/images/program.png'),
                      )
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: const Color.fromARGB(255, 241, 242, 243),
                thickness: 1,
              ),
              SizedBox(
                height: 12.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    "Profile",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // Show the logout confirmation dialog
                  bool confirmLogout = await showLogoutDialog(context);

                  // If the user confirmed logout, proceed with the sign-out logic
                  if (confirmLogout) {
                    // Sign out the user
                    firebaseAuth.signOut();

                    // Navigate to the login screen after logging out
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LogInScreen()),
                      (route) => false,
                    );
                  }
                },
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text(
                    "Logout",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            ],
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Button: Mark Attendance
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Attendance_Screen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Mark Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Button: Mark Leave
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeaveScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Mark Leave',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Button: View Attendance
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ViewAttendanceScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(200, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'View Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class AttendanceRecord {
  final DateTime date;
  final String status;

  AttendanceRecord({required this.date, required this.status});
}

class LeaveRequest {
  final String reason;

  LeaveRequest({required this.reason});
}
