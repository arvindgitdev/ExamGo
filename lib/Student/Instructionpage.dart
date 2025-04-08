import 'package:flutter/material.dart';

class ExamInstructionsPage extends StatelessWidget {
  const ExamInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Instructions'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900]),
          ),
        ),
        //backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Read the following instructions carefully before starting the exam:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'General Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. This exam consists of [Number] questions.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '2. The total duration of the exam is [Duration] minutes.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '3. Each question carries [Marks] marks.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '4. There is [Negative Marking] for incorrect answers.',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '5. Do not use any unfair means during the exam.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'Specific Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. [Specific Instruction 1 related to the exam format or rules].',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '2. [Specific Instruction 2 related to the exam format or rules].',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              '3. [Specific Instruction 3 related to the exam format or rules].',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            const Text(
              'By clicking "Start Exam", you acknowledge that you have read and understood all the instructions.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showPermissionDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Start Exam'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This exam may require the following permissions:'),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Camera Access (for proctoring)'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.mic),
                    SizedBox(width: 8),
                    Text('Microphone Access (for proctoring)'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.screen_share),
                    SizedBox(width: 8),
                    Text('Screen Sharing (may be required)'),
                  ],
                ),
                SizedBox(height: 10),
                Text('Please grant these permissions before starting the exam.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Deny', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Grant & Start'),
              onPressed: () {
                /*Navigator.of(context).pop();
                // Placeholder for permission granting and exam start navigation
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ExamContentPage()),
                );*/
              },
            ),
          ],
        );
      },
    );
  }
}

/*class ExamContentPage extends StatelessWidget {
  const ExamContentPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text("Exam Content")),
      body: Center(child: Text("Exam content will be here.")),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: ExamInstructionsPage()));
}*/