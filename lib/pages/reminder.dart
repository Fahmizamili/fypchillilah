import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format date and time
import '../services/firestore.dart';

class TaskSchedule extends StatefulWidget {
  const TaskSchedule({super.key});

  @override
  State<TaskSchedule> createState() => _TaskScheduleState();
}

class _TaskScheduleState extends State<TaskSchedule> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // To track task completion status locally in the UI
  Map<String, bool> taskCompletionStatus = {};

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        selectedDate;

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  // Function to pick a time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        ) ??
        selectedTime;

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
      timeController.text =
          selectedTime.format(context); // Display selected time
    }
  }

  // Function to open the task input dialog
  void openTaskBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: "Task Description"),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: "Select Task Date"),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context), // Show time picker on tap
              child: AbsorbPointer(
                child: TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: "Task Time"),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  dateController.text.isNotEmpty &&
                  timeController.text.isNotEmpty) {
                final taskDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                firestoreService.addTask(textController.text,
                    DateFormat('yyyy-MM-dd HH:mm').format(taskDateTime));
                textController.clear();
                dateController.clear();
                timeController.clear();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")));
              }
            },
            child: Text("Add Task"),
          ),
        ],
      ),
    );
  }

  // Function to delete task
  void deleteTask(String taskId) {
    firestoreService.deleteTask(taskId);
    setState(() {}); // Force UI update after task deletion
  }

  // Function to toggle task completion in the UI (without updating Firestore)
  void toggleTaskCompletion(String taskId) {
    setState(() {
      taskCompletionStatus[taskId] = !(taskCompletionStatus[taskId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Schedule"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Manage your chili plant care tasks",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: firestoreService.getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No tasks scheduled"));
                  }

                  final tasks = snapshot.data!;
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      bool isCompleted =
                          taskCompletionStatus[tasks[index].taskId] ?? false;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            tasks[index].taskDescription,
                            style: TextStyle(
                              color: isCompleted ? Colors.grey : Colors.black,
                              fontSize: 18,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null, // Strikethrough for completed tasks
                            ),
                          ),
                          subtitle:
                              Text("Scheduled for: ${tasks[index].taskDate}"),
                          trailing: Icon(
                            Icons.check_circle,
                            color: isCompleted ? Colors.green : Colors.grey,
                          ),
                          onTap: () => toggleTaskCompletion(tasks[index]
                              .taskId), // Toggle task completion on click
                          leading: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteTask(
                                tasks[index].taskId), // Delete task on click
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openTaskBox,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
