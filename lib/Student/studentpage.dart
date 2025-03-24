import 'package:examgo/Provider/auth_provider.dart';
import 'package:examgo/Student/available%20exam.dart';
import 'package:examgo/Student/exam%20history.dart';
import 'package:examgo/Student/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Studentpage extends StatelessWidget {
  const Studentpage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController examKeyController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Dashboard",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
          ),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Student!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Section: Enter Exam Key
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Exam Key or Link',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: examKeyController,
                      decoration: InputDecoration(
                        hintText: 'Enter your exam key or link...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          String key = examKeyController.text.trim();
                          if (key.isNotEmpty) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Exam Key Entered: $key')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please enter a valid key')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        child: const Text('Enter Exam'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section: Upcoming Exams
            const Text(
              'Upcoming Exams',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Math Exam - Tomorrow, 10:00 AM'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {

                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Science Quiz - Next Week, 2:00 PM'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Admin"),
            accountEmail: Text(user?.email ?? "admin@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue.shade800),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
            ),
          ),
          _buildDrawerItem(Icons.home_outlined, "Home", () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.list_alt_outlined, "Available Exams", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AvailableExams()));
          }),
          _buildDrawerItem(Icons.history_outlined, " Exam History ", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExamHistory()));
          }),
          _buildDrawerItem(Icons.settings_outlined, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentSettings()));
          }),
          _buildDrawerItem(Icons.logout_outlined, "logout", () async {
            await Provider.of<AuthProvider>(context, listen: false).signOut(context);
          }),
        ],
      ),
    );
  }
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      onTap: onTap,
    );
  }
}
