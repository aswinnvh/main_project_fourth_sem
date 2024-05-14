import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otpPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _unameController = TextEditingController();
  bool isShowPassword = true;

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.grey.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                ClipOval(
                  child: Image.asset(
                    'assets/images/login1.jpg',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: _unameController,
                  decoration:  InputDecoration(labelText: 'username',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)
                      )
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                      labelText: "email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)
                      )
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid email address.';
                    }
                    if (!RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30,),
                TextFormField(
                  controller: _passwordController,
                  obscureText: isShowPassword,
                  decoration: InputDecoration(
                    labelText: "password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
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
                    if (value.length < 8 || !RegExp(r'[0-9]').hasMatch(value) || !RegExp(r'[!@#$%^&*]').hasMatch(value)) {
                      return 'Password should contain a minimum of 8 characters, \n one number, and one special character.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30,),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      _register();
                    },
                    child: const Text('Register',style: TextStyle(
                        fontSize: 20
                    ),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uname':_unameController.text,
          'password':_passwordController.text,
          'email':_emailController.text
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered successfully")));
        await userCredential.user!.sendEmailVerification();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(email: _emailController.text),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error:$e")));
      }
    }
  }
}
