import 'package:attandance_app/Auth/login_screen.dart';
import 'package:attandance_app/admin/attendance_summary_screen.dart';
import 'package:attandance_app/admin/exampl.dart';
import 'package:attandance_app/userPanel/User_profile/profile_screen.dart';
import 'package:attandance_app/userPanel/helper_function.dart';
import 'package:attandance_app/widget/Appcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'leave_approval_screen.dart';
import 'report_screen.dart';
import 'student_records_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Admin Panel",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 205, 208, 228),
                  Color.fromARGB(255, 116, 159, 197)
                ], // Indigo to Blue gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE3F2FD),
                Color(0xFFBBDEFB)
              ], // Light blue background gradient
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 25),
              _buildMenuButton(
                context,
                label: "Student Records",
                icon: Icons.school,
                color: const Color(0xFF5E35B1), // Deep purple
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentRecordsScreen()),
                ),
              ),
              _buildMenuButton(
                context,
                label: "Approve Leave Requests",
                icon: Icons.approval,
                color: const Color(0xFF3949AB), // Indigo accent
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LeaveApprovalScreen()),
                ),
              ),
              _buildMenuButton(
                context,
                label: "Attendance Summary",
                icon: Icons.calendar_today,
                color: const Color(0xFF039BE5), // Light blue
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendanceSummaryScreen()),
                ),
              ),
              _buildMenuButton(
                context,
                label: "Generate Reports",
                icon: Icons.analytics,
                color: const Color(0xFF00838F), // Teal
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginStudentScreen()),
                ),
              ),
              _buildMenuButton(
                context,
                label: "leave Reports",
                icon: Icons.analytics,
                color: const Color(0xFF00838F), // Teal
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentRecordsScreen2()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build styled menu buttons
  Widget _buildMenuButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: onTap,
      ),
    );
  }
}
