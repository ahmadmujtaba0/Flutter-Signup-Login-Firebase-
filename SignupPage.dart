import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_app/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool isLoading = false;

  Future<void> _registerUser(String email, String password) async {
    setState(() {
    isLoading = true; // Start loading when registration starts
  });

  try {
    // Create user with email and password using Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user details in Firestore under the Users collection
    await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Debug print to verify UID and Firestore operation
    print('User UID: ${userCredential.user!.uid}');
    print('Saving user data to Firestore for UID: ${userCredential.user!.uid}');

    // Check if the document was created successfully
    var doc = await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).get();
    if (doc.exists) {
      print('User data stored in Firestore: ${doc.data()}');
    } else {
      print('User data not found in Firestore!');
    }

    // Navigate to the LoginPage after successful signup
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Clears previous routes
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'email-already-in-use') {
      errorMessage = 'This email is already registered. Please log in.';
    } else if (e.code == 'weak-password') {
      errorMessage = 'The password is too weak. Please choose a stronger password.';
    } else {
      errorMessage = 'Signup failed: ${e.message}';
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Signup button container
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
                onPressed: isLoading
                ? null // Disable button when loading
                : () async {
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();

                  // Simple validation
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return; // Exit the function if validation fails
                  }

                  // Call your register user method
                  await _registerUser(email, password);
                },
                child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Change color to match your theme
                    )
                  : const Text('Sign Up', style: TextStyle(fontSize: 25, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                children: [
                  TextSpan(
                    text: 'Login',
                    style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
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
