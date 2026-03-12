import 'dart:io';

import 'package:aipdfnavigator/routes/app_routes.dart';
import 'package:aipdfnavigator/service/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {

  TextEditingController qController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  circleIcon(Icons.arrow_back_ios_new),

                  IconButton(
                    icon: Icon(Icons.upload_file),
                    onPressed: pickPdf,
                  ),

                  InkWell(
                    onTap: logout,
                    child: circleIcon(Icons.logout),
                  )
                ],
              ),
            ),

            Text(
              "# AI Chat Assistant",
              style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5),

            Text(
              "Ask anything to AI",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 15),

            /// CHAT LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance
                    .collection("UserChat")
                    .doc(uid)
                    .collection("chat")
                    .orderBy("time")
                    .snapshots(),

                builder: (context,snapshot){

                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator());
                  }

                  var chats = snapshot.data!.docs;

                  /// AUTO SCROLL BOTTOM
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  return ListView.builder(

                    controller: _scrollController,
                    padding: EdgeInsets.all(15),
                    itemCount: chats.length,

                    itemBuilder: (context,index){

                      var data = chats[index];

                      bool isUser = data["sender"] == "user";

                      return Container(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,

                        margin: EdgeInsets.symmetric(vertical:6),

                        child: Container(

                          constraints: BoxConstraints(maxWidth: 280),

                          padding: EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blue
                                : Colors.grey.shade300,

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Text(

                            isUser
                                ? data["question"]
                                : data["answer"],

                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// INPUT BAR
            Container(
              padding: EdgeInsets.symmetric(horizontal:15,vertical:10),
              margin: EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(25),
              ),

              child: Row(
                children: [

                  Expanded(
                    child: TextFormField(
                      controller: qController,
                      decoration: InputDecoration(
                        hintText: "Ask AI...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: askQuestion,
                  )

                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  /// ICON
  Widget circleIcon(IconData icon){
    return Container(
      height:40,
      width:40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12,blurRadius:10)
        ],
      ),
      child: Icon(icon,size:18),
    );
  }

  /// LOGOUT
  void logout() async{

    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("id");

    Navigator.pushReplacementNamed(context, AppRoutes.ROUTE_LOGIN);
  }

  /// ASK QUESTION
  void askQuestion() async{

    String question = qController.text.trim();

    if(question.isEmpty) return;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    /// USER MESSAGE SAVE
    await FirebaseFirestore.instance
        .collection("UserChat")
        .doc(uid)
        .collection("chat")
        .add({

      "question": question,
      "sender": "user",
      "time": DateTime.now()

    });

    qController.clear();

    /// AI RESPONSE
    String answer = await ApiService.getData(question);

    /// AI MESSAGE SAVE
    await FirebaseFirestore.instance
        .collection("UserChat")
        .doc(uid)
        .collection("chat")
        .add({

      "answer": answer,
      "sender": "ai",
      "time": DateTime.now()

    });
  }

  Future<void> pickPdf() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {

      File file = File(result.files.single.path!);

      await summarizePdf(file);
    }
  }



  Future<void> summarizePdf(File file) async {

    String summary = await ApiService.getPdfSummary(file);

    String uid = FirebaseAuth.instance.currentUser!.uid;

    /// USER MESSAGE
    await FirebaseFirestore.instance
        .collection("UserChat")
        .doc(uid)
        .collection("chat")
        .add({

      "question": "Summarize this PDF",
      "sender": "user",
      "time": DateTime.now()

    });

    /// AI MESSAGE
    await FirebaseFirestore.instance
        .collection("UserChat")
        .doc(uid)
        .collection("chat")
        .add({

      "answer": summary,
      "sender": "ai",
      "time": DateTime.now()

    });
  }

}