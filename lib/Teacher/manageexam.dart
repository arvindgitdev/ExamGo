import 'package:examgo/Teacher/createexam.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final List<Exam> exams = [
    Exam(id: '1', name: 'Math Exam', description: 'Algebra, Geometry, and Trigonometry', durationMinutes: 60),
    Exam(id: '2', name: 'Science Quiz', description: 'Physics, Chemistry, and Biology', durationMinutes: 30),
    Exam(id: '3', name: 'English Test', description: 'Grammar, Comprehension, and Writing', durationMinutes: 45),
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _deleteExam(int index) {
    final removedExam = exams[index];
    setState(() {
      exams.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildExamItem(removedExam, index, animation),
      duration: const Duration(milliseconds: 300),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedExam.name} deleted'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Manage Exams',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600,color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900])),
        ),
        automaticallyImplyLeading: false,
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  Createexam()),
              );
            },
          ),
        ],
      ),
      body: exams.isEmpty
          ? _buildEmptyState()
          : AnimatedList(
        key: _listKey,
        initialItemCount: exams.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index, animation) {
          return _buildExamItem(exams[index], index, animation);
        },
      ),
    );
  }

  Widget _buildExamItem(Exam exam, int index, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(animation),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              exam.name,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${exam.description}\nDuration: ${exam.durationMinutes} minutes',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    // Navigate to edit exam page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Createexam()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteConfirmationDialog(index);
                  },
                ),
              ],
            ),
            onTap: () {
              // Show exam details
              _showExamDetailsDialog(exam);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Delete Exam',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${exams[index].name}"?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExam(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExamDetailsDialog(Exam exam) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            exam.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '${exam.description}\n\nDuration: ${exam.durationMinutes} minutes',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: GoogleFonts.poppins(color: Colors.blueAccent)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Colors.blue.shade400),
          const SizedBox(height: 16),
          Text(
            'No exams available',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + icon to add a new exam',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
