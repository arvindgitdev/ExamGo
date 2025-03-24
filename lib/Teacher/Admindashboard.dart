import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgo/Teacher/exam.dart';
import 'package:examgo/Teacher/settings.dart' show SettingsPage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Provider/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  late Timer _timer;
  // This key will be used to force refresh the StreamBuilder
  Key _streamBuilderKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        // Generate a new key to force the StreamBuilder to rebuild
        setState(() {
          _streamBuilderKey = UniqueKey();
        });
      }
    });
  }

  // Method to manually refresh data
  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        // Generate a new key to force the StreamBuilder to rebuild
        _streamBuilderKey = UniqueKey();
      });
    }
    // Add a small delay to make the refresh indicator visible
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<QuerySnapshot>(
          key: _streamBuilderKey, // Add the key here to force rebuilds
          stream: FirebaseFirestore.instance
              .collection("exams")
              .orderBy("examTimestamp", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            List<DocumentSnapshot> ongoingExams = [];
            List<DocumentSnapshot> upcomingExams = [];
            List<DocumentSnapshot> completedExams = [];
            DateTime now = DateTime.now();

            for (var doc in snapshot.data!.docs) {
              Map<String, dynamic> examData = doc.data() as Map<String, dynamic>;
              int examTimestamp = examData["examTimestamp"] is int
                  ? examData["examTimestamp"]
                  : int.tryParse(examData["examTimestamp"].toString()) ?? 0;

              String durationString = examData["duration"] ?? "1h 0m"; // Default to "1h 0m" if null

              // Extract hours and minutes using regex
              RegExp regex = RegExp(r"(\d+)h (\d+)m");
              Match? match = regex.firstMatch(durationString);

              int durationHours = match != null ? int.parse(match.group(1)!) : 1;
              int durationMinutes = match != null ? int.parse(match.group(2)!) : 0;

              // Convert total duration to minutes
              int duration = (durationHours * 60) + durationMinutes;

              DateTime examDateTime = DateTime.fromMillisecondsSinceEpoch(examTimestamp);

              if (examDateTime.isBefore(now) &&
                  examDateTime.add(Duration(minutes: duration)).isAfter(now)) {
                ongoingExams.add(doc);
              } else if (examDateTime.isAfter(now)) {
                upcomingExams.add(doc);
              } else if (examDateTime.add(Duration(minutes: duration)).isBefore(now)) {
                completedExams.add(doc);
              }
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                  _buildSectionCard("Current Exams", ongoingExams, Icons.assignment, Colors.green),
                  _buildSectionCard("Upcoming Exams", upcomingExams, Icons.schedule, Colors.blue),
                  _buildSectionCard("Completed Exams", completedExams, Icons.check_circle, Colors.grey),
                ],

            );
          },
        ),
      ),
    );
  }

  /// **Stylish AppBar**
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Admin Dashboard",
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
        ),
      ),
      centerTitle: true,
      elevation: 6,
    );
  }

  /// **Section Title + Cards (Modified to Accept Color)**
  Widget _buildSectionCard(String title, List<DocumentSnapshot> exams, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (exams.isEmpty)
              const Text("No exams found.", style: TextStyle(fontSize: 14, color: Colors.grey))
            else
              Column(
                children: exams.map((exam) => _buildExamCard(exam, color)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// **Stylish Exam Cards (Modified to Accept Color)**
  Widget _buildExamCard(DocumentSnapshot exam, Color color) {
    Map<String, dynamic> examData = exam.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 5,
      shadowColor: color.withOpacity(0.3), // Slightly deeper shadow effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Navigate to ExamDetailsPage
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circular Icon with a gradient background
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color], // Smooth gradient effect
                  ),
                ),
                child: const Icon(Icons.assignment, color: Colors.white),
              ),
              const SizedBox(width: 16), // Space between icon and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exam Title
                    Text(
                      examData["title"] ?? "Unknown Title",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Prevents overflow issues
                    ),
                    const SizedBox(height: 8),

                    // Exam Date & Time
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          examData["date"] ?? "Unknown Date",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          examData["time"] ?? "Unknown Time",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Duration
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          "Duration: ${examData["duration"] ?? ""} ",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Arrow Icon for Navigation
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// **Enhanced Drawer**
  Widget _buildDrawer() {
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
          _buildDrawerItem(Icons.dashboard_customize_outlined, "Dashboard", () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.assignment_outlined, "Exam", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExamPage()));
          }),
          _buildDrawerItem(Icons.settings_outlined, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
          }),
          _buildDrawerItem(Icons.logout_outlined, "Logout", () async {
            await Provider.of<AuthProvider>(context, listen: false).signOut(context);
          }),
          const Divider(),
          _buildDrawerItem(Icons.groups_outlined, "Users", () {}),
          _buildDrawerItem(Icons.insights_outlined, "Reports", () {}),
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

  /// **Improved Empty State UI**
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text("No exams available", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}