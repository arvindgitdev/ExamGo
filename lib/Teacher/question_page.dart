import 'package:flutter/material.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  CreateExamScreenState createState() => CreateExamScreenState();
}

class CreateExamScreenState extends State<CreateExamScreen> {
  List<QuestionModel> questions = [QuestionModel()];

  void addQuestion() {
    setState(() {
      questions.add(QuestionModel());
    });
  }

  void deleteQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  void saveExam() {
    // Check if all questions have text
    bool isValid = true;
    for (var question in questions) {
      if (question.questionController.text.isEmpty) {
        isValid = false;
        break;
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all questions before saving."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate saving the exam (You can add Firebase Firestore or database logic here)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Exam Saved Successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Exam"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addQuestion,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: saveExam,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text("Save Exam"),
            ),
          ),
        ],
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
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question TextField
            TextField(
              controller: widget.questionModel.questionController,
              decoration: const InputDecoration(
                hintText: "Question",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Question Type Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Question Type: "),
                DropdownButton<String>(
                  value: widget.questionModel.questionType,
                  items: ["Multiple Choice", "Short Answer", "Fill in the Blank", "Code"]
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.questionModel.questionType = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Multiple Choice Options
            if (widget.questionModel.questionType == "Multiple Choice") ...[
              Column(
                children: List.generate(widget.questionModel.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0), // Added spacing
                    child: Row(
                      children: [
                        Radio(
                          value: index,
                          groupValue: null,
                          onChanged: (_) {},
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
                          icon: const Icon(Icons.remove_circle, color: Colors.black),
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

            // Short Answer Input (Example Text)
            if (widget.questionModel.questionType == "Short Answer") ...[
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Short answer text",
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
            ],

            // Fill in the Blank Example
            if (widget.questionModel.questionType == "Fill in the Blank") ...[
              const SizedBox(height: 10),
              const Text("Example: The capital of France is _____"),
            ],

            // Code Question Type
            if (widget.questionModel.questionType == "Code") ...[
              const SizedBox(height: 10),
              TextField(
                controller: widget.questionModel.codeAnswerController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Enter your code here...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            // Required Toggle
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

            // Delete Button
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

// Question Model to store question data
class QuestionModel {
  TextEditingController questionController = TextEditingController();
  String questionType = "Multiple Choice";
  List<TextEditingController> options = [TextEditingController()];
  TextEditingController codeAnswerController = TextEditingController();
  bool isRequired = false;
}
