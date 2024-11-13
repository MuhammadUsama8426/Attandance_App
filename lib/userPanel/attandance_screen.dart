// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Attendance_Screen extends StatelessWidget {
//   const Attendance_Screen({super.key});

//   // Function to confirm and mark attendance
//   Future<void> _markAttendance(BuildContext context) async {
//     final user = FirebaseAuth.instance.currentUser;
//     final today = DateTime.now();

//     // Truncate today's date to ignore time (set hours, minutes, seconds, and milliseconds to zero)
//     final todayDateOnly = DateTime(today.year, today.month, today.day);

//     if (user != null) {
//       try {
//         // Retrieve user details from Firestore
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (!userDoc.exists) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("User data not found!")),
//           );
//           return;
//         }

//         String userName = userDoc['fullName'] ?? 'No Name';

//         // Check if attendance for today already exists
//         final existingRecords = await FirebaseFirestore.instance
//             .collection('attendance')
//             .where('userId', isEqualTo: user.uid)
//             .where('date',
//                 isGreaterThanOrEqualTo: Timestamp.fromDate(todayDateOnly))
//             .where('date',
//                 isLessThan:
//                     Timestamp.fromDate(todayDateOnly.add(Duration(days: 1))))
//             .get();

//         if (existingRecords.docs.isNotEmpty) {
//           // Inform user if attendance is already marked
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text("Attendance already marked for today!")),
//           );
//         } else {
//           // Show dialog to confirm attendance marking
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 title: const Text("Mark Attendance"),
//                 content: const Text(
//                   "Are you sure you want to mark yourself as present today?",
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text("Cancel"),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 13, 237, 151),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () async {
//                       Navigator.of(context).pop();
//                       try {
//                         // Mark attendance as 'Present'
//                         await FirebaseFirestore.instance
//                             .collection('attendance')
//                             .add({
//                           'userId': user.uid,
//                           'name': userName,
//                           'date': Timestamp.fromDate(today),
//                           'status': 'Present',
//                         });

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text("Attendance marked as present!")),
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Error: $e")),
//                         );
//                       }
//                     },
//                     child: const Text("Confirm"),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error fetching user data: $e")),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User not authenticated")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 182, 230, 184),
//       appBar: AppBar(
//         title: const Text(
//           "Mark Attendance",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color.fromARGB(255, 195, 213, 244), Colors.blue],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//             backgroundColor: const Color.fromARGB(255, 190, 212, 229),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             elevation: 8,
//           ),
//           onPressed: () => _markAttendance(context),
//           child: const Text(
//             "Mark Present",
//             style: TextStyle(
//                 fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Attendance_Screen extends StatelessWidget {
  const Attendance_Screen({super.key});

  // Function to confirm and mark attendance
  Future<void> _markAttendance(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now();

    // Truncate today's date to ignore time (set hours, minutes, seconds, and milliseconds to zero)
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (user != null) {
      try {
        // Check if user is on leave for today
        final leaveRecords = await FirebaseFirestore.instance
            .collection('leave_requests')
            .where('userId', isEqualTo: user.uid)
            .where('startDate',
                isLessThanOrEqualTo: Timestamp.fromDate(todayDateOnly))
            .where('endDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(todayDateOnly))
            .get();

        if (leaveRecords.docs.isNotEmpty) {
          // User is on leave, show a message and return
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(" You are on leave today!")),
          );
          return;
        }

        // Retrieve user details from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found!")),
          );
          return;
        }

        String userName = userDoc['fullName'] ?? 'No Name';

        // Check if attendance for today already exists in 'daily_attendance'
        final existingRecords = await FirebaseFirestore.instance
            .collection('daily_attendance')
            .where('userId', isEqualTo: user.uid)
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(todayDateOnly))
            .where('date',
                isLessThan:
                    Timestamp.fromDate(todayDateOnly.add(Duration(days: 1))))
            .get();

        if (existingRecords.docs.isNotEmpty) {
          // Inform user if attendance is already marked
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Attendance already marked for today!")),
          );
        } else {
          // Show dialog to confirm attendance marking
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text("Mark Attendance"),
                content: const Text(
                  "Are you sure you want to mark yourself as present today?",
                  style: TextStyle(fontSize: 16),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 237, 151),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      try {
                        // Add or update attendance in 'attendance' collection
                        await FirebaseFirestore.instance
                            .collection('attendance')
                            .add({
                          'userId': user.uid,
                          'name': userName,
                          'date': Timestamp.fromDate(today),
                          'status': 'Present',
                        });

                        // Check if attendance record exists for today in 'daily_attendance'
                        final attendanceRecord = existingRecords.docs.isNotEmpty
                            ? existingRecords.docs.first
                            : null;

                        if (attendanceRecord != null) {
                          // If the record exists, update it with new data
                          await FirebaseFirestore.instance
                              .collection('daily_attendance')
                              .doc(attendanceRecord.id)
                              .update({
                            'status': 'Present',
                            'date': Timestamp.fromDate(today),
                          });
                        } else {
                          // If no record exists, add new data
                          await FirebaseFirestore.instance
                              .collection('daily_attendance')
                              .add({
                            'userId': user.uid,
                            'name': userName,
                            'date': Timestamp.fromDate(today),
                            'status': 'Present',
                          });
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Attendance marked as present!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    child: const Text("Confirm"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching user data: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 182, 230, 184),
      appBar: AppBar(
        title: const Text(
          "Mark Attendance",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 195, 213, 244), Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: const Color.fromARGB(255, 190, 212, 229),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          onPressed: () => _markAttendance(context),
          child: const Text(
            "Mark Present",
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
