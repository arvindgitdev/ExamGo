import 'package:examgo/Provider/auth_provider.dart';
import 'package:examgo/Teacher/exam.dart';
import 'package:examgo/Teacher/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Exam> currentExams = [];
  List<Exam> upcomingExams = [];
  List<FlaggedActivity> flaggedActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulated API call
    currentExams = [
      Exam("Math Exam", "Active", 25),
      Exam("Science Quiz", "Scheduled", 15),
    ];
    upcomingExams = [
      Exam("English Literature", "Scheduled", 20),
      Exam("Programming Exam", "Scheduled", 18),
    ];
    flaggedActivities = [
      FlaggedActivity("John Doe", "Math Exam", "Suspicious behavior"),
      FlaggedActivity("Jane Smith", "Science Quiz", "Multiple accounts"),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile
            },
          )
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard("Current Exams", currentExams, Icons.assignment),
            _buildSectionCard("Upcoming Exams", upcomingExams, Icons.schedule),
            _buildFlaggedCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Admin"),
            accountEmail: Text(user?.email ?? "admin@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          _buildDrawerItem(Icons.dashboard_customize_outlined, "Dashboard", () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );

          }),
          _buildDrawerItem(Icons.assignment_outlined, "Exam", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExamPage()),
            );
          }),
          _buildDrawerItem(Icons.settings_outlined, "Settings", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
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
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildSectionCard(String title, List<Exam> exams, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (exams.isEmpty)
              const Center(child: Text("No exams available."))
            else
              ...exams.map((exam) => _buildExamTile(exam)),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTile(Exam exam) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: exam.status == "Active" ? Colors.green : Colors.orange,
          child: const Icon(Icons.assignment, color: Colors.white),
        ),
        title: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Status: ${exam.status}, Participants: ${exam.participants}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to exam details
        },
      ),
    );
  }

  Widget _buildFlaggedCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.redAccent),
                const SizedBox(width: 10),
                const Text(
                  "Recent Flagged Activities",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (flaggedActivities.isEmpty)
              const Center(child: Text("No flagged activities."))
            else
              ...flaggedActivities.map((activity) => _buildFlaggedTile(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildFlaggedTile(FlaggedActivity activity) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      color: Colors.red[50],
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.redAccent),
        title: Text(activity.participant, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Exam: ${activity.exam}, Issue: ${activity.activity}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class Exam {
  final String name;
  final String status;
  final int participants;
  Exam(this.name, this.status, this.participants);
}

class FlaggedActivity {
  final String participant;
  final String exam;
  final String activity;
  FlaggedActivity(this.participant, this.exam, this.activity);
}
