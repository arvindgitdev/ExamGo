import 'package:examgo/Teacher/question_page.dart';
import 'package:flutter/material.dart';

class Exam {
  final String id;
  String name;
  String description;
  int durationMinutes;


  Exam({required this.id, required this.name, required this.description, required this.durationMinutes});
}

class Createexam extends StatefulWidget {
  final Exam? exam;

  const Createexam({super.key, this.exam});

  @override
  State<Createexam> createState() => _CreateexamState();
}

class _CreateexamState extends State<Createexam> {
  final _formKey = GlobalKey<FormState>();
  late String _examName;
  late String _description;
  late int _durationMinutes;


  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.exam != null) {
      _examName = widget.exam!.name;
      _description = widget.exam!.description;
      _durationMinutes = widget.exam!.durationMinutes;

    } else {
      _examName = '';
      _description = '';
      _durationMinutes = 60;

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam == null ? "Create Exam" : "Edit Exam"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _examName,
                decoration: const InputDecoration(labelText: "Exam Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter exam name";
                  }
                  return null;
                },
                onSaved: (value) => _examName = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _durationMinutes.toString(),
                decoration: const InputDecoration(labelText: "Duration (minutes)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter duration";
                  }
                  if (int.tryParse(value) == null) {
                    return "Invalid duration";
                  }
                  return null;
                },
                onSaved: (value) => _durationMinutes = int.parse(value!),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateExamScreen() ),
                  );
                },
                child: Text("Add Question"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
