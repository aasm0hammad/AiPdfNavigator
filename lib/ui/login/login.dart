import 'package:aipdfnavigator/routes/app_routes.dart';
import 'package:aipdfnavigator/ui/login/login%20bloc/login%20event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/user model/user_model.dart';
import '../../widget/ui helper.dart';
import '../home.dart';
import 'login bloc/login bloc.dart';
import 'login bloc/login state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController conPassController = TextEditingController();

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
                child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_outlined,
                        color: Color(0xff6A3EA1),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      UiHelper.CustomText(
                          text: isLogin ? "Back to Register" : "Back to Login",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff6A3EA1),
                          textAlign: TextAlign.left),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        isLogin ? "Login Account" : "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Create a new account to get started and enjoy seamless access.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
          
          
                      SizedBox(height: 30),
                      SizedBox(
                        height: 32,
                      ),
                      if (!isLogin)
                        UiHelper.customTextField(
                            validator: (v) {
                              if (v!.isEmpty) {
                                return "Enter your name";
                              } else {
                                return null;
                              }
                            },
                            controller: nameController,
                            hint: "Example: John Doe",
                            label: "Full Name"),
          
          
          
                      SizedBox(
                        height: 16,
                      ),
                      UiHelper.customTextField(
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Enter your Email!..";
                            } else {
                              return null;
                            }
                          },
                          controller: emailController,
                          hint: "Example: johndoe@gmail.com",
                          label: "Email Address"),
                      SizedBox(
                        height: 16,
                      ),
                      if (!isLogin)
                        UiHelper.customTextField(
                            validator: (v) {
                              if (v!.isEmpty) {
                                return "Enter your Phone!..";
                              } else {
                                return null;
                              }
                            },
                            controller: phoneController,
                            hint: "Example: 9874561233",
                            label: "Phone Number"),
          
                      SizedBox(
                        height: 16,
                      ),
                      UiHelper.customTextField(
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Enter Password!";
                            } else {
                              return null;
                            }
                          },
                          controller: passController,
                          hint: "********",
                          label: "Password",
                          obscureText: true),
                      if (!isLogin)
                        SizedBox(
                          height: 16,
                        ),
                      if (!isLogin)
                        UiHelper.customTextField(
                            validator: (v) {
                              if (v!.isEmpty) {
                                return "Enter confirm Password!";
                              } else {
                                return null;
                              }
                            },
                            controller: conPassController,
                            hint: "********",
                            label: "Confirm Password",
                            obscureText: true),
                      SizedBox(
                        height: 12,
                      ),
                      UiHelper.CustomText(
                          text: "Forgot Password",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff6A3EA1),
                          textAlign: TextAlign.left),
                      SizedBox(
                        height: 32,
                      ),
          
                      /// Register with email
          
                      BlocListener<RegisterBloc,RegisterState>(
                        listener: (context, state) {
                          if (state is RegisterLoadingState) {
                            isLoading = true;
                            setState(() {});
                          }
          
                          if (state is RegisterFailureState) {
                            isLoading = false;
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.errorMsg)));
                          }
                          if (state is RegisterSuccessState) {
                            isLoading = false;
                            setState(() {
                              isLogin = !isLogin;
                            });
                          }
                        },
                        child: isLogin
                            ? UiHelper.customButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      UserCredential userCred = await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: emailController.text,
                                              password: passController.text);
          
                                      if (userCred.user != null) {
                                        SharedPreferences pref =
                                            await SharedPreferences.getInstance();
                                        pref.setString("id", userCred.user!.uid);
          
                                      }
          
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text("Login Successfully !")));
          
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home()));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text("${e.toString()}")));
                                    }
          
                                    /// Normal with Model
                                    /* try {
                                FirebaseAuth mAuth = FirebaseAuth.instance;
          
                                UserCredential mUser =
                                    await mAuth.createUserWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passController.text);
          
                                if (mUser.user != null) {
                                  fireStore.collection("users").doc(mUser.user!.uid).set(
                                    UserModel(name: nameController.text, email: emailController.text, number: int.parse(phoneController.text)).toMap(),
                                  );
                                  print("uSer id: ${mUser.user!.uid}");
          
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Success")));
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                                }
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  print('The password provided is too weak.');
                                } else if (e.code == 'email-already-in-use') {
                                  print(
                                      'The account already exists for that email.');
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "The account already exists for that email.")));
                                }
                              } catch (e) {
                                print(e);
                              }*/
                                  }
                                },
                                text: Text("Login"),
                                color: Color(0xff6A3EA1),
                                textColor: Colors.white)
                            : UiHelper.customButton(
                                text: Text("Register"),
                                color: Color(0xff6A3EA1),
                                textColor: Colors.white,
                                onPressed: () {
                                  context.read<RegisterBloc>().add(
                                      RegisterUserEvent(
                                          newUserModel: UserModel(
                                              name: nameController.text,
                                              password: passController.text,
                                              email: emailController.text,
                                              number: int.parse(
                                                  phoneController.text))));
                                },
                              ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Center(
                          child: Text(
                        "or",
                        style: TextStyle(color: Colors.grey),
                      )),
                      SizedBox(
                        height: 16,
                      ),
          
                      ///Register with Google
                     /* UiHelper.customButton(
                          onPressed: () {
          
                            Navigator.pushReplacementNamed(context, AppRoutes.ROUTE_HOME);
                          },
                          text: Text(isLogin
                              ? "Login with Google"
                              : "Register with Google"),
                          color: Colors.white,
                          textColor: Color(0xff180E25)),*/
                      SizedBox(
                        height: isLogin ? 29 : 16,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                            /*  Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) => SignUp()));
                       */
                          },
                          child: UiHelper.CustomText(
                              text: isLogin
                                  ? "Don’t have any account? Register here"
                                  : "Already have an account? Login here",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff6A3EA1),
                              textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
                ),
              ),
        ));
  }
}
