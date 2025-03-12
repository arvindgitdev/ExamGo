import 'package:flutter/material.dart';

class Studentpage extends StatelessWidget {
  const Studentpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        backgroundColor: Colors.lightBlue[100],
      ),
      drawer: Drawer( // Drawer for navigation
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFFB3E5Ff),
              ),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Navigate to Home
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Available Exams'),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Exam History'),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                /*Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentSettings()));*/
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Student!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Exams:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Math Exam - Tomorrow, 10:00 AM'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    title: Text('Science Quiz - Next Week, 2:00 PM'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
