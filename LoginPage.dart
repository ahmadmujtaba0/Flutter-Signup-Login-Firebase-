import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_login_app/SignupPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_app/todolist.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isLoading =false;

  Future<void> _loginUser(String email, String password) async {
    setState(() {
    isLoading = true; // Start loading when login starts
  });

  try {
    // Sign in the user with email and password
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if user exists in Firestore
    var doc = await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).get();
    if (doc.exists) {
      print('User data found: ${doc.data()}');
      // Navigate to the ToDoList page or any other page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ToDoList()),
      );
    } else {
      print('User data not found in Firestore!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not found. Please check your credentials.')),
      );
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided for that user.';
    } else {
      errorMessage = 'Login failed: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: ${e.toString()}')),
    );
  } finally {
    setState(() {
      isLoading = false; // End loading after attempt completes, success or failure
    });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top image container
            Container(
              width: w,
              height: h * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/blur.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Text fields container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Hello!", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                      labelText: 'Email',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password, color: Colors.blueAccent),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Login button container
            Container(
              alignment: Alignment.center,
              width: 130,
              height: 50,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/blur.jpg"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: TextButton(
                onPressed: () {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();
                  _loginUser(email, password);
                },
                child: const Text('Login', style: TextStyle(fontSize: 25, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            RichText(
              text: TextSpan(
                text: 'Don\'t have an account? ',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                children: [
                  TextSpan(
                    text: 'Create',
                    style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}