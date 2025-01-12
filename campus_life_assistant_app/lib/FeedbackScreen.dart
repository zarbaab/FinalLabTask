import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;

  String? _selectedCourse;
  String? _selectedProfessor;

  Future<void> _submitFeedback() async {
    if (_selectedCourse != null && _rating > 0) {
      try {
        await _firestore.collection('feedback').add({
          'courseName': _selectedCourse,
          'professorName': _selectedProfessor,
          'rating': _rating,
          'comment': _commentController.text,
          'submittedBy':
              "user@example.com", // Replace with actual user ID or email
        });
        _commentController.clear();
        setState(() {
          _rating = 0;
          _selectedCourse = null;
          _selectedProfessor = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields!')),
      );
    }
  }

  Future<List<Map<String, String>>> _fetchCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'courseName': data['courseName'] as String? ?? '',
        'professorName': data['professorName'] as String? ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, String>>>(
              future: _fetchCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.indigo),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Error loading courses: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                final courses = snapshot.data ?? [];

                return DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  decoration: InputDecoration(
                    labelText: 'Select a Course',
                    labelStyle: const TextStyle(color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value;
                      _selectedProfessor = courses.firstWhere((course) =>
                          course['courseName'] == value)['professorName'];
                    });
                  },
                  items: courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course['courseName'],
                      child: Text(course['courseName']!),
                    );
                  }).toList(),
                );
              },
            ),
            if (_selectedProfessor != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Professor: $_selectedProfessor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Rating:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Comment',
                labelStyle: const TextStyle(color: Colors.indigo),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.indigo, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
