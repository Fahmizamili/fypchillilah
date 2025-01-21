import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fypchillilah/pages/homepage.dart';
import 'package:fypchillilah/pages/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to handle login
  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Sign in the user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful login, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Homepage()), // Use your HomePage here
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors
      if (e.code == 'user-not-found') {
        _showError('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showError('Wrong password provided for that user.');
      } else {
        _showError('Error: ${e.message}');
      }
    } catch (e) {
      _showError('Something went wrong. Please try again.');
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

  // Navigate to the sign-up page
  void _navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
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

                // Image
                Image.asset(
                  'lib/images/farmericon.png', // Replace with your image path
                  height: 200,
                  width: 200,
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

                // Login Button
                ElevatedButton(
                  onPressed: _loginUser, // Call the login function
                  child: Text("Login"),
                ),
                SizedBox(height: 16),

                // Sign-up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Do not have an account? "),
                    GestureDetector(
                      onTap: () => _navigateToSignUp(context),
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
