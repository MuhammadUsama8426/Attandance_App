import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false, // Prevents dismissing by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15), // Rounded corners for the dialog
            ),
            title: Column(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.red, // Logout icon color
                  size: 30,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            content: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            actions: <Widget>[
              // Cancel button with styling
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false (cancel)
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Logout button with styling
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Return true (confirmed logout)
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red, // Logout button background color
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Rounded corners for the button
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ) ??
      false; // Default to false if dialog is dismissed without selection
}


// FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;



//  final List<AttendanceRecord> _attendanceRecords = [];
//   // ignore: unused_field
//   final List<LeaveRequest> _leaveRequests = [];
//   File? _profileImage;
//   final ImagePicker _picker = ImagePicker();
//   // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   void _markAttendance(BuildContext context) async {
//     final today = DateTime.now();
//     final user = _auth.currentUser;

//     if (user != null) {
//       // Check if attendance is already marked for today
//       final existingRecords = await _firestore
//           .collection('attendance')
//           .where('userId', isEqualTo: user.uid)
//           .where('date', isEqualTo: today)
//           .get();

//       if (existingRecords.docs.isNotEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Attendance already marked for today!")),
//         );
//       } else {
//         await _firestore.collection('attendance').add({
//           'userId': user.uid,
//           'name': user.displayName ?? 'No Name', // Save user's name
//           'date': Timestamp.fromDate(today), // Save as Timestamp
//           'status': 'Present',
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Attendance marked as present!")),
//         );
//       }
//     }
//   }

//   void _markLeave(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         String? reason;
//         return AlertDialog(
//           title: const Text(
//             "Mark Leave",
//             style: TextStyle(color: Colors.black),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 style: const TextStyle(color: Colors.black),
//                 onChanged: (value) {
//                   reason = value;
//                 },
//                 decoration:
//                     const InputDecoration(hintText: "Enter leave reason"),
//               ),
//               TextField(
//                 style: const TextStyle(color: Colors.black),
//                 onChanged: (value) {
//                   // You can implement duration input if needed
//                 },
//                 decoration:
//                     const InputDecoration(hintText: "Enter duration (days)"),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text("Submit"),
//               onPressed: () async {
//                 final user = _auth.currentUser;
//                 if (user != null && reason != null && reason!.isNotEmpty) {
//                   await _firestore.collection('leave_requests').add({
//                     'userId': user.uid,
//                     'name': user.displayName ?? 'No Name', // Save user's name
//                     'reason': reason,
//                     'date': DateTime.now(),
//                   });

//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Leave request submitted!")),
//                   );
//                 }
//               },
//             ),
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _viewAttendance(BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const AttendanceSummaryScreen(),
//       ),
//     );
//   }