import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and times
import 'db_helper.dart';

class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  ClassScheduleScreenState createState() => ClassScheduleScreenState();
}

class ClassScheduleScreenState extends State<ClassScheduleScreen> {
  final DBHelper _dbHelper = DBHelper.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadClasses();
  }

  Future<void> _initializeNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message);
      });
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _handleNotificationClick(RemoteMessage message) {
    // Handle notification click
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      platformDetails,
    );
  }

  Future<void> _loadClasses() async {
    final data = await _dbHelper.getClasses();
    setState(() {
      _classes = data;
    });
  }

  Future<void> _addClass(BuildContext context) async {
    final result = await _showClassDialog(context);
    if (result != null) {
      await _dbHelper.addClassRecord(result);
      _loadClasses();
    }
  }

  Future<void> _editClass(
      BuildContext context, Map<String, dynamic> classItem) async {
    final result = await _showClassDialog(context, classItem);
    if (result != null) {
      await _dbHelper.updateClass(classItem['id'], result);
      _loadClasses();
    }
  }

  Future<Map<String, dynamic>?> _showClassDialog(BuildContext context,
      [Map<String, dynamic>? classData]) async {
    final titleController =
        TextEditingController(text: classData?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: classData?['description'] ?? '');
    DateTime? selectedDate =
        classData != null ? DateTime.parse(classData['date']) : null;
    TimeOfDay? selectedTime = classData != null
        ? TimeOfDay(
            hour: int.parse(classData['time'].split(":")[0]),
            minute: int.parse(classData['time'].split(":")[1].split(" ")[0]),
          )
        : null;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            classData == null ? 'Add Class' : 'Edit Class',
            style: TextStyle(color: Colors.indigo),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                        : '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedTime?.format(context) ?? '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null) {
                  Navigator.of(context).pop({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                    'time': selectedTime!.format(context),
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title:
            const Text('Class Schedule', style: TextStyle(color: Colors.white)),
      ),
      body: _classes.isEmpty
          ? const Center(
              child: Text('No classes yet',
                  style: TextStyle(color: Colors.indigo)))
          : ListView.builder(
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classItem = _classes[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      classItem['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${classItem['date']} at ${classItem['time']}'),
                        Text(
                          'Description: ${classItem['description']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editClass(context, classItem),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _dbHelper.deleteClass(classItem['id']);
                            _loadClasses();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () => _addClass(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
