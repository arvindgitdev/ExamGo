import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgo/Teacher/Admindashboard.dart';
import 'package:examgo/Teacher/student_stream.dart'; // New page for student stream
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Provider/auth_provider.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
              (route) => false,
        );
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Ongoing Exams",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("exams")
              .where("createdBy", isEqualTo: user?.uid)
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
            DateTime now = DateTime.now();

            for (var doc in snapshot.data!.docs) {
              Map<String, dynamic> examData = doc.data() as Map<String, dynamic>;
              int examTimestamp = examData["examTimestamp"] is int
                  ? examData["examTimestamp"]
                  : int.tryParse(examData["examTimestamp"].toString()) ?? 0;

              String durationString = examData["duration"] ?? "1h 0m"; // Default duration
              RegExp regex = RegExp(r"(\d+)h (\d+)m");
              Match? match = regex.firstMatch(durationString);
              int durationHours = match != null ? int.parse(match.group(1)!) : 1;
              int durationMinutes = match != null ? int.parse(match.group(2)!) : 0;
              int duration = (durationHours * 60) + durationMinutes;

              DateTime examDateTime = DateTime.fromMillisecondsSinceEpoch(examTimestamp);
              if (examDateTime.isBefore(now) && examDateTime.add(Duration(minutes: duration)).isAfter(now)) {
                ongoingExams.add(doc);
              }
            }

            if (ongoingExams.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ongoingExams.length,
              itemBuilder: (context, index) {
                return _buildExamCard(context, ongoingExams[index]);
              },
            );
          },
        ),
      ),
    );
  }

  /// **Stylish Exam Card**
  Widget _buildExamCard(BuildContext context, DocumentSnapshot exam) {
    Map<String, dynamic> examData = exam.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        // Navigate to StudentStreamPage when the teacher clicks an exam
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentStreamPage(exam: exam),
          ),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                examData["title"] ?? "Unknown Title",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    "Duration: ${examData["duration"] ?? ""} ",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Empty State UI**
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text("No ongoing exams", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
