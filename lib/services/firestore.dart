import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Data Collection
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Task Collection
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  // Fetch user data
  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot = await users.doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  // Update user data
  Future<void> updateUserData(
      String uid, Map<String, dynamic> updatedData) async {
    try {
      await users.doc(uid).update(updatedData);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Add a new task
  Future<void> addTask(String taskDescription, String taskDate) async {
    try {
      await tasks.add({
        'taskDescription': taskDescription,
        'taskDate': taskDate,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Get tasks from Firestore
  Stream<List<Task>> getTasks() {
    return tasks
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task(
                  taskId: doc.id, // Task ID for deletion
                  taskDescription: doc['taskDescription'],
                  taskDate: doc['taskDate'],
                ))
            .toList());
  }

  // Delete task by ID
  Future<void> deleteTask(String taskId) async {
    try {
      await tasks.doc(taskId).delete();
      print("Task deleted successfully");
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}

class Task {
  final String taskId;
  final String taskDescription;
  final String taskDate;

  Task({
    required this.taskId,
    required this.taskDescription,
    required this.taskDate,
  });
}
