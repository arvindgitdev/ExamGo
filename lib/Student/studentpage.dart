import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgo/Provider/auth_provider.dart';
import 'package:examgo/Student/Instructionpage.dart';
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
                        // Modified part of the ElevatedButton onPressed callback in Studentpage
                          onPressed: () async {
                            String key = examKeyController.text.trim();

                            if (key.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid key')),
                              );
                              return;
                            }

                            try {
                              // Query for exam with matching key
                              final querySnapshot = await FirebaseFirestore.instance
                                  .collection('exams')
                                  .where('examKey', isEqualTo: key)
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                final examDoc = querySnapshot.docs.first;
                                final examData = examDoc.data();
                                final examId = examDoc.id;

                                // Get current time
                                final now = DateTime.now().millisecondsSinceEpoch;

                                // Get exam timestamp from Firestore
                                final examTimestamp = examData['examTimestamp'] as int;

                                // Parse duration string to get exam end time
                                final durationStr = examData['duration'] as String; // Format: "2h 30m"
                                final hours = int.parse(durationStr.split('h')[0]);
                                final minutes = int.parse(durationStr.split('h')[1].trim().split('m')[0]);
                                final durationMillis = (hours * 60 * 60 + minutes * 60) * 1000;

                                final examEndTime = examTimestamp + durationMillis;

                                // Calculate time differences in minutes
                                final minsUntilExam = (examTimestamp - now) / (1000 * 60);
                                final minsSinceExamStarted = (now - examTimestamp) / (1000 * 60);

                                // Case 1: Exam completed
                                if (now > examEndTime) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('This exam has already ended'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                // Case 2: Exam is upcoming but within 15 min window - allow instructions only
                                else if (minsUntilExam <= 15 && minsUntilExam > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExamInstructionsPage(
                                        examId: examId,
                                        examData: examData,
                                        canStartExam: false,
                                        message: 'Exam will start in ${minsUntilExam.ceil()} minutes',
                                      ),
                                    ),
                                  );
                                }

                                // Case 3: Exam is ongoing but within 10 min late window - allow full access
                                else if (minsSinceExamStarted <= 10 && minsSinceExamStarted > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExamInstructionsPage(
                                        examId: examId,
                                        examData: examData,
                                        canStartExam: true,
                                        message: 'Exam is in progress. You can start now.',
                                      ),
                                    ),
                                  );
                                }

                                // Case 4: Exam is ongoing but past 10 min window - deny access
                                else if (minsSinceExamStarted > 10 && now < examEndTime) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You are more than 10 minutes late. Entry denied.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Case 5: Exam hasn't started yet and not within 15 min window
                                else if (minsUntilExam > 15) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Exam will start in ${(minsUntilExam / 60).floor()} hours and ${(minsUntilExam % 60).ceil()} minutes. You can enter 15 minutes before the start time.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                              } else {
                                // Key is invalid
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid Exam Key'), backgroundColor: Colors.red),
                                );
                              }
                            } catch (e) {
                              // Handle error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error validating key: $e'), backgroundColor: Colors.red),
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
                  // Navigate to a page that shows more details about the exam
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
                  // Navigate to a page that shows more details about the exam
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
          _buildDrawerItem(Icons.history_outlined, "Exam History", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExamHistory()));
          }),
          _buildDrawerItem(Icons.settings_outlined, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StudentSettings()));
          }),
          _buildDrawerItem(Icons.logout_outlined, "Logout", () async {
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
