import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamContentPage extends StatefulWidget {
  final String examId;

  const ExamContentPage({Key? key, required this.examId}) : super(key: key);

  @override
  _ExamContentPageState createState() => _ExamContentPageState();
}

class _ExamContentPageState extends State<ExamContentPage> {
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> examData = {};
  bool isLoading = true;
  int currentQuestionIndex = 0;
  Map<int, dynamic> answers = {};
  Timer? timer;
  int remainingSeconds = 0;
  final Map<int, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    loadExam();
  }

  @override
  void dispose() {
    timer?.cancel();
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void loadExam() async {
    try {
      final examDoc = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .get();

      if (!examDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam not found'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
        return;
      }

      examData = examDoc.data()!;

      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('questions')
          .get();

      questions = questionsSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      final durationStr = examData['duration'] as String;
      final hours = int.parse(durationStr.split('h')[0]);
      final minutes = int.parse(durationStr.split('h')[1].trim().split('m')[0]);

      final examTimestamp = examData['examTimestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final totalDurationSeconds = (hours * 3600) + (minutes * 60);
      final elapsedSeconds = (now - examTimestamp) ~/ 1000;

      remainingSeconds = totalDurationSeconds - elapsedSeconds;
      startTimer();

      setState(() => isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exam: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          submitExam();
        }
      });
    });
  }

  TextEditingController getTextController(int index) {
    _textControllers.putIfAbsent(index, () => TextEditingController());
    return _textControllers[index]!;
  }

  void submitExam() async {
    timer?.cancel();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<Map<String, dynamic>> detailedAnswers = [];

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final answer = answers[i];

        detailedAnswers.add({
          'questionId': question['id'],
          'questionText': question['question'],
          'questionType': question['type'],
          'answer': answer,
        });
      }

      await FirebaseFirestore.instance.collection('exam_submissions').add({
        'examId': widget.examId,
        'userId': user.uid,
        'answers': detailedAnswers,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam submitted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void saveAnswer(dynamic answer) => setState(() => answers[currentQuestionIndex] = answer);

  void nextQuestion() => setState(() => currentQuestionIndex++);

  void previousQuestion() => setState(() => currentQuestionIndex--);

  Widget buildQuestion(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'Multiple Choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question['question'], style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            ...List.generate((question['options'] as List).length, (i) {
              return RadioListTile(
                title: Text(question['options'][i]),
                value: i,
                groupValue: answers[currentQuestionIndex],
                onChanged: (val) => saveAnswer(val),
              );
            })
          ],
        );
      case 'Short Answer':
      case 'Fill in the Blank':
      case 'Code':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question['question'], style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: getTextController(currentQuestionIndex),
              maxLines: question['type'] == 'Code' ? 8 : 3,
              onChanged: saveAnswer,
              decoration: InputDecoration(
                hintText: question['type'] == 'Code' ? 'Enter code here' : 'Type your answer...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        );
      default:
        return const Text('Unsupported question type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(examData['title'] ?? "Exam", style: GoogleFonts.poppins()),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Chip(
              backgroundColor: remainingSeconds < 300 ? Colors.red.shade100 : Colors.green.shade100,
              label: Text(
                formatTime(remainingSeconds),
                style: TextStyle(
                  color: remainingSeconds < 300 ? Colors.red : Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(Colors.indigo),
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Container(
                  key: ValueKey(currentQuestionIndex),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: buildQuestion(questions[currentQuestionIndex]),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                    onPressed: currentQuestionIndex > 0 ? previousQuestion : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Submit"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Submit Exam"),
                        content: const Text("Are you sure you want to submit your answers?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          ElevatedButton(
                            child: const Text("Submit"),
                            onPressed: () {
                              Navigator.pop(ctx);
                              submitExam();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next"),
                    onPressed: currentQuestionIndex < questions.length - 1 ? nextQuestion : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
