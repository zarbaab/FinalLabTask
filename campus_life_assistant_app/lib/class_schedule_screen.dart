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
    // Request notification permissions
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted notification permissions");

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      // Handle notification clicks when the app is in the background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message);
      });

      // Get and print the FCM token (optional, for debugging)
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");
    } else {
      print("Notification permissions denied or not granted");
    }

    // Configure local notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _handleNotificationClick(RemoteMessage message) {
    // Handle what happens when a notification is clicked
    print('Notification clicked: ${message.notification?.title}');
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
          title: Text(classData == null ? 'Add Class' : 'Edit Class'),
          content: Column(
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
                decoration: const InputDecoration(labelText: 'Date'),
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
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: selectedTime?.format(context) ?? 'No Time Selected',
                ),
                decoration: const InputDecoration(labelText: 'Time'),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
      appBar: AppBar(title: const Text('Class Schedule')),
      body: _classes.isEmpty
          ? const Center(child: Text('No classes yet'))
          : ListView.builder(
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                final classItem = _classes[index];
                return ListTile(
                  title: Text(classItem['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${classItem['date']} at ${classItem['time']}'),
                      Text(
                        'Description: ${classItem['description']}',
                        style: TextStyle(color: Colors.grey),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addClass(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
