// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LeaveApprovalScreen extends StatefulWidget {
//   const LeaveApprovalScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _LeaveApprovalScreenState createState() => _LeaveApprovalScreenState();
// }

// class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> approveLeave(String documentId) async {
//     await _firestore.collection('leave_requests').doc(documentId).update({
//       'status': 'Approved',
//     });
//   }

//   Future<void> rejectLeave(String documentId) async {
//     await _firestore.collection('leave_requests').doc(documentId).update({
//       'status': 'Rejected',
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leave Approval'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('leave_requests').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No leave requests found.'));
//           }

//           return ListView(
//             children: snapshot.data!.docs.map((doc) {
//               var data = doc.data() as Map<String, dynamic>;
//               String name = data['name'] ?? 'Unknown';
//               String reason = data['reason'] ?? 'No reason provided';
//               String status = data['status'] ?? 'Pending';

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Name: $name',
//                         style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Reason: $reason',
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.black),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Status: $status',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: status == 'Approved'
//                               ? Colors.green
//                               : status == 'Rejected'
//                                   ? Colors.red
//                                   : Colors.orange,
//                         ),
//                       ),
//                       if (status == 'Pending') ...[
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             ElevatedButton(
//                               onPressed: () => approveLeave(doc.id),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green),
//                               child: const Text('Approve'),
//                             ),
//                             const SizedBox(width: 8),
//                             ElevatedButton(
//                               onPressed: () => rejectLeave(doc.id),
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red),
//                               child: const Text('Reject'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Don't forget to import the intl package for date formatting

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  _LeaveApprovalScreenState createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> approveLeave(String documentId) async {
    await _firestore.collection('leave_requests').doc(documentId).update({
      'status': 'Approved',
    });
  }

  Future<void> rejectLeave(String documentId) async {
    await _firestore.collection('leave_requests').doc(documentId).update({
      'status': 'Rejected',
    });
  }

  // Function to calculate the leave duration
  String calculateDuration(Timestamp? startDate, Timestamp? endDate) {
    if (startDate == null || endDate == null) {
      return 'Unknown duration'; // If either start or end date is null
    }

    final start = startDate.toDate();
    final end = endDate.toDate();
    final duration = end.difference(start).inDays + 1; // Duration in days
    return '$duration day(s)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Approval'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('leave_requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No leave requests found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String userId = data['userId'] ?? ''; // Get user ID
              String reason = data['reason'] ?? 'No reason provided';
              String status = data['status'] ?? 'Pending';
              Timestamp? startDate =
                  data['startDate']; // Assuming startDate is a Timestamp
              Timestamp? endDate =
                  data['endDate']; // Assuming endDate is a Timestamp
              Timestamp? applyDate =
                  data['date']; // Assuming applyDate is a Timestamp

              // Format the date and time
              String formattedApplyDate = applyDate != null
                  ? DateFormat('yyyy-MM-dd').format(applyDate.toDate())
                  : 'Unknown';
              String formattedApplyTime = applyDate != null
                  ? DateFormat('hh:mm a').format(applyDate.toDate())
                  : 'Unknown';

              // Fetch the user's name from the users collection
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  // Safely access user data with data() method
                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  if (userData == null) {
                    return const SizedBox.shrink();
                  }

                  String userName = userData['fullName'] ?? 'Unknown';

                  // Calculate the leave duration
                  String leaveDuration = calculateDuration(startDate, endDate);

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $userName',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reason: $reason',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Leave Apply Date: $formattedApplyDate',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            'Leave Apply Time: $formattedApplyTime',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Duration: $leaveDuration',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: $status',
                            style: TextStyle(
                              fontSize: 14,
                              color: status == 'Approved'
                                  ? Colors.green
                                  : status == 'Rejected'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                          if (status == 'Pending') ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => approveLeave(doc.id),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text('Approve'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => rejectLeave(doc.id),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text('Reject'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
