import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to handle user registration
  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      // Show an error message if passwords do not match
      _showError('Passwords do not match');
      return;
    }

    try {
      // Create a new user with email and password
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful registration, navigate to a new page (e.g., profile page)
      // You can replace this with the appropriate page
      Navigator.pushReplacementNamed(context, '/profilePage');
    } on FirebaseAuthException catch (e) {
      // Handle registration errors
      if (e.code == 'weak-password') {
        _showError('The password is too weak');
      } else if (e.code == 'email-already-in-use') {
        _showError('This email is already in use');
      } else {
        _showError('Error: ${e.message}');
      }
    } catch (e) {
      _showError('Something went wrong, please try again');
    }
  }

  // Method to display error messages
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Image above the email field
                Image.asset(
                  'lib/images/SignupIcon.png',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _registerUser, // Register the user when pressed
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
