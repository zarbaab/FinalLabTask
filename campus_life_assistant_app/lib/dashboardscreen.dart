import 'package:campus_life_assistant_app/AssignmentTrackerScreen.dart';
import 'package:flutter/material.dart';
import 'class_schedule_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Class Schedule Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassScheduleScreen(),
                  ),
                );
              },
              child: const Text('Manage Class Schedule'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Class Schedule Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AssignmentTrackerScreen(),
                  ),
                );
              },
              child: const Text('Assignments'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Log out and navigate back to login
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
