import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';

class AssignmentTrackerScreen extends StatefulWidget {
  const AssignmentTrackerScreen({super.key});

  @override
  AssignmentTrackerScreenState createState() => AssignmentTrackerScreenState();
}

class AssignmentTrackerScreenState extends State<AssignmentTrackerScreen> {
  final DBHelper _dbHelper = DBHelper.instance;
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final data = await _dbHelper.getAssignments();
    setState(() {
      _assignments = data;
    });
  }

  Future<void> _addAssignment(BuildContext context) async {
    final result = await _showAssignmentDialog(context);
    if (result != null) {
      await _dbHelper.addAssignment(result);
      _loadAssignments();
    }
  }

  Future<void> _editAssignment(
      BuildContext context, Map<String, dynamic> assignment) async {
    final result = await _showAssignmentDialog(context, assignment);
    if (result != null) {
      await _dbHelper.updateAssignment(assignment['id'], result);
      _loadAssignments();
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
          title: Text(
              assignmentData == null ? 'Add Assignment' : 'Edit Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                  ),
                  decoration: const InputDecoration(labelText: 'Due Date'),
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
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedTime != null
                        ? _formatTimeOfDay(selectedTime!)
                        : 'No Time Selected',
                  ),
                  decoration: const InputDecoration(labelText: 'Due Time'),
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
                child: const Text('Cancel')),
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
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleCompletion(int id, int isCompleted) async {
    await _dbHelper.updateAssignmentCompletion(id, isCompleted == 0 ? 1 : 0);
    _loadAssignments();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat.jm().format(formattedTime); // Converts to hh:mm AM/PM
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final format = DateFormat.jm(); // Parses hh:mm AM/PM
    final DateTime parsedTime = format.parse(time);
    return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Tracker'),
      ),
      body: _assignments.isEmpty
          ? const Center(child: Text('No assignments yet'))
          : ListView.builder(
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                return ListTile(
                  title: Text(assignment['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due Date: ${assignment['due_date']}'),
                      Text('Due Time: ${assignment['due_time']}'),
                      Text('Description: ${assignment['description']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          assignment['is_completed'] == 1
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: assignment['is_completed'] == 1
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () => _toggleCompletion(
                            assignment['id'], assignment['is_completed']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editAssignment(context, assignment),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _dbHelper.deleteAssignment(assignment['id']);
                          _loadAssignments();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAssignment(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
