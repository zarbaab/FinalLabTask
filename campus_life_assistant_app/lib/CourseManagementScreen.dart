import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _professorNameController =
      TextEditingController();

  Future<void> _addCourse() async {
    if (_courseNameController.text.isNotEmpty &&
        _professorNameController.text.isNotEmpty) {
      await _firestore.collection('courses').add({
        'courseName': _courseNameController.text,
        'professorName': _professorNameController.text,
      });

      _courseNameController.clear();
      _professorNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Course added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill in all fields!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCourseList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final courses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  course['courseName'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Professor: ${course['professorName']}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailsScreen(course: course),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _firestore.collection('courses').doc(course.id).delete();
                  },
                ),
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
        title: const Text(
          'Course Management',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(
                labelText: 'Course Name',
                labelStyle: const TextStyle(color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.book, color: Colors.indigo),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _professorNameController,
              decoration: InputDecoration(
                labelText: 'Professor Name',
                labelStyle: const TextStyle(color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Course',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Courses List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildCourseList()),
          ],
        ),
      ),
    );
  }
}

class CourseDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot course;

  const CourseDetailsScreen({super.key, required this.course});

  Future<Map<String, double>> _fetchFeedbackStats(String courseName) async {
    final feedbacks = await FirebaseFirestore.instance
        .collection('feedback')
        .where('courseName', isEqualTo: courseName)
        .get();

    int positive = 0;
    int total = feedbacks.docs.length;

    for (var feedback in feedbacks.docs) {
      if ((feedback['rating'] ?? 0) >= 4) {
        positive++;
      }
    }

    double positivePercentage = total > 0 ? (positive / total) * 100 : 0;
    double negativePercentage = total > 0 ? 100 - positivePercentage : 0;

    return {
      'positive': positivePercentage,
      'negative': negativePercentage,
    };
  }

  Future<List<Map<String, dynamic>>> _fetchAssignments(
      String courseName) async {
    final assignments = await FirebaseFirestore.instance
        .collection('assignments')
        .where('courseName', isEqualTo: courseName)
        .get();

    return assignments.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    String courseName = course['courseName'];
    String professorName = course['professorName'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$courseName - $professorName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder(
        future: Future.wait([
          _fetchFeedbackStats(courseName),
          _fetchAssignments(courseName),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedbackStats = snapshot.data![0] as Map<String, double>;
          final assignments = snapshot.data![1] as List<Map<String, dynamic>>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Professor Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CircularPercentIndicator(
                    radius: 80.0,
                    lineWidth: 10.0,
                    percent: feedbackStats['positive']! / 100,
                    center: Text(
                      "${feedbackStats['positive']!.toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 18),
                    ),
                    progressColor: Colors.green,
                    backgroundColor: Colors.red,
                    footer: const Text(
                      'Positive Feedback',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assignments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    return Card(
                      child: ListTile(
                        title: Text(assignment['title']),
                        subtitle: Text('Due: ${assignment['due_date']}'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
