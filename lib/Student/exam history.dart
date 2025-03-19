import 'package:flutter/material.dart';

class ExamHistory extends StatelessWidget {
  const ExamHistory({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> examHistory = [
      {
        'title': 'Math Exam',
        'date': '2023-10-26',
        'score': 85,
        'status': 'Passed',
      },
      {
        'title': 'Science Quiz',
        'date': '2023-10-25',
        'score': 60,
        'status': 'Failed',
      },
      {
        'title': 'English Test',
        'date': '2023-10-20',
        'score': 92,
        'status': 'Passed',
      },
      // Add more exam history entries here
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam History'),
        backgroundColor: Colors.lightBlue[300], // Consistent light blue theme
      ),
      body: ListView.builder(
        itemCount: examHistory.length,
        itemBuilder: (context, index) {
          final exam = examHistory[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(exam['title'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${exam['date']}'),
                  Text('Score: ${exam['score']}, Status: ${exam['status']}'),
                ],
              ),
              trailing: const Icon(Icons.history), // Example icon, replace as needed
            ),
          );
        },
      ),
    );
  }
}