import 'package:chat_app/mixins/validate_mixin.dart';
import 'package:chat_app/model/user_object.dart';
import 'package:chat_app/utils/app_config.dart';
import 'package:chat_app/utils/app_text_styles.dart';
import 'package:chat_app/utils/shared_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import '../screens/all_chats_screen.dart';
//import '../libs/views/all_chats_screen.dart';
import '../views/all_chats_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with InputValidationMixin {
  final auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  bool isEmailErrorVisible = false;
  bool isPasswordErrorVisible = false;
  late AppConfig appC;
  String redirectUrl = 'https://www.youtube.com/callback';
  String clientId = '86n7nmswa9d9mu';
  String clientSecret = 'cFH2ZE9qEZw87Qvw';
  UserObject? user;
  @override
  Widget build(BuildContext context) {
    appC = AppConfig(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formGlobalKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: appC.rH(26),
                    width: appC.rW(60),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/headers.jpg"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  buildSizedBoxWidget(10),
                  const Text("Login Now", style: AppTextStyles.blackTextStyle),
                  buildSizedBoxWidget(13),
                  const Text(
                    "Please enter the details below to continue",
                    style: AppTextStyles.lightTextStyle,
                  ),
                  buildSizedBoxWidget(15),
                  buildEmailTextField(),
                  buildSizedBoxWidget(10),
                  buildPasswordTextField(),
                  buildSizedBoxWidget(15),
                  buildButtonWidget(context, "LOGIN", () {
                    if (formGlobalKey.currentState!.validate()) {
                      if (_emailController.text.toString().trim().length != 0 &&
                          _passwordController.text.toString().trim().length !=
                              0) {

                        logIn(_emailController.text.toString().trim(),
                            _passwordController.text.toString().trim()).then((user) {
                              print("user is $user");
                          if (user != null) {
                            print("Login Successfull");
                            // setState(() {
                            //   isLoading = false;
                            // });

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllChatsScreen()),
                                  (route) => false,
                            );
                            EasyLoading.showSuccess('Logged in Successfully...');
                            EasyLoading.dismiss();
                          }

                          if(user == null) {
                            print("login failed");
                            // Future.delayed(Duration(seconds: 4));
                            // EasyLoading.showError('User does not exist');
                            //print("Error ${error.toString()}");
                            EasyLoading.dismiss();
                            _emailController.clear();
                            _passwordController.clear();
                            print("login failed again");
                          }
                        }).onError((error, stackTrace) {
                          Future.delayed(Duration(seconds: 2));
                          EasyLoading.showError('User does not exist');
                          print("Error ${error.toString()}");
                          EasyLoading.dismiss();
                        });
                        // auth
                        //     .signInWithEmailAndPassword(
                        //     email: _emailController.text,
                        //     password: _passwordController.text)
                        //     .then((value) {
                        //   Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => HomeScreen()),
                        //         (route) => false,
                        //   );
                        //   // EasyLoading.showSuccess('Logged in Successfully...');
                        //   // EasyLoading.dismiss();
                        // }).onError((error, stackTrace) {
                        //   Future.delayed(Duration(seconds: 2));
                        //   //EasyLoading.showError('User does not exist');
                        //   print("Error ${error.toString()}");
                        //   //EasyLoading.dismiss();
                        // });
                      }
                    }
                  }),
                  //_buildSignInWithText(),
                  navigationTextWidget(
                      context, "Don't have account?",
                      SignUpScreen(),
                      "Register"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildSocialBtn(Function onTap, AssetImage logo) {
  //   return GestureDetector(
  //     onTap: () {
  //       onTap();
  //     },
  //     child: Container(
  //       height: 45.0,
  //       width: 45.0,
  //       decoration: BoxDecoration(
  //         image: DecorationImage(
  //           image: logo,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildSignupBtn() {
  //   return GestureDetector(
  //     onTap: () => print('Sign Up Button Pressed'),
  //     child: RichText(
  //       text: const TextSpan(
  //         children: [
  //           TextSpan(
  //             text: 'Don\'t have an Account? ',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //           TextSpan(
  //             text: 'Sign Up',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      cursorColor: Colors.black,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        labelText: "Enter Email",
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.3),
        border: OutlineInputBorder(
            borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      ),
      validator: (email) {
        if (isEmailValid(email!))
          return null;
        else
          return 'Enter a valid email address';
      },
    );
  }

  Widget buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      cursorColor: Colors.black,
      keyboardType: TextInputType.text,
      obscureText: true,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.grey,
        ),
        labelText: "Enter Password",
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.grey.withOpacity(0.3),
        border: OutlineInputBorder(
            borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      ),
      validator: (password) {
        if (isPasswordValid(password!))
          return null;
        else
          return 'Enter a valid password';
      },
    );
  }

  Future<User?> logIn(String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Future.delayed(Duration(seconds: 4));
    EasyLoading.show(status: 'Please Wait...');
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print("Login Sucessfull");
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((value) => userCredential.user!.updateDisplayName(value['name']));

      return userCredential.user;
    } catch (e) {
      Future.delayed(Duration(seconds: 2));
      EasyLoading.showError('User does not exist');
      print("e is $e");
      return null;
    }
  }

}


