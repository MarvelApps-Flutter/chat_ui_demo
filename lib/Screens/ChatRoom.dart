import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';


class ChatScreen extends StatefulWidget {
  final DocumentSnapshot? snapshotMap;
  final String? chatRoomId;
  final Map? map;
  final dynamic maps;
  final String? senderName;
  ChatScreen({this.chatRoomId, this.snapshotMap, this.map,this.maps,this.senderName});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController messageController = TextEditingController();
  File? imageFile;
  var info;
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "sendto": (widget.senderName) != null ? widget.senderName : (widget.snapshotMap) != null ? widget.snapshotMap!['name'] : widget.map!['name'],
        "message": messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
        "is_read": false,
      };

      messageController.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  void initState() {
    super.initState();
    print("maps is ${widget.maps}");
    print("senderName is ${widget.senderName}");
    print("snapshotMap is ${widget.snapshotMap}");
    print("chatRoomId is ${widget.chatRoomId}");
    if(widget.senderName != null)
      {
        info = _firestore.collection("users").where("name", isEqualTo: widget.senderName).snapshots().listen((event) {
          print("event.docs[0]['uid']");
          print(event.docs[0]['uid']);
        });
      }

    //print("info is ${info['']}");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/images/user.jpg"),
          ),
        ),
        title: widget.senderName == null && info == null

        ? StreamBuilder<DocumentSnapshot>(
          stream: widget.snapshotMap != null
              ? _firestore
              .collection("users")
              .doc(widget.snapshotMap!['uid'])
              .snapshots()
              : _firestore.collection("users").doc(widget.map!['uid']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    widget.snapshotMap != null
                        ? Text(widget.snapshotMap!['name'], style: TextStyle(fontSize: 20,color: Colors.black),)
                        : Text(widget.map!['name'] ,style: TextStyle(fontSize: 20,color: Colors.black),),
                    // Text(
                    //   snapshot.data!['status'],
                    //   style: TextStyle(fontSize: 14,color: Colors.black),
                    // ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ) :  StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("users").where("name", isEqualTo: widget.senderName).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    // widget.snapshotMap != null
                    //     ? Text(widget.snapshotMap!['name'], style: TextStyle(fontSize: 20,color: Colors.black),)
                    //     :
                    Text( snapshot.data!.docs[0]['name'] ,style: TextStyle(fontSize: 20,color: Colors.black),),
                    // Text(
                    //   snapshot.data!.docs[0]['status'],
                    //   style: TextStyle(fontSize: 14,color: Colors.black),
                    // ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        )
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        //physics: BouncingScrollPhysics(),
        child: Container(
          color: Color(0xfff5f7fb),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                // height: size.height / 1.25,
                // width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        reverse: true,
                        //physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return messages(size, map, context);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              //Divider(),
              Container(
                // padding: EdgeInsets.all(5),
                // height: size.height / 10,
                // width: size.width,
                alignment: Alignment.center,

                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 150,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextField(
                            minLines: 1,
                            maxLines: null,
                            controller: messageController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                hintText: "Type a message...",
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                      // Spacer(),
                      SizedBox(
                          width: 70,
                          child: Row(
                            children: [
                              //Flexible(child:
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.perm_media_outlined,
                                    color: Colors.grey[300]),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.attachment,
                                    color: Colors.grey[300]),
                              )
                            ],
                          )),
                      SizedBox(
                        width: 40,
                        child: CircleAvatar(
                          backgroundColor: Colors.tealAccent[700],
                          radius: 20,
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              onSendMessage();
                            },
                            icon: Icon(Icons.send),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Container(
              //   height: size.height / 10,
              //   width: size.width,
              //   alignment: Alignment.center,
              //   child: Container(
              //     height: size.height / 12,
              //     width: size.width / 1.1,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Container(
              //           height: size.height / 17,
              //           width: size.width / 1.3,
              //           child: TextField(
              //             controller: _message,
              //             decoration: InputDecoration(
              //                 suffixIcon: IconButton(
              //                   onPressed: () => getImage(),
              //                   icon: Icon(Icons.photo),
              //                 ),
              //                 hintText: "Send Message",
              //                 border: OutlineInputBorder(
              //                   borderRadius: BorderRadius.circular(8),
              //                 )),
              //           ),
              //         ),
              //         IconButton(
              //             icon: Icon(Icons.send), onPressed: onSendMessage),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.tealAccent[700],
        ),
        child: Text(
          map['message'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    )
        : Container(
      height: size.height / 2.5,
      width: size.width,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: map['sendby'] == _auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShowImage(
              imageUrl: map['message'],
            ),
          ),
        ),
        child: Container(
          height: size.height / 2.5,
          width: size.width / 2,
          decoration: BoxDecoration(border: Border.all()),
          alignment: map['message'] != "" ? null : Alignment.center,
          child: map['message'] != ""
              ? Image.network(
            map['message'],
            fit: BoxFit.cover,
          )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage("assets/images/user.png"),
        ),
      ),
      title: Column(
        children: [
          Text(
            "Roberta Sharp",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Text(
            "Active now",
            style: TextStyle(color: Colors.grey[300], fontSize: 15),
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.clear),
          color: Colors.black,
        )
      ],
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}


// class ChatRoom extends StatelessWidget {
//   final DocumentSnapshot? snapshotMap;
//   final String? chatRoomId;
//   final Map? map;
//   final dynamic maps;
//   final String? senderName;
//   ChatRoom({this.chatRoomId, this.snapshotMap, this.map,this.maps,this.senderName});
//
//   //final TextEditingController _message = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController messageController = TextEditingController();
//   File? imageFile;
//
//   Future getImage() async {
//     ImagePicker _picker = ImagePicker();
//
//     await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
//       if (xFile != null) {
//         imageFile = File(xFile.path);
//         uploadImage();
//       }
//     });
//   }
//
//   Future uploadImage() async {
//     String fileName = Uuid().v1();
//     int status = 1;
//
//     await _firestore
//         .collection('chatroom')
//         .doc(chatRoomId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendby": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       "time": FieldValue.serverTimestamp(),
//     });
//
//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
//
//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();
//
//       status = 0;
//     });
//
//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();
//
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .update({"message": imageUrl});
//
//       print(imageUrl);
//     }
//   }
//
//   void onSendMessage() async {
//     if (messageController.text.isNotEmpty) {
//       Map<String, dynamic> messages = {
//         "sendby": _auth.currentUser!.displayName,
//         "sendto": snapshotMap!['name'],
//         "message": messageController.text,
//         "type": "text",
//         "time": FieldValue.serverTimestamp(),
//       };
//
//       messageController.clear();
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .add(messages);
//     } else {
//       print("Enter Some Text");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("maps is $maps");
//     print("map is $map");
//     print("snapshotMap is $snapshotMap");
//     final size = MediaQuery.of(context).size;
//     print("chatRoomId is $chatRoomId");
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: CircleAvatar(
//             radius: 18,
//             backgroundImage: AssetImage("assets/images/user.jpg"),
//           ),
//         ),
//         title: StreamBuilder<DocumentSnapshot>(
//           stream: snapshotMap != null
//               ? _firestore
//                   .collection("users")
//                   .doc(snapshotMap!['uid'])
//                   .snapshots()
//               : _firestore.collection("users").doc(map!['uid']).snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.data != null) {
//               return Container(
//                 child: Column(
//                   children: [
//                     snapshotMap != null
//                         ? Text(snapshotMap!['name'], style: TextStyle(fontSize: 20,color: Colors.black),)
//                         : Text(map!['name'] ,style: TextStyle(fontSize: 20,color: Colors.black),),
//                     Text(
//                       snapshot.data!['status'],
//                       style: TextStyle(fontSize: 14,color: Colors.black),
//                     ),
//                   ],
//                 ),
//               );
//             } else {
//               return Container();
//             }
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         //physics: BouncingScrollPhysics(),
//         child: Container(
//           color: Color(0xfff5f7fb),
//           child: Column(
//             //crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 height: size.height / 1.25,
//                 width: size.width,
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: _firestore
//                       .collection('chatroom')
//                       .doc(chatRoomId)
//                       .collection('chats')
//                       .orderBy("time", descending: false)
//                       .snapshots(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.data != null) {
//                       return ListView.builder(
//                         itemCount: snapshot.data!.docs.length,
//                         reverse: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemBuilder: (context, index) {
//                           Map<String, dynamic> map = snapshot.data!.docs[index]
//                               .data() as Map<String, dynamic>;
//                           return messages(size, map, context);
//                         },
//                       );
//                     } else {
//                       return Container();
//                     }
//                   },
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(5),
//                 height: size.height / 10,
//                 width: size.width,
//                 alignment: Alignment.center,
//
//                 child: Container(
//                   height: size.height / 12,
//                   width: size.width / 1.1,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(30),
//                       color: Colors.white),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width - 150,
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 10),
//                           child: TextField(
//                             minLines: 1,
//                             maxLines: null,
//                             controller: messageController,
//                             decoration: InputDecoration(
//                               contentPadding: EdgeInsets.zero,
//                                 hintStyle: TextStyle(color: Colors.grey[400]),
//                                 hintText: "Type a message...",
//                                 border: InputBorder.none),
//                           ),
//                         ),
//                       ),
//                       // Spacer(),
//                       SizedBox(
//                           width: 70,
//                           child: Row(
//                             children: [
//                               //Flexible(child:
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 5),
//                                 child: Icon(Icons.perm_media_outlined,
//                                     color: Colors.grey[300]),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 5),
//                                 child: Icon(Icons.attachment,
//                                     color: Colors.grey[300]),
//                               )
//                             ],
//                           )),
//                       SizedBox(
//                         width: 40,
//                         child: CircleAvatar(
//                           backgroundColor: Colors.tealAccent[700],
//                           radius: 20,
//                           child: IconButton(
//                             color: Colors.white,
//                             onPressed: () {
//                               onSendMessage();
//                             },
//                             icon: Icon(Icons.send),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Container(
//               //   height: size.height / 10,
//               //   width: size.width,
//               //   alignment: Alignment.center,
//               //   child: Container(
//               //     height: size.height / 12,
//               //     width: size.width / 1.1,
//               //     child: Row(
//               //       mainAxisAlignment: MainAxisAlignment.center,
//               //       children: [
//               //         Container(
//               //           height: size.height / 17,
//               //           width: size.width / 1.3,
//               //           child: TextField(
//               //             controller: _message,
//               //             decoration: InputDecoration(
//               //                 suffixIcon: IconButton(
//               //                   onPressed: () => getImage(),
//               //                   icon: Icon(Icons.photo),
//               //                 ),
//               //                 hintText: "Send Message",
//               //                 border: OutlineInputBorder(
//               //                   borderRadius: BorderRadius.circular(8),
//               //                 )),
//               //           ),
//               //         ),
//               //         IconButton(
//               //             icon: Icon(Icons.send), onPressed: onSendMessage),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
//     return map['type'] == "text"
//         ? Container(
//             width: size.width,
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.tealAccent[700],
//               ),
//               child: Text(
//                 map['message'],
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )
//         : Container(
//             height: size.height / 2.5,
//             width: size.width,
//             padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: InkWell(
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ShowImage(
//                     imageUrl: map['message'],
//                   ),
//                 ),
//               ),
//               child: Container(
//                 height: size.height / 2.5,
//                 width: size.width / 2,
//                 decoration: BoxDecoration(border: Border.all()),
//                 alignment: map['message'] != "" ? null : Alignment.center,
//                 child: map['message'] != ""
//                     ? Image.network(
//                         map['message'],
//                         fit: BoxFit.cover,
//                       )
//                     : CircularProgressIndicator(),
//               ),
//             ),
//           );
//   }
//
//   Widget buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       leading: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: CircleAvatar(
//           radius: 18,
//           backgroundImage: AssetImage("assets/images/user.png"),
//         ),
//       ),
//       title: Column(
//         children: [
//           Text(
//             "Roberta Sharp",
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//           Text(
//             "Active now",
//             style: TextStyle(color: Colors.grey[300], fontSize: 15),
//           )
//         ],
//       ),
//       actions: [
//         IconButton(
//           onPressed: () {},
//           icon: Icon(Icons.clear),
//           color: Colors.black,
//         )
//       ],
//     );
//   }
// }
//
// class ShowImage extends StatelessWidget {
//   final String imageUrl;
//
//   const ShowImage({required this.imageUrl, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Container(
//         height: size.height,
//         width: size.width,
//         color: Colors.black,
//         child: Image.network(imageUrl),
//       ),
//     );
//   }
// }

//
