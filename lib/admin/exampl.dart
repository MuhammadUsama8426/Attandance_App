import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentRecordsScreen2 extends StatefulWidget {
  const StudentRecordsScreen2({super.key});

  @override
  _StudentRecordsScreen2State createState() => _StudentRecordsScreen2State();
}

class _StudentRecordsScreen2State extends State<StudentRecordsScreen2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Login Student  Records"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('users').snapshots(), // Fetching the students
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var students = snapshot.data!.docs;
          if (students.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView(
            children: students.map((users) {
              String studentName = users['fullName'] ?? 'No Name';
              String studentId = users.id;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    // Navigate to the attendance management screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaveRequestsScreen(
                          studentName: studentName,
                          studentId: studentId,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class LeaveRequestsScreen extends StatelessWidget {
  final String studentId;
  final String studentName;

  const LeaveRequestsScreen(
      {required this.studentId, required this.studentName, super.key});

  Future<List<Map<String, dynamic>>> _getApprovedLeaveRequests() async {
    try {
      QuerySnapshot leaveRequestsSnapshot = await FirebaseFirestore.instance
          .collection('leave_requests')
          .where('userId', isEqualTo: studentId)
          .where(
            'status',
          )
          .get();

      List<Map<String, dynamic>> approvedLeaveRequests =
          leaveRequestsSnapshot.docs.map((doc) {
        Timestamp startDate = doc['startDate'];
        Timestamp endDate = doc['endDate'];
        String reason = doc['reason'];
        String fullName = doc['fullName'];
        String formattedStartDate =
            DateFormat('yyyy-MM-dd').format(startDate.toDate());
        String formattedEndDate =
            DateFormat('yyyy-MM-dd').format(endDate.toDate());

        return {
          'fullName': fullName,
          'reason': reason,
          'startDate': formattedStartDate,
          'endDate': formattedEndDate,
          'status': doc['status'],
        };
      }).toList();

      return approvedLeaveRequests;
    } catch (e) {
      print("Error fetching leave requests: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$studentName's Approved Leave Requests"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getApprovedLeaveRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No approved leave requests found."));
          }

          List<Map<String, dynamic>> leaveRequests = snapshot.data!;

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> leaveRequest = leaveRequests[index];

              return Padding(
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    'Name: ${leaveRequest['fullName']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Start Date: ${leaveRequest['startDate']}\n'
                    'End Date: ${leaveRequest['endDate']}\n'
                    'Reason: ${leaveRequest['reason']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
