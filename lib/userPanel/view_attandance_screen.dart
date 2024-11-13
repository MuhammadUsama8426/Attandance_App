// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ViewAttendanceScreen extends StatelessWidget {
//   const ViewAttendanceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Attendance History")),
//         body:
//             const Center(child: Text("Please log in to view your attendance.")),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Attendance"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         // Fetch user data to get the name
//         future:
//             FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
//         builder: (context, userSnapshot) {
//           if (userSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (userSnapshot.hasError) {
//             return Center(child: Text('Error: ${userSnapshot.error}'));
//           }

//           if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
//             return const Center(child: Text("User data not found."));
//           }

//           final userName = userSnapshot.data!['fullName'] ??
//               'User'; // Fetch name from the 'users' collection

//           return FutureBuilder<QuerySnapshot>(
//             // Fetch the attendance records
//             future: FirebaseFirestore.instance
//                 .collection('attendance')
//                 .where('userId', isEqualTo: user.uid)
//                 .orderBy('date', descending: true)
//                 .get(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }

//               final attendanceData = snapshot.data?.docs ?? [];

//               if (attendanceData.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     'No attendance records found.',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 );
//               }

//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: attendanceData.length,
//                 itemBuilder: (context, index) {
//                   final data = attendanceData[index];
//                   final date = (data['date'] as Timestamp).toDate();
//                   final status = data['status'] ?? 'Unknown';

//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     elevation: 5,
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.all(16),
//                       title: Text(
//                         'Date: ${date.toLocal()}',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       subtitle: Text(
//                         'Status: $status\nUser: $userName', // Display the user's name
//                         style: TextStyle(
//                           color:
//                               status == 'Present' ? Colors.green : Colors.red,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       trailing: Icon(
//                         status == 'Present' ? Icons.check_circle : Icons.cancel,
//                         color: status == 'Present' ? Colors.green : Colors.red,
//                         size: 28,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewAttendanceScreen extends StatelessWidget {
  const ViewAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Attendance History")),
        body:
            const Center(child: Text("Please log in to view your attendance.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Attendance"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Fetch user data to get the name
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          final userName = userSnapshot.data!['fullName'] ??
              'User'; // Fetch name from the 'users' collection

          return FutureBuilder<List<QuerySnapshot>>(
            // Fetch the attendance records and leave requests
            future: Future.wait([
              FirebaseFirestore.instance
                  .collection('attendance')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .get(),
              FirebaseFirestore.instance
                  .collection('leave_requests')
                  .where('userId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'Approved')
                  .orderBy('date', descending: true)
                  .get(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final attendanceData = snapshot.data?[0].docs ?? [];
              final leaveRequests = snapshot.data?[1].docs ?? [];

              if (attendanceData.isEmpty && leaveRequests.isEmpty) {
                return const Center(
                  child: Text(
                    'No attendance or approved leave records found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: attendanceData.length + leaveRequests.length,
                itemBuilder: (context, index) {
                  final isLeave = index >= attendanceData.length;
                  final data = isLeave
                      ? leaveRequests[index - attendanceData.length]
                      : attendanceData[index];

                  final date = (data['date'] as Timestamp).toDate();
                  final status = data['status'] ?? 'Unknown';

                  // For leave requests, calculate the duration
                  String leaveDuration = '';
                  if (isLeave) {
                    final startDate = (data['startDate'] as Timestamp).toDate();
                    final endDate = (data['endDate'] as Timestamp).toDate();
                    final duration = endDate.difference(startDate).inDays +
                        1; // Duration in days
                    leaveDuration = 'Duration: $duration day(s)';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Date: ${date.toLocal()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        isLeave
                            ? 'Leave Status: $status\nUser: $userName\n$leaveDuration'
                            : 'Attendance Status: $status\nUser: $userName',
                        style: TextStyle(
                          color: status == 'Approved'
                              ? Colors.green
                              : (status == 'Present'
                                  ? Colors.green
                                  : Colors.red),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        isLeave
                            ? (status == 'Approved'
                                ? Icons.check_circle
                                : Icons.cancel)
                            : (status == 'Present'
                                ? Icons.check_circle
                                : Icons.cancel),
                        color: status == 'Approved'
                            ? Colors.green
                            : (status == 'Present' ? Colors.green : Colors.red),
                        size: 28,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
