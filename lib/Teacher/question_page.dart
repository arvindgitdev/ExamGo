import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Admindashboard.dart';

class QuestionScreen extends StatefulWidget {
  final String examTitle;
  final String examDate;
  final String examTime;

  const QuestionScreen({
    super.key,
    required this.examTitle,
    required this.examDate,
    required this.examTime,
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

  Future<void> saveExam() async {
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
              Text("Saving exam..."),
            ],
          ),
        );
      },
    );

    try {
      DocumentReference examRef = await FirebaseFirestore.instance.collection("exams").add({
        "title": widget.examTitle,
        "date": widget.examDate,
        "time": widget.examTime,
        "createdBy": user.uid,
        "createdAt": Timestamp.now(),
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
        const SnackBar(content: Text("Exam saved successfully!"), backgroundColor: Colors.green),
      );

      // Navigate to another page (replace 'NextScreen' with your desired screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()), // Change `NextScreen` accordingly
      );

    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save exam: $e"), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle),
        backgroundColor: Colors.blue.shade100,
        automaticallyImplyLeading: false,
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
              onPressed: saveExam,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Save Exam"),
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
