import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Admindashboard.dart';

class QuestionScreen extends StatefulWidget {
  final String examTitle;
  final String examDate;
  final String examTime;
  final int durationHours;
  final int durationMinutes;

  const QuestionScreen({
    super.key,
    required this.examTitle,
    required this.examDate,
    required this.examTime,
    required this.durationHours,
    required this.durationMinutes,
  });

  @override
  QuestionScreenState createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> {
  List<QuestionModel> questions = [QuestionModel()];
  bool isLoading = false;

  void addQuestion() {
    setState(() {
      questions.add(QuestionModel());
    });
  }

  void deleteQuestion(int index) {
    setState(() {
      questions[index].dispose();
      questions.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var question in questions) {
      question.dispose();
    }
    super.dispose();
  }
  void previewExam() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exam Preview"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📌 Exam Title: ${widget.examTitle}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("📅 Date: ${widget.examDate}  🕒 Time: ${widget.examTime}"),
                Text("⏳ Duration: ${widget.durationHours} hrs ${widget.durationMinutes} mins"),
                const Divider(),
                ...questions.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  QuestionModel question = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Q$index: ${question.questionController.text}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (question.questionType == "Multiple Choice")
                        ...question.options.map((e) => Text("🔹 ${e.text}")),
                      if (question.questionType == "Code")
                        Text("🖥 Code Answer: ${question.codeAnswerController.text}"),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Edit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                createExam();
              },
              child: const Text("Confirm & Submit"),
            ),
          ],
        );
      },
    );
  }
  Future<void> createExam() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated."), backgroundColor: Colors.red),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Creating exam..."),
            ],
          ),
        );
      },
    );

    try {
      // Generate a unique exam ID
      String examId = FirebaseFirestore.instance.collection("exams").doc().id;

      DocumentReference examRef = FirebaseFirestore.instance.collection("exams").doc(examId);

      await examRef.set({
        "examId": examId, // Store the unique ID
        "title": widget.examTitle,
        "date": widget.examDate,
        "time": widget.examTime,
        "duration": "${widget.durationHours}h ${widget.durationMinutes}m",
        "createdBy": user.uid,
        "examTimestamp":  _getExamTimestamp(),
      });

      for (var question in questions) {
        await examRef.collection("questions").add({
          "question": question.questionController.text,
          "type": question.questionType,
          "options": question.options.map((e) => e.text).toList(),
          "codeAnswer": question.codeAnswerController.text,
          "isRequired": question.isRequired,
        });
      }

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exam Created successfully!"), backgroundColor: Colors.green),
      );

      // Navigate to Admin Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );

    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Create exam: $e"), backgroundColor: Colors.red),
      );
    }
  }
  int _getExamTimestamp() {
    try {
      // Parse date properly
      DateTime parsedDate = DateTime.parse(widget.examDate); // Ensure YYYY-MM-DD format

      // Parse time properly (handling 12-hour format with AM/PM)
      TimeOfDay parsedTime = _parseTime(widget.examTime);

      // Combine date and time into a single DateTime object
      DateTime examDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      return examDateTime.millisecondsSinceEpoch;
    } catch (e) {
      print("Error parsing date/time: $e");
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

// Helper function to convert "hh:mm AM/PM" to TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    final format = RegExp(r'(\d+):(\d+) (\w{2})'); // Matches "hh:mm AM/PM"
    final match = format.firstMatch(timeStr);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!;

      if (period == "PM" && hour != 12) hour += 12;
      if (period == "AM" && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    }

    return TimeOfDay.now();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.examTitle,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
          ),
        ),
        centerTitle: true,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addQuestion,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Date: ${widget.examDate}  |  Time: ${widget.examTime}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return QuestionCard(
                    key: ValueKey(index),
                    questionModel: questions[index],
                    onDelete: () => deleteQuestion(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:  previewExam,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: Colors.blue.shade300,
              ),
              child: const Text("Preview & Submit" ,style: TextStyle(fontSize: 18, ),),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final QuestionModel questionModel;
  final VoidCallback onDelete;

  const QuestionCard({super.key, required this.questionModel, required this.onDelete});

  @override
  QuestionCardState createState() => QuestionCardState();
}

class QuestionCardState extends State<QuestionCard> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: widget.questionModel.questionController,
              decoration: const InputDecoration(
                labelText: "Enter Question",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: widget.questionModel.questionType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ["Multiple Choice", "Short Answer", "Fill in the Blank", "Code"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  widget.questionModel.questionType = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            if (widget.questionModel.questionType == "Multiple Choice") ...[
              Column(
                children: List.generate(widget.questionModel.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value;
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.questionModel.options[index],
                            decoration: InputDecoration(
                              hintText: "Option ${index + 1}",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.questionModel.options.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.questionModel.options.add(TextEditingController());
                  });
                },
                child: const Text("Add Option"),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Required"),
                Switch(
                  value: widget.questionModel.isRequired,
                  onChanged: (value) {
                    setState(() {
                      widget.questionModel.isRequired = value;
                    });
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionModel {
  TextEditingController questionController = TextEditingController();
  String questionType = "Multiple Choice";
  List<TextEditingController> options = [TextEditingController(), TextEditingController()];
  TextEditingController codeAnswerController = TextEditingController();
  bool isRequired = false;

  void dispose() {
    questionController.dispose();
    for (var option in options) {
      option.dispose();
    }
    codeAnswerController.dispose();
  }
}
