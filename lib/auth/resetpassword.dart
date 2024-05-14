import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _error;
  bool isShowPassword=true;
  bool isShowPassword1=true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.blue.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _newPasswordController,
              obscureText: isShowPassword,
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(209, 0, 0, 0),
              ),
              decoration: InputDecoration(
                hintText: "Enter your new password",
                labelText: "New Password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isShowPassword = !isShowPassword;
                    });
                  },
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    isShowPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid value.';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _confirmPasswordController,
              obscureText: isShowPassword1,
              decoration:  InputDecoration(labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isShowPassword1 = !isShowPassword1;
                    });
                  },
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    isShowPassword1 ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                if (_newPasswordController.text == _confirmPasswordController.text) {
                  try {
                    await _auth.currentUser!.updatePassword(_newPasswordController.text);
                    Navigator.pop(context);
                  } catch (e) {
                    setState(() {
                      _error = 'Failed to reset password: $e';
                    });
                  }
                } else {
                  setState(() {
                    _error = 'Passwords do not match';
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
