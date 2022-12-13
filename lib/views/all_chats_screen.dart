import 'package:chat_app/views/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authentication/methods.dart';
import '../../model/chat_model.dart';
import 'chat_room.dart';
import 'users_screen.dart';

class AllChatsScreen extends StatefulWidget {
  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> with SingleTickerProviderStateMixin{
  TextEditingController searchController = TextEditingController();
  String? roomId;
  QuerySnapshot? reference;
  Map<String , dynamic>? map;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List usersData = [];
  List<ChatModel> chatLists = [];
  List chatLists1 = [];
  List<ChatModel> chatModelList = [];
  QuerySnapshot? snap;
  List names = [];
  var uniqueList;
  TabController? tabController;
  var counts;
  Future<List> getData() async
  {
    reference = await FirebaseFirestore.instance.collection("users").get();
    print("reference is $reference");
    final allData = reference!.docs.map((doc) => doc.data()).toList();
    print("allData is $allData");
    usersData = allData;
    print("usersData is $usersData");
    for(int i = 0 ; i < usersData.length ; i++)
    {
      print(usersData[i]['name']);
      String roomId = chatRoomId(
          auth.currentUser!.displayName!,
          usersData[i]['name']);
      print("roomId is $roomId");
      QuerySnapshot snap = await FirebaseFirestore.instance.collection("chatroom").doc(roomId).collection("chats").orderBy("time", descending: false).get();

      if(snap.size != 0)
        {
          chatLists1 = snap.docs.map((e) => e.data()).toList();
          print("chatLists1.length is ${chatLists1.length}");
          for(int i = 0 ; i < chatLists1.length ; i++)
            {
              ChatModel model = ChatModel();
              model.time = chatLists1[i]['time'].toDate();
              model.message = chatLists1[i]['message'];
              model.type = chatLists1[i]['type'];
              model.sendBy = chatLists1[i]['sendby'];
              model.sendto = chatLists1[i]['sendto'];
              model.isRead = chatLists1[i]['is_read'];
              model.count = chatLists1.where((element) => element['is_read'] == false).length;
              print("model.count is ${model.count}");
              model.roomId = roomId;
             chatModelList.add(model);

             print("chatModelList is ${chatModelList.length}");
            }
          counts = chatModelList.where((element) => element.isRead == false).length;

          print("counts is $counts");
          uniqueList = chatLists1.toSet().toList();
         // uniqueList.sort((a,b)=> a["time"].compareTo(b["time"]));
          print("uniqueList is $chatModelList");
          print("uniqueList.last is ${chatModelList.last}");
          //chatLists.add(uniqueList.first);
          if(!chatLists.contains(chatModelList.last))
            {
              chatLists.add(chatModelList.last);

            }
          // for(int i = 0 ; i < chatLists.length ; i++)
          //   {
          //     ChatModel
          //     chatLists.add(value)
          //   }
        }
        }

    print("chatLists is $chatLists");
    return chatLists.toSet().toList();
  }

  int index = 0;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      index = tabController!.index;
      setState(() {
        print("index is $index");
        if(index == 0)
          {
            chatLists.clear();
            chatModelList.clear();
            getData();
          }
      });

    });
  }
  
  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xfff5f7fb),
          appBar: AppBar(
            leading: Padding(
              padding: EdgeInsets.fromLTRB(8,8,2,8),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                child: Image.asset("assets/images/chat.png", fit: BoxFit.cover,),
              ),
            ),
            backgroundColor: Color(0xfff5f7fb),
            elevation: 0,
            bottom: TabBar(
              controller: tabController,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
               // onTap: (value){
               //  print("value is $value");
               //  if(value == 0)
               //    {
               //      setState(() {
               //        print("Chats");
               //        chatLists.clear();
               //        chatModelList.clear();
               //        getData();
               //      });
               //    }
               // },
              tabs: [
                Tab(text: "Chats",),
                Tab(text: "Users",),
                //Tab(text: "Profile",),
              ],),
            title: Text("E-Chats", style: TextStyle(color: Colors.black),),
            actions: [
              PopupMenuButton(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "assets/images/three_dots.png",
                    height: 15,
                    width: 22,
                  ),
                ),
                onSelected: (choose) async {
                  if (choose == "View Profile") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(

                            )));
                  } else if (choose == "Logout") {
                    logOut(context);
                  }
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem(
                        value: "View Profile",
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 17,
                                color: Colors.black,
                              ),
                            ),
                            Text('View Profile')
                          ],
                        )),
                    PopupMenuItem(
                        value: "Logout",
                        child: Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                              child: Icon(
                                Icons.logout,
                                size: 17,
                                color: Colors.black,
                              ),
                            ),
                            Text('Logout')
                          ],
                        )),
                  ];
                },
              ),
              // IconButton(onPressed: (){
              //   if (FirebaseAuth.instance.currentUser != null) {
              //     FirebaseAuth.instance.signOut().then((value) {
              //       print("Signed Out");
              //       Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(builder: (context) => const LoginScreen()),
              //             (route) => false,
              //       );
              //     });
              //   }
              //   logOut(context);
              // },
              //     icon: Icon(Icons.logout,color: Colors.black,))

            ],
          ),
         body: TabBarView(
           controller: tabController,
           children: [
             Container(
               padding: EdgeInsets.all(8),
               child: SingleChildScrollView(
                 physics: ScrollPhysics(),
                 child: Column(
                   children: [
                     //buildSearchTextField(),
                     SizedBox(height: 10,),
                     buildBody(),
                   ],
                 ),
               ),
             ),
             UsersScreen(),
             //Container(),
           ],
         ),

          floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> UsersScreen()));
            },
            backgroundColor: Colors.tealAccent[700],
            elevation: 6,
            child: Icon(Icons.add),
          ),
        ));
  }

  Widget buildBody() {

    return
    SingleChildScrollView(
      // child:
      // Card(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20)
      //   ),
        child:
        FutureBuilder(
          future: getData(),
          builder: (
              BuildContext context,
              AsyncSnapshot snapshot,
              ) {
            if(snapshot.connectionState != ConnectionState.done)
              {
                print("circular");
                return Column(
                  children: [
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }
            if(snapshot.hasError)
              {
                print("error");
                return Text("Error");
              }

            if(snapshot.data.length != 0)
              {
                print("has data");
                if (snapshot.data != null) {
                  return ListView.separated(
                      separatorBuilder: (context, index){

                        print("snapshot length is ${snapshot.data.length}");
                        ChatModel chatModel = snapshot.data[index];
                        if(chatModel.sendto != auth.currentUser!.displayName!)
                        {
                          return Divider();
                        }
                        if(chatModel.sendto == auth.currentUser!.displayName! && chatModel.sendto != chatModel.sendBy)
                        {
                          return Divider();
                        }
                        else
                        {
                          return Container();
                        }
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                      snapshot.hasData == true ? snapshot.data!.length : 0,
                      itemBuilder: (context, index) {
                        // var c = snapshot.data;
                        // print("c is $c");
                        // var counts;
                        // print("snapshot.data.length is ${snapshot.data.length}");
                        // for(int i = 0 ; i < snapshot.data.length; i++)
                        // {
                        //   print("snapshot.data ${snapshot.data[i].isRead}");
                        //   counts = snapshot.data[i].isRead;
                        // }
                        // print("counts is $counts");
                        // var count = snapshot.data.where((c) => c.isRead).toList().length;
                        // print("count is $count");
                        //List a = snapshot.data[index];
                        snapshot.data.sort((ChatModel a, ChatModel b){ //sorting in ascending order
                          return b.time!.compareTo(a.time!);
                        });

                        ChatModel chatModel = snapshot.data[index];
                        if(chatModel.sendto != auth.currentUser!.displayName!)
                        {
                          return Container(

                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(20)
                              // ),
                              child: buildItem(user: chatModel,));
                        }
                        if(chatModel.sendto  == auth.currentUser!.displayName! && chatModel.sendto != chatModel.sendBy)
                        {
                          return Container(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(20)
                              // ),
                              child: buildItem(user: chatModel,));
                        }
                        else
                        {
                          return Container();
                        }

                      });
                }
                else{
                  print("in else part for no data but for if");
                  return Center(child: Text("No conversations yet"));

                }
              }
              else{
                print("in else part for no data");
                return Container(
                    child: Column(
                      children: [
                        Center(child: Text("No conversations yet")),
                      ],
                    ));
            }
          },
        ),
      //)
    ) ;
  }

  Widget buildItem({ChatModel? user})
  {
    return
      //count != 0 ?
    Padding(
      padding: EdgeInsets.all(8),
      //color: Colors.white,
      child: ListTile(
        onTap: () async {

          print(user!.roomId);

          // var a = ref.docs[0];
          // print("a is $a");
          // a.
          // var b = a.get("is_read");
          // print("b is $b");
          //data.docs;
          // await ref.update({
          //   "is_read" : true,
          //   "message" : user.message,
          //   "sendby" : user.sendBy,
          //   "sendto" : user.sendto,
          //   "time" : user.time,
          //   "type" : user.type
          // });

          //data.set();
          if(user.sendto != auth.currentUser!.displayName!)
            {
              String roomId = chatRoomId(
                  auth.currentUser!.displayName!,
                  user.sendto!);


              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatRoomId: roomId,
                    senderName : user.sendto,
                    //maps: user,
                  ),
                ),
              ).then((value) => {
                setState(() {
                  chatLists.clear();
                  print("chatLists length is ${chatLists.length}");
                  uniqueList.clear();
                  chatModelList.clear();
                   getData();
                })
              });
            }
          if(user.sendto == auth.currentUser!.displayName! && user.sendto != user.sendBy)
          {
            String roomId = chatRoomId(
                auth.currentUser!.displayName!,
                user.sendBy!);

            QuerySnapshot ref = await FirebaseFirestore.instance.collection("chatroom").doc(user.roomId).collection("chats").get();
            try{
              List<DocumentSnapshot> docss = ref.docs;
              print("docss is $docss");
              for(var doc in docss)
              {
                await doc.reference.update(
                    {
                      'is_read' : true
                    }
                );
              }
            }catch(e)
            {
              print(e.toString());
            }

            print("updated successfully");
            print("data is $ref");

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatRoomId: roomId,
                  senderName : user.sendBy,
                  //maps: user,
                ),
              ),
            ).then((value) => {
              setState(() {
                chatLists.clear();
                print("chatLists length is ${chatLists.length}");
                uniqueList.clear();
                chatModelList.clear();
                getData();
              })
            });
          }
        },
        leading: CircleAvatar(
         radius: 25,
         backgroundImage: AssetImage("assets/images/user.jpg"),
         backgroundColor: Colors.transparent,
       ),
        title: auth.currentUser!.displayName! == user!.sendto? Text(user.sendBy!,style: TextStyle(color: Colors.black),): Text(user.sendto!,style: TextStyle(color: Colors.black),),
        subtitle:  auth.currentUser!.displayName! == user.sendBy || user.count == 0 ? Text(user.message!,style: TextStyle(color: Colors.black),) : Text(user.message!,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        trailing:  auth.currentUser!.displayName! == user.sendBy || user.count == 0 ? Text("") : CircleAvatar(
          radius: 14,
            backgroundColor: Colors.tealAccent[700],
            child: Text(user.count.toString(),style: TextStyle(color: Colors.black),))
      ),
    ) ;
    //     : Padding(
    //   padding: EdgeInsets.all(8),
    //   //color: Colors.white,
    //   child: ListTile(
    //       onTap: (){
    //         print(auth.currentUser);
    //         if(user!.sendto != auth.currentUser!.displayName!)
    //         {
    //           String roomId = chatRoomId(
    //               auth.currentUser!.displayName!,
    //               user.sendto!);
    //
    //           Navigator.of(context).push(
    //             MaterialPageRoute(
    //               builder: (_) => ChatScreen(
    //                 chatRoomId: roomId,
    //                 senderName : user.sendto,
    //                 //maps: user,
    //               ),
    //             ),
    //           ).then((value) => {
    //             setState(() {
    //               chatLists.clear();
    //               print("chatLists length is ${chatLists.length}");
    //               uniqueList.clear();
    //               chatModelList.clear();
    //               getData();
    //             })
    //           });
    //         }
    //         if(user.sendto == auth.currentUser!.displayName! && user.sendto != user.sendBy)
    //         {
    //           String roomId = chatRoomId(
    //               auth.currentUser!.displayName!,
    //               user.sendBy!);
    //
    //           Navigator.of(context).push(
    //             MaterialPageRoute(
    //               builder: (_) => ChatScreen(
    //                 chatRoomId: roomId,
    //                 senderName : user.sendBy,
    //                 //maps: user,
    //               ),
    //             ),
    //           ).then((value) => {
    //             setState(() {
    //               chatLists.clear();
    //               print("chatLists length is ${chatLists.length}");
    //               uniqueList.clear();
    //               chatModelList.clear();
    //               getData();
    //             })
    //           });
    //         }
    //       },
    //       leading: CircleAvatar(
    //         radius: 25,
    //         backgroundImage: AssetImage("assets/images/user.jpg"),
    //         backgroundColor: Colors.transparent,
    //       ),
    //       title: auth.currentUser!.displayName! == user!.sendto? Text(user.sendBy!,style: TextStyle(color: Colors.black),): Text(user.sendto!,style: TextStyle(color: Colors.black),),
    //       subtitle: Text(user.message!,style: TextStyle(color: Colors.black),),
    //   ),
    // );
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Widget buildMapData()
  {
    return  Padding(
      padding: EdgeInsets.all(8),
      //color: Colors.white,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: ListTile(
          onTap: (){
            print(auth.currentUser);
            if(map!['name'] != auth.currentUser!.displayName!)
            {
              String roomId = chatRoomId(
                  auth.currentUser!.displayName!,
                  map!['name']);

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
          title: Text(map!['name'],style: TextStyle(color: Colors.black),),
          trailing: Icon(Icons.chat_outlined, color: Colors.black,),
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
      // onChanged: (query)
      // {
      //   print("query is $query");
      //   if(query.length == 3)
      //     {
      //        searchUser(searchController.text.toString().trim());
      //
      //     }
      //   if(query.length == 0)
      //     {
      //       setState(() {
      //         map = null;
      //       });
      //     }
      // },
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

  // searchUser(String text)
  // {
  //   print("text is $text");
  //   reference.where("name" , isNotEqualTo: text)
  //       .orderBy("name").startAt([text,]).endAt([text+'\uf8ff'])
  //       .get().then((value) {
  //     print("value is ${value.docs}");
  //     setState(() {
  //       map = value.docs[0].data();
  //       print("map is $map");
  //     });
  //
  //   });
  // }
}
