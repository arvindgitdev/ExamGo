import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Provider/auth_provider.dart';

class ManageExamsPage extends StatefulWidget {
  const ManageExamsPage({super.key});

  @override
  State<ManageExamsPage> createState() => _ManageExamsPageState();
}

class _ManageExamsPageState extends State<ManageExamsPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Manage Exams",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
          ),
        ),
        centerTitle: true,
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
            return _buildEmptyState("No upcoming exams found.");
          }

          List<DocumentSnapshot> upcomingExams = [];
          DateTime now = DateTime.now();

          for (var doc in snapshot.data!.docs) {
            Map<String, dynamic> examData = doc.data() as Map<String, dynamic>;
            int examTimestamp = examData["examTimestamp"] ?? 0;
            DateTime examDateTime = DateTime.fromMillisecondsSinceEpoch(examTimestamp);

            if (examDateTime.isAfter(now)) {
              upcomingExams.add(doc);
            }
          }

          if (upcomingExams.isEmpty) {
            return _buildEmptyState("No upcoming exams at the moment.");
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: upcomingExams.map((exam) => _buildExamCard(exam)).toList(),
          );
        },
      ),
    );
  }

  /// Builds the Exam Card with Edit & Delete options
  Widget _buildExamCard(DocumentSnapshot exam) {
    Map<String, dynamic> examData = exam.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 5,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          examData["title"] ?? "Unknown Exam",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.date_range, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(examData["date"] ?? "Unknown Date", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(examData["time"] ?? "Unknown Time", style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") {
              _editExam(exam);
            } else if (value == "delete") {
              _deleteExam(exam.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: "edit", child: Text("Edit")),
            const PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
      ),
    );
  }

  /// Opens a dialog to edit exam details
  void _editExam(DocumentSnapshot exam) {
    Map<String, dynamic> examData = exam.data() as Map<String, dynamic>;
    TextEditingController titleController = TextEditingController(text: examData["title"]);
    TextEditingController dateController = TextEditingController(text: examData["date"]);
    TextEditingController timeController = TextEditingController(text: examData["time"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Exam"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Exam Title"),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Exam Date"),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "Exam Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection("exams").doc(exam.id).update({
                "title": titleController.text,
                "date": dateController.text,
                "time": timeController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Deletes an exam from Firebase
  void _deleteExam(String examId) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete) {
      await FirebaseFirestore.instance.collection("exams").doc(examId).delete();
    }
  }

  /// Shows a confirmation dialog before deleting
  Future<bool> _showDeleteConfirmationDialog() async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this exam?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    return shouldDelete ?? false;
  }

  /// Shows an empty state when there are no upcoming exams
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(message, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
