// import 'package:attandance_app/users/leave/view_leave_status_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class LeaveScreen extends StatefulWidget {
//   const LeaveScreen({super.key});

//   @override
//   _LeaveScreenState createState() => _LeaveScreenState();
// }

// class _LeaveScreenState extends State<LeaveScreen> {
//   DateTime? startDate;
//   DateTime? endDate;
//   String? reason;

//   Future<void> _selectStartDate(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: startDate ?? now,
//       firstDate: DateTime(now.year),
//       lastDate: DateTime(now.year + 1),
//     );
//     if (picked != null) {
//       setState(() {
//         startDate = picked;
//         // Reset endDate if it's before the new startDate
//         if (endDate != null && endDate!.isBefore(startDate!)) {
//           endDate = null;
//         }
//       });
//     }
//   }

//   Future<void> _selectEndDate(BuildContext context) async {
//     final now = DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: endDate ?? now,
//       firstDate: startDate ?? now,
//       lastDate: DateTime(now.year + 1),
//     );
//     if (picked != null) {
//       setState(() {
//         endDate = picked;
//       });
//     }
//   }

//   int _calculateDuration() {
//     if (startDate != null && endDate != null) {
//       return endDate!.difference(startDate!).inDays + 1;
//     }
//     return 0;
//   }

