import 'package:examgo/Teacher/question_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Exam {
  final String id;
  String name;
  String description;
  int durationMinutes;
  DateTime examDate;
  TimeOfDay examTime;

  Exam({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.examDate,
    required this.examTime,
  });
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
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

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
      _selectedDate = widget.exam!.examDate;
      _selectedTime = widget.exam!.examTime;
    } else {
      _examName = '';
      _description = '';
      _durationMinutes = 60;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.exam == null ? "Create Exam" : "Edit Exam"),
        backgroundColor: Colors.blue.shade100,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Exam Name
                  TextFormField(
                    initialValue: _examName,
                    decoration: InputDecoration(
                      labelText: "Exam Name",
                      prefixIcon: Icon(Icons.assignment),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value!.isEmpty ? "Enter exam name" : null,
                    onSaved: (value) => _examName = value!,
                  ),
                  SizedBox(height: 15),

                  // Description
                  TextFormField(
                    initialValue: _description,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? "Enter Description" : null,
                    onSaved: (value) => _description = value!,
                  ),
                  SizedBox(height: 15),

                  // Duration
                  TextFormField(
                    initialValue: _durationMinutes.toString(),
                    decoration: InputDecoration(
                      labelText: "Duration (minutes)",
                      prefixIcon: Icon(Icons.timer),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter duration";
                      if (int.tryParse(value) == null) return "Invalid duration";
                      return null;
                    },
                    onSaved: (value) => _durationMinutes = int.parse(value!),
                  ),
                  SizedBox(height: 15),

                  // Date Picker
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exam Date: ${DateFormat.yMMMMd().format(_selectedDate)}",
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Time Picker
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exam Time: ${_selectedTime.format(context)}",
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.access_time, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Add Questions Button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionScreen(
                              examTitle: _examName,
                              examDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                              examTime: _selectedTime.format(context),
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.add_circle),
                    label: Text("Add Questions"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
