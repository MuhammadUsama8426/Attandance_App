import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentRecordsScreen extends StatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  _StudentRecordsScreenState createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
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
                        builder: (context) => AttendanceManagementScreen(
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

class AttendanceManagementScreen extends StatefulWidget {
  final String studentName;
  final String studentId;

  const AttendanceManagementScreen({
    required this.studentName,
    required this.studentId,
    super.key,
  });

  @override
  _AttendanceManagementScreenState createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _editStudentRecord(
      BuildContext context, DocumentSnapshot student) async {
    String newName = student['fullName'] ?? 'No Name';
    String newStatus = student['status'] ?? 'No Status';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => newName = value,
              controller: TextEditingController(text: student['fullName']),
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              onChanged: (value) => newStatus = value,
              controller: TextEditingController(text: student['status']),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('attendance').doc(student.id).update({
                'fullName': newName,
                'status': newStatus,
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudentRecord(
      BuildContext context, String studentId) async {
    await _firestore.collection('attendance').doc(studentId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student record deleted')),
    );
  }

  void _markAttendance(String studentId, String status) async {
    try {
      // Get today's date in the format 'yyyy-MM-dd' to use as a unique key for daily attendance
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Check if the student has submitted a leave request for today
      DocumentSnapshot leaveRequestSnapshot = await _firestore
          .collection('leave_requests')
          .doc(
              '$studentId-$todayDate') // Unique document ID for each student per day
          .get();

      if (leaveRequestSnapshot.exists) {
        String leaveStatus = leaveRequestSnapshot['status'] ?? 'Pending';

        // Show different messages based on leave status
        if (leaveStatus == 'Pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave request is pending for today')),
          );
          return;
        } else if (leaveStatus == 'Approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Leave request is approved for today')),
          );
          return;
        } else if (leaveStatus == 'Rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Leave request is rejected for today. Marking as absent is allowed.')),
          );
          // Allow marking as absent if status is 'rejected' (continue to the next check)
        }
      }

      // Check if attendance has already been marked for this student today
      DocumentSnapshot dailyAttendanceSnapshot = await _firestore
          .collection('daily_attendance')
          .doc('$studentId-$todayDate')
          .get();

      if (dailyAttendanceSnapshot.exists) {
        // If an attendance record exists for today, notify admin that attendance is already marked
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance already marked for today')),
        );
        return;
      }

      // Fetch student name from 'users' collection using studentId
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(studentId).get();

      if (userSnapshot.exists) {
        String studentName = userSnapshot['fullName'] ?? 'Unknown';

        // Add attendance record to Firestore in both collections
        await _firestore.collection('attendance').add({
          'userId': studentId,
          'name': studentName,
          'status': status,
          'date': Timestamp.now(),
        });

        // Also add to daily_attendance collection with a document ID for today
        await _firestore
            .collection('daily_attendance')
            .doc('$studentId-$todayDate')
            .set({
          'userId': studentId,
          'name': studentName,
          'status': status,
          'date': todayDate,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Attendance marked as $status for $studentName')),
        );

        setState(() {}); // Refresh the screen after marking attendance
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student not found')),
        );
      }
    } catch (e) {
      print("Error marking attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error marking attendance')),
      );
    }
  }

  // Function to edit attendance record
  void _editAttendance(String docId, String currentStatus) async {
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Attendance Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Present'),
              leading: Radio<String>(
                value: 'Present',
                groupValue: currentStatus,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
            ),
            ListTile(
              title: const Text('Absent'),
              leading: Radio<String>(
                value: 'Absent',
                groupValue: currentStatus,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (newStatus != null && newStatus != currentStatus) {
      try {
        // Update attendance record in Firestore
        await _firestore.collection('attendance').doc(docId).update({
          'status': newStatus,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
        setState(() {}); // Refresh the screen after editing attendance
      } catch (e) {
        print("Error updating attendance: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update record')),
        );
      }
    }
  }

  // Function to get the attendance records for a student
  Future<List<Map<String, dynamic>>> _getStudentAttendance(
      String studentId) async {
    try {
      // Fetch attendance records for the student
      QuerySnapshot attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: studentId)
          .get();

      // Fetch approved leave requests for the student
      QuerySnapshot leaveRequestsSnapshot = await _firestore
          .collection('leave_requests')
          .where('userId', isEqualTo: studentId)
          .where(
            'status',
            isEqualTo: 'Approved',
          ) // Filter for approved leaves
          .get();

      // Convert each attendance record to a map with name, status, date, and docId
      List<Map<String, dynamic>> attendanceRecords =
          attendanceSnapshot.docs.map((doc) {
        Timestamp dateTimestamp = doc['date'];
        String status = doc['status'];

        String name = doc['name'] ?? 'No Name'; // Fetch name from the document
        String formattedDate =
            DateFormat('yyyy-MM-dd').format(dateTimestamp.toDate());

        return {
          'name': name,
          'status': status,
          'date': formattedDate,
          'docId': doc.id, // Store the document ID
          'type': 'attendance', // Type to distinguish records
        };
      }).toList();

      // Convert each approved leave request to a map with relevant fields
      List<Map<String, dynamic>> leaveRequests =
          leaveRequestsSnapshot.docs.map((doc) {
        Timestamp startDate = doc['startDate'];
        Timestamp endDate = doc['endDate'];
        String reason = doc['reason'];
        String fullName = doc['fullName'];
        String status = doc['status'];

        String formattedStartDate =
            DateFormat('yyyy-MM-dd').format(startDate.toDate());
        String formattedEndDate =
            DateFormat('yyyy-MM-dd').format(endDate.toDate());

        return {
          'fullName': fullName,
          'reason': reason,
          'startDate': formattedStartDate,
          'endDate': formattedEndDate,
          'status': status,
          'docId': doc.id, // Store the document ID
          'type': 'leave', // Type to distinguish records
        };
      }).toList();

      // Combine the attendance and leave records into one list
      List<Map<String, dynamic>> allRecords = [
        ...attendanceRecords,
        ...leaveRequests,
      ];

      // Sort the combined records by date (most recent first)
      allRecords.sort((a, b) {
        DateTime dateA =
            DateFormat('yyyy-MM-dd').parse(a['date'] ?? a['startDate']);
        DateTime dateB =
            DateFormat('yyyy-MM-dd').parse(b['date'] ?? b['startDate']);
        return dateB.compareTo(dateA);
      });

      return allRecords;
    } catch (e) {
      print("Error fetching records: $e");
      return [];
    }
  }

  // Function to mark attendance as Present/Absent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.studentName}'s Attendance & Leave Requests"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStudentAttendance(widget.studentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // List<Map<String, dynamic>> records = snapshot.data!;
          List<Map<String, dynamic>> records = snapshot.data ?? [];

          // Separate attendance and leave records
          List<Map<String, dynamic>> attendanceRecords = records
              .where((record) => record['type'] == 'attendance')
              .toList();
          List<Map<String, dynamic>> leaveRequests =
              records.where((record) => record['type'] == 'leave').toList();

          return Column(
            children: [
              // Attendance Records List
              Expanded(
                child: ListView(
                  children: attendanceRecords.map((record) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        tileColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          'Name: ${record['name']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Date: ${record['date']} - Status: ${record['status']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: record['status'] == 'Present'
                                ? Colors.green
                                : record['status'] == 'Absent'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blueAccent,
                              onPressed: () => _editAttendance(
                                  record['docId'], record['status']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.redAccent,
                              onPressed: () async {
                                try {
                                  await _firestore
                                      .collection('attendance')
                                      .doc(record['docId'])
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Record deleted')),
                                  );
                                  setState(() {});
                                } catch (e) {
                                  print("Error deleting record: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Failed to delete record')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Leave Requests List
              Expanded(
                child: ListView(
                  children: leaveRequests.map((record) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        tileColor: Colors
                            .orange[100], // Different color for leave requests
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          'Leave Request - ${record['status']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Full Name: ${record['fullName']} - Reason: ${record['reason']} \n Start Date: ${record['startDate']} - End Date: ${record['endDate']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: record['status'] == 'approved'
                                ? Colors.green
                                : record['status'] == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.redAccent,
                          onPressed: () async {
                            try {
                              await _firestore
                                  .collection('leave_requests')
                                  .doc(record['docId'])
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Leave request deleted')),
                              );
                              setState(() {});
                            } catch (e) {
                              print("Error deleting leave request: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Failed to delete leave request')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Attendance & Leave Action Buttons
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            _markAttendance(widget.studentId, 'Present'),
                        child: const Text(
                          'Mark Present',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            _markAttendance(widget.studentId, 'Absent'),
                        child: const Text(
                          'Mark Absent',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _markAttendance(widget.studentId, 'Leave'),
                    child: const Text(
                      'Mark Leave',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
