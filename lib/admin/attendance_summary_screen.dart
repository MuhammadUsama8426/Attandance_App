// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AttendanceSummaryScreen extends StatefulWidget {
//   const AttendanceSummaryScreen({super.key});

//   @override
//   State<AttendanceSummaryScreen> createState() =>
//       _AttendanceSummaryScreenState();
// }

// class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Attendance Summary")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('attendance')
//             .where('userId',
//                 isEqualTo: _auth.currentUser?.uid) // Filter by user ID
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           var attendanceRecords = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: attendanceRecords.length,
//             itemBuilder: (context, index) {
//               var record = attendanceRecords[index];
//               String displayDate;

//               // Check if 'date' is a Firestore Timestamp
//               if (record['date'] is Timestamp) {
//                 displayDate = (record['date'] as Timestamp)
//                     .toDate()
//                     .toString()
//                     .split(' ')[0];
//               }
//               // Check if 'date' is a String
//               else if (record['date'] is String) {
//                 displayDate = record[
//                     'date']; // Assuming it's already in the desired format
//               } else {
//                 displayDate =
//                     "Invalid date format"; // Fallback for unexpected formats
//               }

//               return ListTile(
//                 title: Text("Date: $displayDate"),
//                 subtitle: Text("Status: ${record['status']}"),
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

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to delete all records
  Future<void> _clearAllRecords() async {
    try {
      var gradeRecords = await _firestore
          .collection('grades')
          .where(
            'studentId',
          )
          .get();

      if (gradeRecords.docs.isNotEmpty) {
        for (var record in gradeRecords.docs) {
          await _firestore.collection('grades').doc(record.id).delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All records deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records found to delete')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing records: $e')),
      );
    }
  }

  // Function to show delete confirmation dialog for deleting all records
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete all records?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllRecords();
              },
              child: const Text("Yes, Delete"),
            ),
          ],
        );
      },
    );
  }

  // Function to show delete confirmation dialog for a single record
  void _showDeleteConfirmationDialogForRecord(String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(recordId);
              },
              child: const Text("Yes, Delete"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a single record
  Future<void> _deleteRecord(String recordId) async {
    try {
      await _firestore.collection('grades').doc(recordId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Summary"),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('grades')
            .where(
              'studentId',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var gradeRecords = snapshot.data!.docs;

          if (gradeRecords.isEmpty) {
            return const Center(child: Text('No records found.'));
          }

          return ListView.builder(
            itemCount: gradeRecords.length,
            itemBuilder: (context, index) {
              var record = gradeRecords[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    title: Text(
                      "Student: ${record['studentName'] ?? 'N/A'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Grade: ${record['grade'] ?? 'N/A'}",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          "Attendance Percentage: ${record['attendancePercentage'] ?? '0'}%",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialogForRecord(record.id);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDeleteConfirmationDialog();
        },
        tooltip: 'Clear All Records',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.delete_forever),
      ),
    );
  }
}
