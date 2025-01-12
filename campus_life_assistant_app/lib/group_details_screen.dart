import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? "unknown_user";

  final TextEditingController _scheduleTopicController =
      TextEditingController();
  final TextEditingController _scheduleDateController = TextEditingController();
  final TextEditingController _scheduleTimeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _resourceNameController = TextEditingController();
  final TextEditingController _resourceUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.indigo,
              child: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    icon: Icon(Icons.calendar_today),
                    text: "Schedule",
                  ),
                  Tab(
                    icon: Icon(Icons.message),
                    text: "Messages",
                  ),
                  Tab(
                    icon: Icon(Icons.folder),
                    text: "Resources",
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  children: [
                    _buildScheduleTab(),
                    _buildMessagesTab(),
                    _buildResourcesTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Column(
      children: [
        // Schedule List Section
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('study_groups')
                .doc(widget.groupId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.indigo,
                  ),
                );
              }

              final schedule =
                  (snapshot.data!.data() as Map<String, dynamic>)['schedule'] ??
                      [];
              if (schedule.isEmpty) {
                return const Center(
                  child: Text(
                    "No schedules available",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  final item = schedule[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        item['topic'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "${item['date']} at ${item['time']}",
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(
                        Icons.more_vert,
                        color: Colors.indigo,
                      ),
                      onLongPress: () => _showScheduleActions(context, item),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Add Schedule Section
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _scheduleTopicController,
                decoration: InputDecoration(
                  labelText: "Topic",
                  labelStyle: const TextStyle(color: Colors.indigo),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.indigo, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _scheduleDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        labelStyle: const TextStyle(color: Colors.indigo),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.indigo),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          _scheduleDateController.text =
                              pickedDate.toIso8601String().split('T').first;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _scheduleTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Time",
                        labelStyle: const TextStyle(color: Colors.indigo),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.indigo),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.indigo, width: 2),
                        ),
                      ),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          _scheduleTimeController.text =
                              pickedTime.format(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Add to Schedule",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showScheduleActions(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Update"),
                onTap: () {
                  Navigator.pop(context);
                  _updateSchedule(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteSchedule(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateSchedule(Map<String, dynamic> item) async {
    // Populate the fields with the existing data
    _scheduleTopicController.text = item['topic'];
    _scheduleDateController.text = item['date'];
    _scheduleTimeController.text = item['time'];

    // Wait for user to press the "Update Schedule" button
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Schedule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _scheduleTopicController,
                decoration: const InputDecoration(labelText: "Topic"),
              ),
              TextField(
                controller: _scheduleDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date"),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _scheduleDateController.text =
                        pickedDate.toIso8601String().split('T').first;
                  }
                },
              ),
              TextField(
                controller: _scheduleTimeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Time"),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _scheduleTimeController.text = pickedTime.format(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _firestore
                    .collection('study_groups')
                    .doc(widget.groupId)
                    .update({
                  'schedule': FieldValue.arrayRemove([item]),
                });
                await _firestore
                    .collection('study_groups')
                    .doc(widget.groupId)
                    .update({
                  'schedule': FieldValue.arrayUnion([
                    {
                      'topic': _scheduleTopicController.text,
                      'date': _scheduleDateController.text,
                      'time': _scheduleTimeController.text,
                    }
                  ]),
                });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSchedule(Map<String, dynamic> item) async {
    await _firestore.collection('study_groups').doc(widget.groupId).update({
      'schedule': FieldValue.arrayRemove([item]),
    });
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        // Messages List Section
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('study_groups')
                .doc(widget.groupId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.indigo,
                  ),
                );
              }

              final messages = snapshot.data!.docs;
              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    "No messages yet.",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.indigo[50]
                          : Colors.white, // Alternate colors
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        message['sender'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        message['message'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Text(
                        (message['timestamp'] as Timestamp)
                            .toDate()
                            .toLocal()
                            .toString()
                            .split('.')[0],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Message Input Section
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Message Input Field
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: "Type a message...",
                    labelStyle: const TextStyle(color: Colors.indigo),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.indigo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Colors.indigo, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.indigo[50],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send Button
              IconButton(
                icon: const Icon(Icons.send, color: Colors.indigo),
                iconSize: 28,
                onPressed: _sendMessage,
                tooltip: "Send",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addSchedule() async {
    try {
      if (_scheduleTopicController.text.isNotEmpty &&
          _scheduleDateController.text.isNotEmpty &&
          _scheduleTimeController.text.isNotEmpty) {
        await _firestore.collection('study_groups').doc(widget.groupId).update({
          'schedule': FieldValue.arrayUnion([
            {
              'topic': _scheduleTopicController.text,
              'date': _scheduleDateController.text,
              'time': _scheduleTimeController.text,
            }
          ]),
        });
        _scheduleTopicController.clear();
        _scheduleDateController.clear();
        _scheduleTimeController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding schedule: $e')));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _firestore
            .collection('study_groups')
            .doc(widget.groupId)
            .collection('messages')
            .add({
          'sender': "user@example.com", // Replace with the actual user
          'message': _messageController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        debugPrint("Error sending message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending message: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message cannot be empty")),
      );
    }
  }

  Widget _buildResourcesTab() {
    return Column(
      children: [
        // Resources List Section
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('study_groups')
                .doc(widget.groupId)
                .collection('resources')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.indigo, // Styled indicator
                    strokeWidth: 4.0, // Adjusted thickness
                  ),
                );
              }

              final resources = snapshot.data!.docs;
              if (resources.isEmpty) {
                return const Center(
                  child: Text(
                    "No resources available yet.",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  final resource = resources[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        resource['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      subtitle: Text(
                        resource['url'],
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_browser,
                            color: Colors.indigo),
                        onPressed: () {
                          _openResource(resource['url']);
                        },
                      ),
                      onLongPress: () =>
                          _showResourceActions(context, resource),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Resource Input Section
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resource Name Input
              TextField(
                controller: _resourceNameController,
                decoration: InputDecoration(
                  labelText: "Resource Name",
                  labelStyle: const TextStyle(color: Colors.indigo),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Colors.indigo, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.indigo[50],
                ),
              ),
              const SizedBox(height: 10),

              // Resource URL Input
              TextField(
                controller: _resourceUrlController,
                decoration: InputDecoration(
                  labelText: "Resource URL",
                  labelStyle: const TextStyle(color: Colors.indigo),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Colors.indigo, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.indigo[50],
                ),
              ),
              const SizedBox(height: 10),

              // Share Resource Button
              ElevatedButton(
                onPressed: _addResource,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Share Resource",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openResource(String resourceUrl) async {
    try {
      final Uri uri = Uri.parse(resourceUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to open resource URL")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening resource: $e")),
      );
      debugPrint("Error opening resource: $e");
    }
  }

  void _showResourceActions(
      BuildContext context, QueryDocumentSnapshot resource) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Update"),
                onTap: () {
                  Navigator.pop(context);
                  _updateResource(resource);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteResource(resource.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateResource(QueryDocumentSnapshot resource) {
    _resourceNameController.text = resource['name'];
    _resourceUrlController.text = resource['url'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Resource"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _resourceNameController,
                decoration: const InputDecoration(labelText: "Resource Name"),
              ),
              TextField(
                controller: _resourceUrlController,
                decoration: const InputDecoration(labelText: "Resource URL"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _firestore
                    .collection('study_groups')
                    .doc(widget.groupId)
                    .collection('resources')
                    .doc(resource.id)
                    .update({
                  'name': _resourceNameController.text,
                  'url': _resourceUrlController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                _resourceNameController.clear();
                _resourceUrlController.clear();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteResource(String resourceId) async {
    await _firestore
        .collection('study_groups')
        .doc(widget.groupId)
        .collection('resources')
        .doc(resourceId)
        .delete();
  }

  Future<void> _addResource() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be logged in to add a resource.")),
      );
      return;
    }

    if (_resourceNameController.text.isNotEmpty &&
        _resourceUrlController.text.isNotEmpty) {
      try {
        await _firestore
            .collection('study_groups')
            .doc(widget.groupId)
            .collection('resources')
            .add({
          'name': _resourceNameController.text,
          'url': _resourceUrlController.text,
          'uploadedBy': user.email, // Set the logged-in user's email
          'timestamp': FieldValue.serverTimestamp(),
        });
        _resourceNameController.clear();
        _resourceUrlController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resource shared successfully!")),
        );
      } catch (e) {
        debugPrint("Error adding resource: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing resource: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
    }
  }
}
