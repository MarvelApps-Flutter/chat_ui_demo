
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

import '../views/login_screen.dart';

//import '../libs/views/login_screen.dart';


Future<User?> createAccount(String name, String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future.delayed(Duration(seconds: 4));
  EasyLoading.show(status: 'Please Wait...');
  try {
    UserCredential userCrendetial = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    print("Account created Successfull");

    userCrendetial.user!.updateDisplayName(name);

    // var tempImage =
    // // ignore: deprecated_member_use
    // await ImagePicker.pickImage(
    //     source:
    //     ImageSource.camera);
    // setState(() {
    //   sampleImage = tempImage;
    // });
    // final postImageRef =
    // FirebaseStorage.instance
    //     .ref()
    //     .child("Profile Images");
    //
    // var timeKey = DateTime.now();
    //
    // final StorageUploadTask
    // uploadTask = postImageRef
    //     .child(
    //     timeKey.toString() +
    //         ".jpg")
    //     .putFile(sampleImage);
    // var imageUrl =
    // await (await uploadTask
    //     .onComplete)
    //     .ref
    //     .getDownloadURL();
    // String url = imageUrl.toString();
    // print("Image Url =" + url);

    await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "status": "Unavalible",
      "uid": _auth.currentUser!.uid,
      //"imageUrl" : url
    });

    return userCrendetial.user;
  } catch (e) {
    Future.delayed(Duration(seconds: 2));
    EasyLoading.showError('User does not exist');
    print("e is $e");
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    print(e);
    return null;
  }
}

Future logOut(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    await _auth.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    });
  } catch (e) {
    print("error");
  }
}
