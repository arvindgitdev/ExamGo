import 'package:examgo/Student/startexam.dart';
import 'package:flutter/material.dart';

class AvailableExams extends StatelessWidget {
  const AvailableExams({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> availableExams = [
      {
        'title': 'Math Exam',
        'description': 'A comprehensive math exam.',
        'date': 'Tomorrow, 10:00 AM',
        'duration': '60 minutes',
      },
      {
        'title': 'Science Quiz',
        'description': 'A short quiz on general science.',
        'date': 'Next Week, 2:00 PM',
        'duration': '30 minutes',
      },
      {
        'title': 'English Test',
        'description': 'Test your English proficiency.',
        'date': 'Next Friday, 11:00 AM',
        'duration': '45 minutes',
      },
      // Add more exams here
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Exams'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: ListView.builder(
        itemCount: availableExams.length,
        itemBuilder: (context, index) {
          final exam = availableExams[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(exam['title']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam['description']!),
                  Text('Date: ${exam['date']!}, Duration: ${exam['duration']!}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {

                  _startExam(context, exam['title']!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _startExam(BuildContext context, String examTitle) {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Start $examTitle?'),
          content: const Text('Are you sure you want to start this exam?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
               Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=> StartExamPage()));
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }
}

/*class ExamPage extends StatelessWidget {
  final String examTitle;
  const ExamPage({super.key, required this.examTitle});
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(examTitle)),
      body: Center(child: Text("Exam $examTitle will be here.")),
    );
  }
}*/