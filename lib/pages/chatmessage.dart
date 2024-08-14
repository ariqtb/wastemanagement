import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  late IO.Socket socket;
  TextEditingController messageController = TextEditingController();
  List<dynamic> messages = [];
  String test = '';
  bool chatFromPhone = false;

  late IOWebSocketChannel channel; //channel varaible for websocket
  bool connected = false; // boolean value to track connection status

  String myid = "222"; //my id
  String recieverid = "111"; //reciever id
  // swap myid and recieverid value on another mobile to test send and recieve
  String auth = "chatapphdfgjd34534hjdfk"; //auth key

  List msglist = [];

  TextEditingController msgtext = TextEditingController();

  @override
  void initState() {
    connected = false;
    msgtext.text = "";
    // channelconnect();
    // checkFromPhone().then((res) {
    //   if (res == false) {
    //     // print("NIH RSPONSE: $res");
        connectToServer();
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // if (chatFromPhone == false) {
      socket.disconnect();
    // }
  }

  checkFromPhone() async {
    final prefs = await SharedPreferences.getInstance();
    String? getString = await prefs.getString("chat_history");
    if (getString != null) {
      List<dynamic> chathistory = jsonDecode(getString);
      print("WOYY $chathistory");
      if (mounted) {
        setState(() {
          chatFromPhone = true;
          chathistory.forEach((element) {
            messages.add(element);
          });
        });
      }
      return true;
    } else {
      print("WOYY2");
      return false;
    }
  }

  void connectToServer() async {
    final prefs = await SharedPreferences.getInstance();
    socket =
        IO.io('https://wastemngmt.fdvsdeveloper.repl.co', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.on('get history', (data) {
      print("nihh:gawgwa");
      // List<String> chatdata =
      //     data.map((element) => element.toString()).toList();
      print("INI ${data}");
      if (mounted) {
        setState(() {
          data.forEach((element) {
            messages.add(element['message']);
          });
          prefs.setString("chat_history", json.encode(messages));
        });
      }
      print("INI2 ${messages}");
    });
  }

  sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      print("nihh: $message");
      socket.emit('send_message', {'sender': 'usman', 'message': message});
      messageController.clear();
    }
  }

  channelconnect() {
    try {
      channel = IOWebSocketChannel.connect(
          "ws://wastemngmt.fdvsdeveloper.repl.co:3030/chat/$myid");
      channel.stream.listen(
        (message) {
          print("ini pesan: [$message]");
          setState(() {
            if (message == "connected") {
              connected = true;
              setState(() {});
              print("Connection establised.");
            } else if (message == "send:success") {
              print("Message send success");
              setState(() {
                msgtext.text = "";
              });
            } else if (message == "send:error") {
              print("Message send error");
            } else if (message.substring(0, 6) == "{'cmd'") {
              print("Message data");
              message = message.replaceAll(RegExp("'"), '"');
              var jsondata = json.decode(message);

              // msglist.add(MessageData(
              //   //on message recieve, add data to model
              //   msgtext: jsondata["msgtext"],
              //   userid: jsondata["userid"],
              //   isme: false,
              // ));
              setState(() {
                //update UI after adding data to message model
              });
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendmsg(String sendmsg, String id) async {
    if (connected == true) {
      String msg =
          "{'auth':'$auth','cmd':'send','userid':'$id', 'msgtext':'$sendmsg'}";
      setState(() {
        msgtext.text = "";
        //  msglist.add(msgtext: sendmsg, userid: myid, isme: true);
      });
      channel.sink.add(msg); //send message to reciever channel
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My ID: $myid - Chat App Example"),
          leading: Icon(Icons.circle,
              color: connected ? Colors.greenAccent : Colors.redAccent),
          //if app is connected to node.js then it will be gree, else red.
          titleSpacing: 0,
        ),
        body: Container(
            child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  // return ListTile(
                  //   title: Text(messages[index]),
                  // );
                  return Center(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 60, 0),
                        child: Card(
                            color: Colors.blueGrey[700],
                            //if its my message then, blue background else red background
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    "usman",
                                    style: TextStyle(color: Colors.white),
                                  )),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      messages[index],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                  );
                },
              ),
            ),
            // Positioned(
            //     top: 0,
            //     bottom: 70,
            //     left: 0,
            //     right: 0,
            //     child: Container(
            //         padding: EdgeInsets.all(15),
            //         child: SingleChildScrollView(
            //             child: Column(
            //               children: [
            //                 Expanded(
            //                   child: ListView.builder(
            //                     itemCount: 2,
            //                     itemBuilder: (context, index){
            //                       return Container(
            //                         child: Text("messages[index]"),
            //                       );
            //                     },
            //                   ),
            //                 )
            //               ],
            //           // children: [
            //           //   Container(
            //           //       child: Column(children: [
            //           //     Container(
            //           //         margin: EdgeInsets.only(
            //           //           //if is my message, then it has margin 40 at left
            //           //           left: 0,
            //           //           right: 40, //else margin at right
            //           //         ),
            //           //         child:
            //           //         Card(
            //           //             color: Colors.blueGrey[700],
            //           //             //if its my message then, blue background else red background
            //           //             child: Container(
            //           //               width: double.infinity,
            //           //               padding: EdgeInsets.all(15),
            //           //               child: Column(
            //           //                 crossAxisAlignment:
            //           //                     CrossAxisAlignment.start,
            //           //                 children: [
            //           //                   Container(
            //           //                       child: Text(
            //           //                     "usman",
            //           //                     style: TextStyle(color: Colors.white),
            //           //                   )),
            //           //                   Container(
            //           //                     margin: EdgeInsets.only(
            //           //                         top: 10, bottom: 10),
            //           //                     child: Text(
            //           //                       "Kamu dimana dengan siapa",
            //           //                       style:
            //           //                           TextStyle(color: Colors.white),
            //           //                     ),
            //           //                   ),
            //           //                 ],
            //           //               ),
            //           //             ))
            //           //             )
            //           //   ]))
            //           // ],
            //         )))),
            Container(
              //position text field at bottom of screen

              // bottom: 0, left: 0, right: 0,
              child: Container(
                  color: Colors.black12,
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.all(10),
                        child: TextField(
                          controller: messageController,
                          decoration:
                              InputDecoration(hintText: "Enter your Message"),
                        ),
                      )),
                      Container(
                          margin: EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: Icon(Icons.send),
                            onPressed: () {
                              sendMessage();
                              // if(msgtext.text != ""){
                              //   sendmsg(msgtext.text, recieverid); //send message with webspcket
                              // }else{
                              //   print("Enter message");
                              // }
                            },
                          ))
                    ],
                  )),
            )
          ],
        )));
  }
}
