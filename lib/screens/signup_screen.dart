import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfantest/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  String? _name;
  String? _email;
  String? _password;
  String? _confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'images/fanlogo.png',
                          width: 200,
                          height: 200,
                        ),
                        const SizedBox(height: 16),
                        _buildNameField(),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 16),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Sign Up'),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
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
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
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
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Name',
        prefixIcon: Icon(Icons.short_text),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        if (value.length < 3) {
          return 'Name must be at least 3 characters long';
        }
        if (value.length > 50) {
          return 'Name must not exceed 50 characters';
        }
        return null;
      },
      onSaved: (value) {
        _name = value;
      },
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
        if (!value.contains(RegExp(r'[A-Z]'))) {
          return 'Password must contain at least one uppercase letter';
        }
        if (!value.contains(RegExp(r'[a-z]'))) {
          return 'Password must contain at least one lowercase letter';
        }
        if (!value.contains(RegExp(r'[0-9]'))) {
          return 'Password must contain at least one number';
        }
        return null;
      },
      onSaved: (value) {
        _password = value;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirm Password is required';
        }
        if (value != _passwordController.text) {
          return 'Password and Confirm Password do not match';
        }
        return null;
      },
      onSaved: (value) {
        _confirmPassword = value;
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        );

        await userCredential.user!.sendEmailVerification();

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _name,
          'email': _email,
          'isEmailVerified': false,
        });

        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: 'Email verification has been sent',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (e.code == 'email-already-in-use') {
          Fluttertoast.showToast(
            msg: 'Email address is already in use',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Error: ${e.message}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }
}
