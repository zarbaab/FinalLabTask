import 'package:campus_life_assistant_app/AssignmentTrackerScreen.dart';
import 'package:campus_life_assistant_app/CourseManagementScreen.dart';
import 'package:campus_life_assistant_app/FeedbackScreen.dart';
import 'package:campus_life_assistant_app/StudyGroupScreen.dart';
import 'package:flutter/material.dart';
import 'class_schedule_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username; // Accepting username from login

  const DashboardScreen({super.key, required this.username});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Hi, ${widget.username} 👋', // Personalized greeting
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopImageBox(),
            const SizedBox(height: 16),
            _buildNavigationGrid(context),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top rectangular box with an image
  Widget _buildTopImageBox() {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.25, // Occupy 25% of screen height
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage('assets/banner.png'), // Top image asset
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Navigation grid with square boxes
  Widget _buildNavigationGrid(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        "title": "Class Schedule",
        "image": "assets/class.png",
        "screen": const ClassScheduleScreen(),
        "gradient": [Colors.blue, Colors.lightBlueAccent],
      },
      {
        "title": "Assignments",
        "image": "assets/asignment.png",
        "screen": const AssignmentTrackerScreen(),
        "gradient": [Colors.purple, Colors.deepPurpleAccent],
      },
      {
        "title": "Group Study",
        "image": "assets/group.png",
        "screen": const StudyGroupScreen(),
        "gradient": [Colors.green, Colors.lightGreenAccent],
      },
      {
        "title": "Feedback",
        "image": "assets/feedback.png",
        "screen": const FeedbackScreen(),
        "gradient": [Colors.orange, Colors.deepOrangeAccent],
      },
      {
        "title": "Courses",
        "image": "assets/courses.png",
        "screen": const CourseManagementScreen(),
        "gradient": [Colors.red, Colors.redAccent],
      },
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3 / 2,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return _buildNavigationBox(
            context: context,
            title: option['title'],
            image: option['image'],
            screen: option['screen'],
            gradient: option['gradient'],
          );
        },
      ),
    );
  }

  Widget _buildNavigationBox({
    required BuildContext context,
    required String title,
    required String image,
    required Widget screen,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 60, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
