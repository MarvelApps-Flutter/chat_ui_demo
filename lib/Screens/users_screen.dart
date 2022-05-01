import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatRoom.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController searchController = TextEditingController();
  var reference = FirebaseFirestore.instance.collection("users");
  Map<String, dynamic>? map;
  final FirebaseAuth auth = FirebaseAuth.instance;
  DocumentSnapshot? snap;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xfff5f7fb),
      // appBar: AppBar(
      //   leading: Padding(
      //     padding: EdgeInsets.fromLTRB(8, 8, 2, 8),
      //     child: CircleAvatar(
      //       radius: 25,
      //       backgroundColor: Colors.transparent,
      //       child: Image.asset(
      //         "assets/images/chat.png",
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //   ),
      //   backgroundColor: Color(0xfff5f7fb),
      //   elevation: 0,
      //   title: Text(
      //     "Users",
      //     style: TextStyle(color: Colors.black54),
      //   ),
      //   actions: [
      //     Icon(
      //       Icons.notifications,
      //       color: Colors.black,
      //     )
      //   ],
      // ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            buildSearchTextField(),
            SizedBox(
              height: 10,
            ),
            buildBody(),
          ],
        ),
      ),
    ));
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: map == null
          ? Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: StreamBuilder(
                stream: reference.snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  return ListView.separated(
                      separatorBuilder: (context, index) {
                        if (snap!['name'] != auth.currentUser!.displayName!) {
                          return Divider();
                        } else {
                          return Container();
                        }
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.hasData == true
                          ? snapshot.data!.docs.length
                          : 0,
                      itemBuilder: (context, index) {
                        snap = snapshot.data!.docs[index];
                        return buildItem(user: snap);
                      });
                },
              ),
            )
          : buildMapData(),
    );
  }

  Widget buildItem({DocumentSnapshot? user}) {
    if (user!['name'] != auth.currentUser!.displayName!) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: ListTile(
          onTap: () {
            print(auth.currentUser);
            if (user['name'] != auth.currentUser!.displayName!) {
              String roomId =
                  chatRoomId(auth.currentUser!.displayName!, user['name']);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatRoomId: roomId,
                    snapshotMap: user,
                  ),
                ),
              );
            }
          },
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/images/user.jpg"),
            backgroundColor: Colors.transparent,
          ),
          title: Text(
            user['name'],
            style: TextStyle(color: Colors.black),
          ),
          trailing: user['name'] != auth.currentUser!.displayName!
              ? Icon(
                  Icons.chat_outlined,
                  color: Colors.black,
                )
              : Container(
                  width: 10,
                ),
        ),
      );
    } else {
      return Container();
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Widget buildMapData() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          onTap: () {
            print(auth.currentUser);
            if (map!['name'] != auth.currentUser!.displayName!) {
              String roomId =
                  chatRoomId(auth.currentUser!.displayName!, map!['name']);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatRoomId: roomId,
                    map: map!,
                  ),
                ),
              );
            }
          },
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/images/user.jpg"),
            backgroundColor: Colors.transparent,
          ),
          title: Text(
            map!['name'],
            style: TextStyle(color: Colors.black),
          ),
          trailing: Icon(
            Icons.chat_outlined,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildSearchTextField() {
    return TextFormField(
      controller: searchController,
      cursorColor: Colors.black,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      onChanged: (query) {
        print("query is $query");
        if (query.length == 3) {
          searchUser(searchController.text.toString().trim());
        }
        if (query.length == 0) {
          setState(() {
            map = null;
          });
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),
        labelText: "Search",
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.all(Radius.circular(30))),
      ),
    );
  }

  searchUser(String text) {
    print("text is $text");
    reference
        .where("name", isNotEqualTo: text)
        .orderBy("name")
        .startAt([
          text,
        ])
        .endAt([text + '\uf8ff'])
        .get()
        .then((value) {
          print("value is ${value.docs}");
          setState(() {
            map = value.docs[0].data();
            print("map is $map");
          });
        });
  }
}
