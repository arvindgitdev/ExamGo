import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgo/Student/startexam.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamInstructionsPage extends StatefulWidget {
  final String examId;
  final Map<String, dynamic> examData;
  final bool canStartExam;
  final String message;

  const ExamInstructionsPage({
    Key? key,
    required this.examId,
    required this.examData,
    required this.canStartExam,
    required this.message,
  }) : super(key: key);

  @override
  State<ExamInstructionsPage> createState() => _ExamInstructionsPageState();
}

class _ExamInstructionsPageState extends State<ExamInstructionsPage> {
  bool _canStartExam = false;
  String _message = "";
  int _questionCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _canStartExam = widget.canStartExam;
    _message = widget.message;
    _loadQuestionCount();

    if (!_canStartExam) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _checkExamStatus();
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestionCount() async {
    try {
      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('questions')
          .get();

      setState(() {
        _questionCount = questionsSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading question count: $e');
    }
  }

  Future<void> _checkExamStatus() async {
    try {
      final now = DateTime.now();
      final examDate = widget.examData['date'] as String?;
      final examTime = widget.examData['time'] as String?;

      if (examDate != null && examTime != null) {
        final dateParts = examDate.split(' ');
        final timeParts = examTime.contains('AM') || examTime.contains('PM')
            ? examTime.split(RegExp(r'(?<=\d)(?=AM|PM)'))
            : [examTime, ''];

        final month = _getMonthNumber(dateParts[1]);
        int hour = int.parse(timeParts[0].split(':')[0]);
        int minute = int.parse(timeParts[0].split(':')[1]);

        if (examTime.contains('PM') && hour != 12) hour += 12;
        if (examTime.contains('AM') && hour == 12) hour = 0;

        final examDateTime = DateTime(
          int.parse(dateParts[2]),
          month,
          int.parse(dateParts[0]),
          hour,
          minute,
        );

        if (now.isAfter(examDateTime)) {
          setState(() {
            _canStartExam = true;
            _message = "✅ Exam is now available. You can start when ready.";
          });
          _refreshTimer?.cancel();
        } else {
          final difference = examDateTime.difference(now);
          final hours = difference.inHours;
          final minutes = difference.inMinutes % 60;
          final seconds = difference.inSeconds % 60;

          setState(() {
            if (hours > 0) {
              _message = "⏳ Exam will be available in $hours hrs $minutes min";
            } else if (minutes > 0) {
              _message = "⏳ Exam will be available in $minutes min $seconds sec";
            } else {
              _message = "⏳ Exam will be available in $seconds seconds";
            }
          });
        }
      }
    } catch (e) {
      print('Error checking exam status: $e');
    }
  }

  int _getMonthNumber(String monthAbbr) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthAbbr] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Exam Instructions",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.examData['title'] ?? 'Exam',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(widget.examData['date'] ?? 'Date not available', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(widget.examData['time'] ?? 'Time not available', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(widget.examData['duration'] ?? 'Duration not available', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.help_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                            _questionCount > 0
                                ? '$_questionCount Questions'
                                : 'Loading questions...',
                            style: const TextStyle(fontSize: 16)
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _canStartExam ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _canStartExam ? Icons.check_circle : Icons.access_time,
                            color: _canStartExam ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message,
                              style: TextStyle(
                                fontSize: 16,
                                color: _canStartExam ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_canStartExam)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Page will automatically refresh when exam time arrives",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "General Instructions",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("• Read all questions carefully before answering"),
                    Text("• Do not refresh or close the browser during the exam"),
                    Text("• Your answers are saved automatically as you proceed"),
                    Text("• You cannot return to previous questions once submitted"),
                    Text("• The exam will automatically submit when time expires"),
                    Text("• Use the 'End Exam' button to submit your answers early"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canStartExam
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamContentPage(examId: widget.examId),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(
                  _canStartExam ? "Start Exam" : "Waiting for Exam Time",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
