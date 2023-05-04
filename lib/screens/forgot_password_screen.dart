import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfantest/screens/signin_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  String? _email;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPasswordPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
        // Password reset email sent successfully
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
            msg: 'User not registered',
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(
            msg: e.code,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
        );
      }

      Fluttertoast.showToast(
        msg: 'Reset link has been sent to your email',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _onLogInPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                  ElevatedButton(
                    onPressed: _onResetPasswordPressed,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Reset Password'),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onLogInPressed,
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
}
