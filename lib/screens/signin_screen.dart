import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfantest/screens/forgot_password_screen.dart';
import 'package:flutterfantest/screens/home_screen.dart';
import 'package:flutterfantest/screens/signup_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _email;
  String? _password;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'images/fanlogo.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Log In'),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot password ?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
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

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: Icon(Icons.email),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Invalid email address';
        }
        return null;
      },
      onSaved: (value) {
        _email = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: Icon(Icons.lock),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
      onSaved: (value) {
        _password = value;
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        User? user = userCredential.user;
        if (user != null) {
          if (user.emailVerified) {
            // Update user data isEmailVerified to true in users firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'isEmailVerified': true,
            });

            // Redirect to Main
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            // Toast message that says 'please verify your account'
            Fluttertoast.showToast(
              msg: 'Please verify your account',
              toastLength: Toast.LENGTH_LONG,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
            msg: 'User not registered',
            toastLength: Toast.LENGTH_LONG,
          );
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
            msg: 'Email or password doen\'t match',
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(
            msg: e.code,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }
}
