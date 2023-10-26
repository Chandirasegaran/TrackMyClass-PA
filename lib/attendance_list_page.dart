import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class AttendanceListPage extends StatelessWidget {
  final DateTime selectedDate;
  final String className;

  AttendanceListPage({
    required this.selectedDate,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance for $className on ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
        ),
      ),
      body: FutureBuilder<List<ScannedData>>(
        future: DatabaseHelper().getAttendanceForDate(selectedDate, className),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final attendanceList = snapshot.data;
            if (attendanceList != null && attendanceList.isNotEmpty) {
              return ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  final entry = attendanceList[index];
                  return ListTile(
                    title: Text('Register Number: ${entry.registerNumber}'),
                    // subtitle: Text('Name: ${entry.name}'),
                    // Add more information as needed
                  );
                },
              );
            } else {
              return Center(
                child:
                    Text('No attendance entries found for the selected date.'),
              );
            }
          }
        },
      ),
    );
  }
}
