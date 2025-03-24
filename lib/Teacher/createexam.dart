import 'package:examgo/Teacher/question_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Createexam extends StatefulWidget {
  @override
  State<Createexam> createState() => _CreateexamState();
}

class _CreateexamState extends State<Createexam> {
  final _formKey = GlobalKey<FormState>();

  String _examName = '';
  String _description = '';
  int _selectedHours = 1;
  int _selectedMinutes = 0;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Create Exam",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade900])),
        ),
        elevation: 6,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exam Name
                  TextFormField(
                    textInputAction: TextInputAction.next,
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
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value!.isEmpty ? "Enter description" : null,
                    onSaved: (value) => _description = value!,
                  ),
                  SizedBox(height: 15),

                  // Exam Date Picker
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Exam Date: ${DateFormat.yMMMMd().format(_selectedDate)}", style: TextStyle(fontSize: 16)),
                          Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Exam Time Picker
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                      if (picked != null) {
                        setState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Exam Time: ${_selectedTime.format(context)}", style: TextStyle(fontSize: 16)),
                          Icon(Icons.access_time, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Duration Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedHours,
                          decoration: InputDecoration(
                            labelText: "Hours",
                            prefixIcon: Icon(Icons.timer),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: List.generate(6, (index) => DropdownMenuItem(value: index, child: Text("$index hrs"))),
                          onChanged: (value) {
                            setState(() {
                              _selectedHours = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedMinutes,
                          decoration: InputDecoration(
                            labelText: "Minutes",
                            prefixIcon: Icon(Icons.timer),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: [0, 5,10,15,20,25, 30,35,40, 45,50]
                              .map((minutes) => DropdownMenuItem(value: minutes, child: Text("$minutes min")))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMinutes = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Add Questions Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                                durationHours: _selectedHours,
                                durationMinutes: _selectedMinutes,
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
