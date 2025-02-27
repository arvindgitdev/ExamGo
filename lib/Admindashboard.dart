import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // replace with actual data from backend
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
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call

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
        title: const Text("Admin Dashboard"),
        // Add logout
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'ExamGo Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Exams'),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Users'),
            ),
            ListTile(
              leading: Icon(Icons.insights),
              title: Text('Reports'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard("Current Exams", currentExams),
            _buildCard("Upcoming Exams", upcomingExams),
            _buildCard("Recent Flagged Activities", flaggedActivities),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<dynamic> items) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text("No items to display.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.details),
                    onTap: () {
                      // Navigate to details page
                    },
                  );
                },
              ),
            if (items.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to "View All" page
                },
                child: const Text("View All"),
              ),
          ],
        ),
      ),
    );
  }
}

//replace with actual data structures
class Exam {
  final String name;
  final String status;
  final int participants;

  Exam(this.name, this.status, this.participants);

  String get details => "Status: $status, Participants: $participants";
}

class FlaggedActivity {
  final String participant;
  final String exam;
  final String activity;

  FlaggedActivity(this.participant, this.exam, this.activity);

  String get details => "Exam: $exam, Activity: $activity";
}