import 'package:examgo/Teacher/createexam.dart';
import 'package:examgo/Teacher/manageexam.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Exam Management",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),

        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade600,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(
              context,
              title: "Create Exam",
              icon: Icons.add_circle_outline,
              color: Colors.blue.shade500,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Createexam()),
              ),
            ),
            const SizedBox(height: 20),
            _buildButton(
              context,
              title: "Manage Exams",
              icon: Icons.edit_calendar_rounded,
              color: Colors.green.shade600,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageExamsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
