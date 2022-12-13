import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var currentUserUid;
  var currentUserName;
  var currentUserEmail;
  // Future getData() async
  // {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   final User? user = auth.currentUser;
  //   currentUserUid = user!.uid;
  //   currentUserName = user.displayName;
  //   currentUserEmail = user.email;
  //   print("currentUserUid is $currentUserUid");
  //   print("currentUserName is $currentUserName");
  //   print("currentUserEmail is $currentUserEmail");
  // }

  @override
  initState() {
    super.initState();
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    currentUserUid = user!.uid;
    // getData().then((value) {
    //   setState(() {
    //     _nameController.text = currentUserName;
    //     _emailController.text = currentUserEmail;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.tealAccent[700],
          title: Text("Profile"),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection("users").doc(currentUserUid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              _nameController.text = snapshot.data!['name'];
              _emailController.text = snapshot.data!['email'];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: Stack(
                        fit: StackFit.expand,

                        // ignore: deprecated_member_use
                       // overflow: Overflow.visible,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            // child: CircleAvatar(
                            //   backgroundImage: NetworkImage(data.profile),
                            //   minRadius: 50,
                            //   maxRadius: 75,
                            // ),
                          ),
                          // ignore: deprecated_member_use
                          Positioned(
                              right: -12,
                              bottom: 0,
                              // ignore: deprecated_member_use
                              child: SizedBox(
                                height: 46,
                                width: 46,
                                // ignore: deprecated_member_use
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                         primary: Colors.tealAccent[700],
                                        side: BorderSide(color: Colors.white)),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              height: 130,
                                              child: Column(
                                                children: <Widget>[
                                                  ListTile(
                                                    leading:
                                                        Icon(Icons.camera_alt),
                                                    title: Text("camera"),
                                                    onTap: () async {
                                                      // ignore: deprecated_member_use
                                                      //var tempImage =
                                                      // ignore: deprecated_member_use
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
                                                      // String key = data.secretkey;
                                                      // FirebaseDatabase.instance
                                                      //     .reference()
                                                      //     .child('Registration/' + key)
                                                      //     .set({
                                                      //   'username': data.username,
                                                      //   'profile': url,
                                                      //   'mobile': data.mobile,
                                                      //   'email': data.email,
                                                      //   'password': data.userpassword,
                                                      //   'address': data.address,
                                                      //   'description': data.description,
                                                      //   'status': data.status
                                                      // });
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons
                                                        .photo_album_outlined),
                                                    title: Text("gallery"),
                                                    onTap: () async {
                                                      //var tempImage =
                                                      // ignore: deprecated_member_use
                                                      // await ImagePicker.pickImage(
                                                      //     source:
                                                      //     ImageSource.gallery);
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
                                                      // String key = data.secretkey;
                                                      // FirebaseDatabase.instance
                                                      //     .reference()
                                                      //     .child('Registration/' + key)
                                                      //     .set({
                                                      //   'username': data.username,
                                                      //   'profile': url,
                                                      //   'mobile': data.mobile,
                                                      //   'email': data.email,
                                                      //   'password': data.userpassword,
                                                      //   'address': data.address,
                                                      //   'description': data.description,
                                                      //   'status': data.status
                                                      // });
                                                    },
                                                  )
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                   
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    )),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // ignore: deprecated_member_use
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      // ignore: deprecated_member_use
                      child: TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Container(
                                    child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text("Enter name"),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 26.0),
                                              child: TextFormField(
                                                autofocus: true,
                                                controller: _nameController,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            onTap: () {},
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("cancel")),
                                                SizedBox(
                                                  width: 40,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      FirebaseFirestore.instance
                                                          .collection("users")
                                                          .doc(currentUserUid)
                                                          .update({
                                                        "name": _nameController
                                                            .text
                                                            .toString()
                                                            .trim()
                                                      });
                                                      // String key = data.secretkey;
                                                      // String name =
                                                      //     _nameController.text;
                                                      //
                                                      // FirebaseDatabase.instance
                                                      //     .reference()
                                                      //     .child('Registration/' + key)
                                                      //     .set({
                                                      //   'username': name,
                                                      //   'profile': data.profile,
                                                      //   'mobile': data.mobile,
                                                      //   'email': data.email,
                                                      //   'password': data.userpassword,
                                                      //   'address': data.address,
                                                      //   'description': data.description,
                                                      //   'status': data.status
                                                      // });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("save"))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                           style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                         primary: Colors.grey,
                                        side: BorderSide(color: Colors.black)),
                         
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.supervisor_account_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                  child: Text(
                                snapshot.data!['name'],
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                              Icon(Icons.edit)
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      // ignore: deprecated_member_use
                      child: TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Container(
                                    child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text("Add Email"),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 26.0),
                                              child: TextFormField(
                                                autofocus: true,
                                                controller: _emailController,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            onTap: () {},
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("cancel")),
                                                SizedBox(
                                                  width: 40,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      FirebaseFirestore.instance
                                                          .collection("users")
                                                          .doc(currentUserUid)
                                                          .update({
                                                        "email":
                                                            _emailController
                                                                .text
                                                                .toString()
                                                                .trim()
                                                      });
                                                      // String key = data.secretkey;
                                                      // String mobile =
                                                      //     _mobileController.text;
                                                      //
                                                      // FirebaseDatabase.instance
                                                      //     .reference()
                                                      //     .child('Registration/' + key)
                                                      //     .set({
                                                      //   'username': data.username,
                                                      //   'profile': data.profile,
                                                      //   'mobile': mobile,
                                                      //   'email': data.email,
                                                      //   'password': data.userpassword,
                                                      //   'address': data.address,
                                                      //   'description': data.description,
                                                      //   'status': data.status
                                                      // });
                                                      //
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("save"))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                            style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        primary: Colors.grey,
                                        side: BorderSide(color: Colors.black)),
                        
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Icon(
                                  Icons.mail_outline,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                  child: Text(
                                snapshot.data!['email'],
                                // data.mobile,
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                              Icon(Icons.edit)
                            ],
                          )),
                    ),
                  ],
                ),
              );

              //   Container(
              //   child: Column(
              //     children: [
              //       widget.snapshotMap != null
              //           ? Text(widget.snapshotMap!['name'], style: TextStyle(fontSize: 20,color: Colors.black),)
              //           : Text(widget.map!['name'] ,style: TextStyle(fontSize: 20,color: Colors.black),),
              //       // Text(
              //       //   snapshot.data!['status'],
              //       //   style: TextStyle(fontSize: 14,color: Colors.black),
              //       // ),
              //     ],
              //   ),
              // );
            } else {
              return Container();
            }
          },
        )
        //}),
        );
  }
}
