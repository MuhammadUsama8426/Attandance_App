// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LeaveStatusScreen extends StatelessWidget {
//   const LeaveStatusScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             "Status of Leave",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//           ),
//           centerTitle: true,
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blueAccent, Colors.blue], // Gradient background
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           elevation: 4,
//         ),
//         body: const Center(
//             child: Text("Please log in to view your leave status.")),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Status of Leave",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blueAccent, Colors.blue], // Gradient background
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         elevation: 4,
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
//             // Fetch leave request data
//             future: FirebaseFirestore.instance
//                 .collection('leave_requests')
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

//               final leaveRequests = snapshot.data?.docs ?? [];

//               if (leaveRequests.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     'No leave requests found.',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 );
//               }

//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: leaveRequests.length,
//                 itemBuilder: (context, index) {
//                   final data = leaveRequests[index];
//                   final date = (data['date'] as Timestamp).toDate();
//                   final status = data['status'] ?? 'Pending';

//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(20), // Rounded corners
//                     ),
//                     elevation: 6, // Added more elevation for a lifted look
//                     shadowColor:
//                         Colors.black.withOpacity(0.3), // Subtle shadow effect
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 20, horizontal: 16),
//                       title: Text(
//                         'Date: ${date.toLocal()}',
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 18),
//                       ),
//                       subtitle: Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Text(
//                           'Status: $status\nUser: $userName', // Display the user's name
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: status == 'Approved'
//                                 ? Colors.green
//                                 : Colors.red,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       trailing: Icon(
//                         status == 'Approved'
//                             ? Icons.check_circle
//                             : Icons.cancel,
//                         color: status == 'Approved' ? Colors.green : Colors.red,
//                         size: 30,
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

class LeaveStatusScreen extends StatelessWidget {
  const LeaveStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Status of Leave",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 4,
        ),
        body: const Center(
            child: Text("Please log in to view your leave status.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Status of Leave",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue], // Gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
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

          return FutureBuilder<QuerySnapshot>(
            // Fetch leave request data
            future: FirebaseFirestore.instance
                .collection('leave_requests')
                .where('userId', isEqualTo: user.uid)
                .orderBy('date', descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final leaveRequests = snapshot.data?.docs ?? [];

              if (leaveRequests.isEmpty) {
                return const Center(
                  child: Text(
                    'No leave requests found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaveRequests.length,
                itemBuilder: (context, index) {
                  final data = leaveRequests[index];
                  final date = (data['date'] as Timestamp).toDate();
                  final duration = data['duration'] ?? 0;
                  final reason = data['reason'] ?? 'No reason provided';
                  final status = data['status'] ?? 'Pending';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                    ),
                    elevation: 6, // Added more elevation for a lifted look
                    shadowColor:
                        Colors.black.withOpacity(0.3), // Subtle shadow effect
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      title: Text(
                        'Leave Date: ${date.toLocal()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Status: $status\nDuration: $duration days\nReason: $reason\nUser: $userName',
                          style: TextStyle(
                            fontSize: 16,
                            color: status == 'Approved'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        status == 'Approved'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: status == 'Approved' ? Colors.green : Colors.red,
                        size: 30,
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
