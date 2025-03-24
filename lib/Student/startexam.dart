import 'package:flutter/material.dart';

class StartExamPage extends StatefulWidget {
  const StartExamPage({super.key});

  @override
  State<StartExamPage> createState() => _StartExamPageState();
}

class _StartExamPageState extends State<StartExamPage> {
  final _formKey = GlobalKey<FormState>();
  String _examCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Exam'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Enter Exam Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the exam code';
                  }
                  return null;
                },
                onSaved: (value) => _examCode = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Implement exam start logic using _examCode
                   // _startExam(context, _examCode);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start Exam'),
              ),
            ],
          ),
        ),
      ),
    );
  }

 /* void _startExam(BuildContext context, String examCode) {
    // Replace with your actual exam start logic
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Start Exam'),
          content: Text('Starting exam with code: $examCode'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to exam page or start the exam
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ExamContentPage(examCode: examCode)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }
}

class ExamContentPage extends StatelessWidget {
  final String examCode;
  const ExamContentPage({super.key, required this.examCode});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exam Content $examCode")),
      body: Center(child: Text("Exam content for $examCode will be here.")),
    );
  }*/
}