import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/all_chats_screen.dart';
import '../views/login_screen.dart';
// import '../libs/views/all_chats_screen.dart';
// import '../libs/views/login_screen.dart';
//import '../screens/all_chats_screen.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return AllChatsScreen();
    } else {
      return LoginScreen();
    }
  }
}
