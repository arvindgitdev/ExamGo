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

  // Map to store text controllers for text-based questions
  final Map<int, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    loadExam();
  }

  @override
  void dispose() {
    timer?.cancel();
    // Clean up all text controllers
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void loadExam() async {
    try {
      // Load exam data
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

      // Load questions
      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('questions')
          .get();

      questions = questionsSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // Calculate remaining time
      final durationStr = examData['duration'] as String; // Format: "2h 30m"
      final hours = int.parse(durationStr.split('h')[0]);
      final minutes = int.parse(durationStr.split('h')[1].trim().split('m')[0]);

      final examTimestamp = examData['examTimestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final totalDurationSeconds = (hours * 60 * 60) + (minutes * 60);
      final elapsedSeconds = (now - examTimestamp) ~/ 1000;

      remainingSeconds = totalDurationSeconds - elapsedSeconds;

      // Start timer
      startTimer();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exam: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Get or create text controller for a question index
  TextEditingController getTextController(int index) {
    if (!_textControllers.containsKey(index)) {
      final currentAnswer = answers[index] as String? ?? '';
      _textControllers[index] = TextEditingController(text: currentAnswer);
    }
    return _textControllers[index]!;
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

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void submitExam() async {
    timer?.cancel();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated'), backgroundColor: Colors.red),
        );
        return;
      }

      // Save answers to Firestore
      await FirebaseFirestore.instance.collection('exam_submissions').add({
        'examId': widget.examId,
        'userId': user.uid,
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Navigate back to student dashboard
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam submitted successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting exam: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void saveAnswer(dynamic answer) {
    setState(() {
      answers[currentQuestionIndex] = answer;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    final questionType = question['type'];

    switch (questionType) {
      case 'Multiple Choice':
        return buildMultipleChoiceQuestion(question);
      case 'Short Answer':
        return buildShortAnswerQuestion(question);
      case 'Fill in the Blank':
        return buildFillInBlankQuestion(question);
      case 'Code':
        return buildCodeQuestion(question);
      default:
        return const Center(child: Text('Unknown question type'));
    }
  }

  Widget buildMultipleChoiceQuestion(Map<String, dynamic> question) {
    final options = question['options'] as List<dynamic>;
    final currentAnswer = answers[currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return RadioListTile<int>(
            title: Text(option),
            value: index,
            groupValue: currentAnswer,
            onChanged: (value) {
              saveAnswer(value);
            },
          );
        }).toList(),
      ],
    );
  }

  Widget buildShortAnswerQuestion(Map<String, dynamic> question) {
    // Initialize controller if needed
    TextEditingController controller = getTextController(currentQuestionIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your answer here',
          ),
          onChanged: (value) {
            saveAnswer(value);
          },
        ),
      ],
    );
  }

  Widget buildFillInBlankQuestion(Map<String, dynamic> question) {
    // Initialize controller if needed
    TextEditingController controller = getTextController(currentQuestionIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Fill in the blank',
          ),
          onChanged: (value) {
            saveAnswer(value);
          },
        ),
      ],
    );
  }

  Widget buildCodeQuestion(Map<String, dynamic> question) {
    // Initialize controller if needed
    TextEditingController controller = getTextController(currentQuestionIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 10,
          style: const TextStyle(
            fontFamily: 'Courier', // Monospace font moved here
            fontFeatures: [FontFeature.tabularFigures()], // Font feature moved here
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Write your code here',
          ),
          onChanged: (value) {
            saveAnswer(value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Loading Exam...",
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          examData['title'] ?? "Exam",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
          ),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: remainingSeconds < 300 ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatTime(remainingSeconds),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: remainingSeconds < 300 ? Colors.red : Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: questions.isEmpty ? 0 : (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),

            // Question card
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: questions.isEmpty
                      ? const Center(child: Text('No questions found'))
                      : buildQuestion(questions[currentQuestionIndex]),
                ),
              ),
            ),

            // Navigation buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0 ? previousQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Submit Exam'),
                          content: const Text('Are you sure you want to submit your exam? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                submitExam();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('End Exam'),
                ),
                ElevatedButton(
                  onPressed: currentQuestionIndex < questions.length - 1 ? nextQuestion : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}