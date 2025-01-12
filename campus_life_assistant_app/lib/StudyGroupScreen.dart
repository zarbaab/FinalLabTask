import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_details_screen.dart';

class StudyGroupScreen extends StatefulWidget {
  const StudyGroupScreen({super.key});

  @override
  State<StudyGroupScreen> createState() => _StudyGroupScreenState();
}

class _StudyGroupScreenState extends State<StudyGroupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _groupNameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  String get _currentUser => user?.email ?? "unknown_user";

  Future<void> _createGroup() async {
    if (_groupNameController.text.isNotEmpty) {
      try {
        await _firestore.collection('study_groups').add({
          'groupName': _groupNameController.text,
          'createdBy': _currentUser,
          'members': [_currentUser],
        });
        _groupNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  Future<void> _joinGroup(String groupId, List<dynamic> members) async {
    if (!members.contains(_currentUser)) {
      await _firestore.collection('study_groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([_currentUser]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined the group!')),
      );
    }
  }

  Future<void> _leaveGroup(String groupId, List<dynamic> members) async {
    if (members.contains(_currentUser)) {
      await _firestore.collection('study_groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([_currentUser]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Left the group!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Study Groups'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: const TextStyle(color: Colors.indigo),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.indigo),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.indigo, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Create',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('study_groups').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.indigo));
                }
                final groups = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final groupId = group.id;
                    final groupName = group['groupName'];
                    final members = List<String>.from(group['members']);
                    final isMember = members.contains(_currentUser);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          groupName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        subtitle: Text(
                          'Members: ${members.length}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: ElevatedButton(
                          onPressed: isMember
                              ? () => _leaveGroup(groupId, members)
                              : () => _joinGroup(groupId, members),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isMember ? Colors.red : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isMember ? 'Leave' : 'Join',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: isMember
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailScreen(
                                      groupId: groupId,
                                      groupName: groupName,
                                    ),
                                  ),
                                )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
