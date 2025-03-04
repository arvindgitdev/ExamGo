import 'package:flutter/material.dart';

class Exam {
  final String id;
  String name;
  String description;
  int durationMinutes;
  List<String> questions;

  Exam({required this.id, required this.name, required this.description, required this.durationMinutes, required this.questions});
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
  List<String> _questions = [];

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
      _questions = List.from(widget.exam!.questions);
    } else {
      _examName = '';
      _description = '';
      _durationMinutes = 60;
      _questions = [];
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add('');
    });
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
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: TextFormField(
                            initialValue: _questions[index],
                            decoration: InputDecoration(labelText: "Question ${index + 1}"),
                            onChanged: (value) => _questions[index] = value,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: Text("Add Question"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    debugPrint(
                        'Saving exam: Name: $_examName, Description: $_description, Duration: $_durationMinutes, Questions: $_questions');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exam Saved!')),
                    );
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// hello
