import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AssignmentTrackerScreen extends StatefulWidget {
  const AssignmentTrackerScreen({super.key});

  @override
  State<AssignmentTrackerScreen> createState() =>
      _AssignmentTrackerScreenState();
}

class _AssignmentTrackerScreenState extends State<AssignmentTrackerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCourse;
  String? _selectedProfessor;

  Future<List<Map<String, dynamic>>> _fetchCoursesAndProfessors() async {
    final snapshot = await _firestore.collection('courses').get();
    return snapshot.docs.map((doc) {
      return {
        'courseName': doc['courseName'],
        'professorName': doc['professorName'],
      };
    }).toList();
  }

  Future<void> _addOrEditAssignment(
      [Map<String, dynamic>? assignmentData]) async {
    final assignmentDetails =
        await _showAssignmentDialog(context, assignmentData);
    if (assignmentDetails != null) {
      if (assignmentData == null) {
        // Add a new assignment
        await _firestore.collection('assignments').add({
          'courseName': _selectedCourse,
          'professorName': _selectedProfessor,
          ...assignmentDetails,
        });
      } else {
        // Edit an existing assignment
        await _firestore
            .collection('assignments')
            .doc(assignmentData['id'])
            .update({
          'courseName': _selectedCourse,
          'professorName': _selectedProfessor,
          ...assignmentDetails,
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _showAssignmentDialog(BuildContext context,
      [Map<String, dynamic>? assignmentData]) async {
    final titleController =
        TextEditingController(text: assignmentData?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: assignmentData?['description'] ?? '');
    DateTime? selectedDate = assignmentData != null
        ? DateTime.parse(assignmentData['due_date'])
        : null;
    TimeOfDay? selectedTime = assignmentData != null
        ? _parseTimeOfDay(assignmentData['due_time'])
        : null;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            assignmentData == null ? 'Add Assignment' : 'Edit Assignment',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedTime != null
                        ? _formatTimeOfDay(selectedTime!)
                        : 'No Time Selected',
                  ),
                  decoration: InputDecoration(
                    labelText: 'Due Time',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                  ),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null) {
                  Navigator.of(context).pop({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'due_date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                    'due_time': _formatTimeOfDay(selectedTime!),
                  });
                }
              },
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        );
      },
    );
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  Widget _buildAssignmentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('assignments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final assignments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(assignment['title'],
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(
                  "${assignment['courseName']} - ${assignment['professorName']}\nDue: ${assignment['due_date']} at ${assignment['due_time']}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () {
                    _addOrEditAssignment({
                      ...assignment.data() as Map<String, dynamic>,
                      'id': assignment.id,
                    });
                  },
                ),
                onLongPress: () async {
                  // Delete assignment
                  await _firestore
                      .collection('assignments')
                      .doc(assignment.id)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Assignment deleted!")),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Assignment Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCoursesAndProfessors(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final courses = snapshot.data!;
                return DropdownButton<String>(
                  value: _selectedCourse,
                  hint: const Text("Select a Course"),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                      _selectedProfessor = courses.firstWhere((course) =>
                          course['courseName'] == value)['professorName'];
                    });
                  },
                  items: courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course['courseName'] as String,
                      child: Text(course['courseName'] as String),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            if (_selectedProfessor != null)
              Text("Professor: $_selectedProfessor",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _addOrEditAssignment(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text(
                'Add Assignment',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildAssignmentList()),
          ],
        ),
      ),
    );
  }
}
