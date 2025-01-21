import 'package:flutter/material.dart';
import 'package:fypchillilah/services/firestore.dart'; // Import Firestore service
import 'editprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart'; // Import the homepage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  User? user = FirebaseAuth.instance.currentUser; // Get current user
  String fullName = '';
  String nickname = '';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page loads
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (user != null) {
      var userData = await firestoreService
          .getUserData(user!.uid); // Fetching user data from Firestore
      setState(() {
        fullName = userData['fullName'] ?? 'No Name';
        nickname = userData['nickname'] ?? 'No Nickname';
        email = userData['email'] ?? 'No Email';
        phone = userData['phone'] ?? 'No Phone Number';
      });
    }
  }

  // Navigate back to Homepage
  void _navigateToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Homepage()), // Replace 'Homepage' with your actual homepage class
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _navigateToHomePage, // Go back to Homepage
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              fullName.isNotEmpty
                  ? fullName
                  : 'Loading...', // Display the full name or loading message
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              nickname.isNotEmpty
                  ? '($nickname)'
                  : '(Loading...)', // Display nickname or loading message
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Flutter Developer',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, color: Colors.teal),
                SizedBox(width: 10),
                Text(
                  email.isNotEmpty ? email : 'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: Colors.teal),
                SizedBox(width: 10),
                Text(
                  phone.isNotEmpty ? phone : 'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                var updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage()), // Go to EditProfilePage
                );

                if (updatedData != null) {
                  setState(() {
                    fullName = updatedData['fullName'];
                    nickname = updatedData['nickname'];
                    email = updatedData['email'];
                    phone = updatedData['phone'];
                  });
                  firestoreService.updateUserData(
                      user!.uid, updatedData); // Update Firestore with new data
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
