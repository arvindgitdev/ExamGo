import 'package:examgo/createexam.dart';
import 'package:flutter/material.dart';

class Exam {
  final String id;
  String name;
  String description;
  int durationMinutes;

  Exam({required this.id, required this.name, required this.description, required this.durationMinutes});
}

class ManageExamsPage extends StatefulWidget {
  const ManageExamsPage({super.key});

  @override
  State<ManageExamsPage> createState() => _ManageExamsPageState();
}

class _ManageExamsPageState extends State<ManageExamsPage> {

  List<Exam> exams = [
    Exam(id: '1', name: 'Math Exam', description: 'A math exam', durationMinutes: 60),
    Exam(id: '2', name: 'Science Quiz', description: 'A science quiz', durationMinutes: 30),
    Exam(id: '3', name: 'English Test', description: 'An English test', durationMinutes: 45),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create exam page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Createexam(exam: null)),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          return ListTile(
            title: Text(exam.name),
            subtitle: Text('${exam.durationMinutes} minutes'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    //Navigate
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    //delete exam logic
                    _showDeleteConfirmationDialog(exam);
                  },
                ),
              ],
            ),
            onTap: () {
              // exam details
            },
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(Exam exam) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exam'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete "${exam.name}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  exams.remove(exam); // Remove the exam from the list.
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

