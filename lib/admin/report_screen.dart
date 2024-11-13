// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class LoginStudentScreen extends StatefulWidget {
//   const LoginStudentScreen({super.key});

//   @override
//   _LoginStudentScreenState createState() => _LoginStudentScreenState();
// }

// class _LoginStudentScreenState extends State<LoginStudentScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Login Students"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           var students = snapshot.data!.docs;
//           if (students.isEmpty) {
//             return const Center(child: Text('No students found.'));
//           }

//           return ListView(
//             children: students.map((users) {
//               String studentName = users['fullName'] ?? 'No Name';
//               String studentId = users.id;

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.all(16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 4,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ReportScreen(
//                           studentName: studentName,
//                           studentId: studentId,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     studentName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
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
import 'package:intl/intl.dart';

class LoginStudentScreen extends StatefulWidget {
  const LoginStudentScreen({super.key});

  @override
  _LoginStudentScreenState createState() => _LoginStudentScreenState();
}

class _LoginStudentScreenState extends State<LoginStudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> _calculateAllStudentGrades(
      DateTime fromDate, DateTime toDate) async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot userSnapshot = await _firestore.collection('users').get();
      List<QueryDocumentSnapshot> users = userSnapshot.docs;

      for (var user in users) {
        String studentId = user.id;
        String studentName = user['fullName'] ?? 'No Name';

        try {
          QuerySnapshot attendanceSnapshot = await _firestore
              .collection('attendance')
              .where('userId', isEqualTo: studentId)
              .where('date', isGreaterThanOrEqualTo: fromDate)
              .where('date', isLessThanOrEqualTo: toDate)
              .get();

          List<Map<String, dynamic>> attendanceRecords =
              attendanceSnapshot.docs.map((doc) {
            String status = doc['status'];
            return {'status': status};
          }).toList();

          int totalDays = attendanceRecords.length;
          int presentDays = attendanceRecords
              .where((record) => record['status'] == 'Present')
              .length;
          double attendancePercentage =
              (totalDays == 0) ? 0 : (presentDays / totalDays) * 100;

          String grade;
          if (attendancePercentage >= 90) {
            grade = 'A';
          } else if (attendancePercentage >= 75) {
            grade = 'B';
          } else if (attendancePercentage >= 50) {
            grade = 'C';
          } else {
            grade = 'D';
          }

          await _firestore.collection('grades').add({
            'studentId': studentId,
            'studentName': studentName,
            'grade': grade,
            'attendancePercentage': attendancePercentage,
            'fromDate': fromDate,
            'toDate': toDate,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print("Error calculating grade for student $studentName: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Grades have been calculated for the selected date range!")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      _fromDate = pickedRange.start;
      _toDate = pickedRange.end;

      _calculateAllStudentGrades(_fromDate!, _toDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Students"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportScreen(
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectDateRange,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.date_range),
        label: const Text('Calculate Student Grades'),
      ),
    );
  }
}

class ReportScreen extends StatefulWidget {
  final String studentName;
  final String studentId;

  const ReportScreen({
    required this.studentName,
    required this.studentId,
    super.key,
  });

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _calculateGrade(double attendancePercentage) {
    if (attendancePercentage >= 90) {
      return 'A';
    } else if (attendancePercentage >= 75) {
      return 'B';
    } else if (attendancePercentage >= 50) {
      return 'C';
    } else {
      return 'D';
    }
  }

  Future<List<Map<String, dynamic>>> _getStudentAttendance(
      String studentId) async {
    try {
      QuerySnapshot attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: studentId)
          .get();

      List<Map<String, dynamic>> attendanceRecords =
          attendanceSnapshot.docs.map((doc) {
        Timestamp dateTimestamp = doc['date'];
        String status = doc['status'];
        String name = doc['name'] ?? 'No Name';
        String formattedDate =
            DateFormat('yyyy-MM-dd').format(dateTimestamp.toDate());

        return {
          'name': name,
          'status': status,
          'date': formattedDate,
          'docId': doc.id,
        };
      }).toList();

      // Calculate attendance percentage and grade
      int totalDays = attendanceRecords.length;
      int presentDays = attendanceRecords
          .where((record) => record['status'] == 'Present')
          .toList()
          .length;

      double attendancePercentage =
          (totalDays == 0) ? 0 : (presentDays / totalDays) * 100;

      String grade = _calculateGrade(attendancePercentage);

      // Store the grade in Firestore
      await _firestore.collection('grades').add({
        'studentId': widget.studentId,
        'studentName': widget.studentName,
        'grade': grade,
        'attendancePercentage': attendancePercentage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add grade to the list of attendance records
      return [
        ...attendanceRecords,
        {
          'grade': grade,
          'attendancePercentage': attendancePercentage,
        },
      ];
    } catch (e) {
      print("Error fetching attendance: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.studentName}'s Attendance"),
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

          List<Map<String, dynamic>> attendanceRecords = snapshot.data!;
          String grade = attendanceRecords.last['grade'] ?? 'N/A';
          double attendancePercentage =
              attendanceRecords.last['attendancePercentage'] ?? 0;

          return Column(
            children: [
              // Display the student's attendance grade and percentage
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Attendance Grade: $grade\nAttendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView(
                  children: attendanceRecords
                      .take(
                          attendanceRecords.length - 1) // Exclude grade record
                      .map((record) {
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



  // DateTime? _fromDate;
  // DateTime? _toDate;
  // Map<String, double> attendanceCount = {'Present': 0, 'Absent': 0, 'Leave': 0};
  // String grade = '';

  // Future<void> _generateReport(BuildContext context) async {
  //   if (_fromDate == null || _toDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please select both dates")),
  //     );
  //     return;
  //   }
  //   Timestamp fromTimestamp = Timestamp.fromDate(_fromDate!);
  //   Timestamp toTimestamp = Timestamp.fromDate(_toDate!);

  //   QuerySnapshot attendanceRecords = await _firestore
  //       .collection('attendance')
  //       .where('userId', isEqualTo: widget.studentId)
  //       .where('date',
  //           isGreaterThanOrEqualTo: fromTimestamp) // Use fromTimestamp
  //       .where('date', isLessThanOrEqualTo: toTimestamp) // Use toTimestamp
  //       .get();

  //   attendanceCount = {'Present': 0, 'Absent': 0, 'Leave': 0};
  //   print("From Date: $_fromDate, To Date: $_toDate");
  //   print("Found ${attendanceRecords.docs.length} attendance records");

  //   for (var record in attendanceRecords.docs) {
  //     String status = record['status']; // Default to 'Absent' if status is null
  //     print("Record status: $status");

  //     if (attendanceCount.containsKey(status)) {
  //       attendanceCount[status] = attendanceCount[status]! + 1;
  //     }
  //   }

  //   double presentCount = attendanceCount['Present'] ?? 0;
  //   grade = _calculateGrade(presentCount);

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Attendance Report for ${widget.studentName}",
  //           style: const TextStyle(color: Colors.black)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text("Present: ${attendanceCount['Present']}",
  //               style: const TextStyle(color: Colors.black)),
  //           Text("Absent: ${attendanceCount['Absent']}",
  //               style: const TextStyle(color: Colors.black)),
  //           Text("Leave: ${attendanceCount['Leave']}",
  //               style: const TextStyle(color: Colors.black)),
  //           const SizedBox(height: 10),
  //           Text("Grade: $grade",
  //               style: const TextStyle(
  //                   color: Colors.black, fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Close"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

//  Future<List<Map<String, dynamic>>> _getStudentAttendance(
//       String studentId) async {
//     try {
//       QuerySnapshot attendanceSnapshot = await _firestore
//           .collection('attendance')
//           .where('userId', isEqualTo: studentId)
//           .get();

//       List<Map<String, dynamic>> attendanceRecords =
//           attendanceSnapshot.docs.map((doc) {
//         Timestamp dateTimestamp = doc['date'];
//         String status = doc['status'];
//         String name = doc['name'] ?? 'No Name';
//         String formattedDate =
//             DateFormat('yyyy-MM-dd').format(dateTimestamp.toDate());

//         return {
//           'name': name,
//           'status': status,
//           'date': formattedDate,
//           'docId': doc.id,
//         };
//       }).toList();

//       // Calculate attendance percentage and grade
//       int totalDays = attendanceRecords.length;
//       int presentDays = attendanceRecords
//           .where((record) => record['status'] == 'Present')
//           .toList()
//           .length;

//       double attendancePercentage =
//           (totalDays == 0) ? 0 : (presentDays / totalDays) * 100;

//       String grade = _calculateGrade(attendancePercentage);

//       // Add grade to the list of attendance records (this could be shown to the user)
//       return [
//         ...attendanceRecords,
//         {
//           'grade': grade,
//           'attendancePercentage': attendancePercentage,
//         },
//       ];
//     } catch (e) {
//       print("Error fetching attendance: $e");
//       return [];
//     }
//   }

  // String _calculateGrade(double presentDays) {
  //   if (presentDays >= 26) {
  //     return "A";
  //   } else if (presentDays >= 20) {
  //     return "B";
  //   } else if (presentDays >= 15) {
  //     return "C";
  //   } else if (presentDays >= 1) {
  //     return "D";
  //   } else {
  //     return "F"; // Return F if no present days
  //   }
  // }

  // Future<void> _selectFromDate(BuildContext context) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _fromDate = picked;
  //     });

  //     // If From Date is after To Date, reset To Date to null or show error
  //     if (_toDate != null && _fromDate!.isAfter(_toDate!)) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //             content: Text("From date cannot be later than To date")),
  //       );
  //       setState(() {
  //         _toDate = null; // Optional: reset To Date if invalid
  //       });
  //     }
  //   }
  // }

  // Future<void> _selectToDate(BuildContext context) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate:
  //         _fromDate ?? DateTime(2020), // Ensure To Date is after From Date
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _toDate = picked;
  //     });

  //     // If To Date is before From Date, show an error
  //     if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("To date cannot be before From date")),
  //       );
  //       setState(() {
  //         _toDate = null; // Optional: reset To Date if invalid
  //       });
  //     }
  //   }
  // }

  // String _formatDate(DateTime date) {
  //   // Use the intl package to format the date
  //   return DateFormat('dd-MM-yyyy').format(date);
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Generate Report")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ListTile(
  //             title: const Text("Select From Date",
  //                 style: TextStyle(color: Colors.black)),
  //             subtitle: Text(
  //               _fromDate == null ? "Not selected" : _formatDate(_fromDate!),
  //               style: const TextStyle(color: Colors.black54),
  //             ),
  //             onTap: () => _selectFromDate(context),
  //           ),
  //           ListTile(
  //             title: const Text("Select To Date",
  //                 style: TextStyle(color: Colors.black)),
  //             subtitle: Text(
  //               _toDate == null ? "Not selected" : _formatDate(_toDate!),
  //               style: const TextStyle(color: Colors.black54),
  //             ),
  //             onTap: () => _selectToDate(context),
  //           ),
  //           const SizedBox(height: 20),
  //           Center(
  //             child: ElevatedButton(
  //               onPressed: () => _generateReport(context),
  //               child: const Text("Generate Report",
  //                   style: TextStyle(color: Colors.black)),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // Function to calculate the grade based on attendance percentage
 





















// class ReportScreen extends StatefulWidget {
//   final String studentName;
//   final String studentId;
//   // const ReportScreen({super.key});
//   const ReportScreen({
//     required this.studentName,
//     required this.studentId,
//     super.key,
//   });
//   @override
//   // ignore: library_private_types_in_public_api
//   _ReportScreenState createState() => _ReportScreenState();
// }

// class _ReportScreenState extends State<ReportScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   DateTime? _fromDate;
//   DateTime? _toDate;

//   Future<void> _generateReport(BuildContext context) async {
//     if (_fromDate == null || _toDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select both dates")),
//       );
//       return;
//     }

//     QuerySnapshot attendanceRecords = await _firestore
//         .collection('attendance')
//         .where('date', isGreaterThanOrEqualTo: _fromDate)
//         .where('date', isLessThanOrEqualTo: _toDate)
//         .get();

//     showDialog(
//       // ignore: use_build_context_synchronously
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Attendance Report",
//             style: TextStyle(color: Colors.black)),
//         content: ListView.builder(
//           shrinkWrap: true,
//           itemCount: attendanceRecords.docs.length,
//           itemBuilder: (context, index) {
//             var record = attendanceRecords.docs[index];
//             return ListTile(
//               title: Text("Date: ${record['date'].toDate()}",
//                   style: const TextStyle(color: Colors.black)),
//               subtitle: Text("Status: ${record['status']}",
//                   style: const TextStyle(color: Colors.black)),
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectFromDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _fromDate = picked;
//       });
//     }
//   }

//   Future<void> _selectToDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _toDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Generate Report")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ListTile(
//               title: const Text("Select From Date",
//                   style: TextStyle(color: Colors.black)),
//               subtitle: Text(
//                 _fromDate == null
//                     ? "Not selected"
//                     : "${_fromDate!.toLocal()}".split(' ')[0],
//                 style: const TextStyle(color: Colors.black54),
//               ),
//               onTap: () => _selectFromDate(context),
//             ),
//             ListTile(
//               title: const Text("Select To Date",
//                   style: TextStyle(color: Colors.black)),
//               subtitle: Text(
//                 _toDate == null
//                     ? "Not selected"
//                     : "${_toDate!.toLocal()}".split(' ')[0],
//                 style: const TextStyle(color: Colors.black54),
//               ),
//               onTap: () => _selectToDate(context),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () => _generateReport(context),
//                 child: const Text("Generate Report",
//                     style: TextStyle(color: Colors.black)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
