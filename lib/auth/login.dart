import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:logapp/auth/register.dart';
import 'package:logapp/auth/resetpassword.dart';

import '../home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isShowPassword=true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  const Padding(
                    padding: EdgeInsets.only(right: 250),
                    child: Text("LOGIN",style: TextStyle(
                        fontSize: 30
                    ),),
                  ),
                  SizedBox(height: 20,),
                  Image.asset('assets/images/loginbackg.jpg',),
                  SizedBox(height: 40,),
                  TextFormField(
                    controller: _emailController,
                    decoration:  InputDecoration(
                      labelText: 'Email',
                      hintText: "Enter your email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: isShowPassword,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      labelText: "Password",
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                        )
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid value.';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 185),
                    child: TextButton(
                      onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordPage()));
                      },
                      child: const Text("Forgot Password ?",style: TextStyle(
                          fontSize: 16
                      ),),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _login();
                      },
                      child: const Text('Login',style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue
                      ),),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("OR"),
                  const SizedBox(height: 15,),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text("Register",style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue
                      ),),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        String username = userDoc['uname'];
        String email = userDoc['email'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  HomePage(title: 'Image Labeler', onImage: (InputImage inputImage) {  },),
          ),
        );
      } catch (e) {
        print("Error during login: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