//   void _markLeave(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           title: const Text(
//             "Request Leave",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Leave Reason",
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.black54,
//                     fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 5),
//               TextField(
//                 style: const TextStyle(color: Colors.black),
//                 onChanged: (value) {
//                   reason = value;
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Enter reason for leave",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _dateButton("Start Date", startDate, _selectStartDate),
//                   _dateButton("End Date", endDate, _selectEndDate),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 (startDate != null && endDate != null)
//                     ? 'Duration: ${_calculateDuration()} day(s)'
//                     : 'Please select start and end dates.',
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             _dialogButton("Cancel", Colors.grey, () {
//               Navigator.of(context).pop();
//             }),
//             _dialogButton("Submit", Colors.blue, () async {
//               if (_isValidLeaveRequest()) {
//                 await _submitLeaveRequest();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Leave request submitted!")),
//                 );
//                 _resetForm();
//                 Navigator.of(context).pop();
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Please fill all fields correctly!')),
//                 );
//               }
//             }),
//           ],
//         );
//       },
//     );
//   }

//   bool _isValidLeaveRequest() {
//     return reason != null &&
//         reason!.isNotEmpty &&
//         startDate != null &&
//         endDate != null &&
//         _calculateDuration() > 0;
//   }

//   Future<void> _submitLeaveRequest() async {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       // Fetch user data from Firestore
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users') // Assuming your collection is named 'users'
//           .doc(user.uid)
//           .get();

//       // Extract the user's name from the document data
//       String fullName = userDoc.get('fullName') ?? 'No Name';

//       // Add the leave request to Firestore
//       await FirebaseFirestore.instance.collection('leave_requests').add({
//         'userId': user.uid,
//         'fullName': fullName,
//         'reason': reason,
//         'duration': _calculateDuration(),
//         'startDate': Timestamp.fromDate(startDate!),
//         'endDate': Timestamp.fromDate(endDate!),
//         'date': Timestamp.fromDate(DateTime.now()),
//         'status': 'Pending',
//       });
//     }
//   }

//   void _resetForm() {
//     setState(() {
//       startDate = null;
//       endDate = null;
//       reason = null;
//     });
//   }

//   Widget _dateButton(
//       String label, DateTime? date, Function(BuildContext) onTap) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         backgroundColor: Colors.blueGrey[50],
//         foregroundColor: Colors.black,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       onPressed: () => onTap(context),
//       child: Text(
//         date == null
//             ? label
//             : '$label: ${DateFormat('yyyy-MM-dd').format(date)}',
//         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//       ),
//     );
//   }

//   Widget _dialogButton(String label, Color color, VoidCallback onPressed) {
//     return TextButton(
//       style: TextButton.styleFrom(
//         foregroundColor: color,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         textStyle: const TextStyle(fontSize: 16),
//       ),
//       onPressed: onPressed,
//       child: Text(label),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Mark Leave"),
//         centerTitle: true,
//         backgroundColor: Colors.teal,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 onPressed: () => _markLeave(context),
//                 child: const Text(
//                   "Request Leave",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const LeaveStatusScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: const Text(
//                   'Status of Leave',
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:attandance_app/userPanel/leave/view_leave_status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? reason;

  // Function to check today's attendance status
  Future<bool> _checkTodayAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    final today = DateTime.now();

    // Truncate today's date to ignore time (set hours, minutes, seconds, and milliseconds to zero)
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (user == null) {
      // Handle case where user is not authenticated
      return false;
    }

    try {
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

      // If any records exist, attendance has already been marked
      return existingRecords.docs.isEmpty;
    } catch (e) {
      // Handle any errors that occur during Firestore operations
      print("Error checking attendance: $e");
      return false;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: now, // Restrict to today and future dates
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? now),
      firstDate: startDate ?? now, // Restrict to today and future dates
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  int _calculateDuration() {
    if (startDate != null && endDate != null) {
      return endDate!.difference(startDate!).inDays + 1;
    }
    return 0;
  }

  void _markLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Request Leave",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Leave Reason",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  reason = value;
                },
                decoration: InputDecoration(
                  hintText: "Enter reason for leave",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dateButton("Start Date", startDate, _selectStartDate),
                  _dateButton("End Date", endDate, _selectEndDate),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                (startDate != null && endDate != null)
                    ? 'Duration: ${_calculateDuration()} day(s)'
                    : 'Please select start and end dates.',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            _dialogButton("Cancel", Colors.grey, () {
              Navigator.of(context).pop();
            }),
            _dialogButton("Submit", Colors.blue, () async {
              if (_isValidLeaveRequest()) {
                await _submitLeaveRequest();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Leave request submitted!")),
                );
                _resetForm();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all fields correctly!')),
                );
              }
            }),
          ],
        );
      },
    );
  }

  bool _isValidLeaveRequest() {
    return reason != null &&
        reason!.isNotEmpty &&
        startDate != null &&
        endDate != null &&
        _calculateDuration() > 0;
  }

  Future<void> _submitLeaveRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String fullName = userDoc.get('fullName') ?? 'No Name';

      // Check for existing overlapping leave requests
      try {
        final existingLeaves = await FirebaseFirestore.instance
            .collection('leave_requests')
            .where('userId', isEqualTo: user.uid)
            .get();

        bool overlapExists = existingLeaves.docs.any((doc) {
          DateTime existingStart = (doc['startDate'] as Timestamp).toDate();
          DateTime existingEnd = (doc['endDate'] as Timestamp).toDate();

          // Check if the selected date range overlaps with an existing leave
          return !(endDate!.isBefore(existingStart) ||
              startDate!.isAfter(existingEnd));
        });

        if (overlapExists) {
          // Show an error message if there is an overlap
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leave already applied for the selected dates.'),
            ),
          );
          return;
        }

        // Submit the leave request if no overlap
        await FirebaseFirestore.instance.collection('leave_requests').add({
          'userId': user.uid,
          'fullName': fullName,
          'reason': reason,
          'duration': _calculateDuration(),
          'startDate': Timestamp.fromDate(startDate!),
          'endDate': Timestamp.fromDate(endDate!),
          'date': Timestamp.fromDate(DateTime.now()),
          'status': 'Pending',
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Leave request submitted!")),
        );
      } catch (e) {
        print("Error submitting leave request: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit leave request.")),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      startDate = null;
      endDate = null;
      reason = null;
    });
  }

  Widget _dateButton(
      String label, DateTime? date, Function(BuildContext) onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: Colors.blueGrey[50],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () => onTap(context),
      child: Text(
        date == null
            ? label
            : '$label: ${DateFormat('yyyy-MM-dd').format(date)}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _dialogButton(String label, Color color, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 16),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Leave"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  if (await _checkTodayAttendance()) {
                    // Allow leave application if today's attendance is not marked yet
                    _markLeave(context);
                  } else {
                    // Show message if attendance is already marked for today
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Today\'s attendance is already marked. Leave cannot be applied.'),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Request Leave",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LeaveStatusScreen()),
                  );
                },
                child: const Text(
                  "View Leave Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
