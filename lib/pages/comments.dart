// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/comment.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final Post post;

  const Comments({super.key, required this.post});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _commentController = TextEditingController();
  late String activeUserId;
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        backgroundColor: Colors.white,
        title: Text(
          "Yorumlar",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [_showComments(), addComment()],
      ),
    );
  }

  _showComments() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getComments(widget.post.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Comment comment = Comment.createPost(snapshot.data!.docs[index]);
            return _commentIndex(comment);
          },
        );
      },
    ));
  }

  Widget _commentIndex(Comment comment) {
    return FutureBuilder(
        future: FirestoreService().getUserById(comment.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Center(
                  child: SizedBox(
                height: 0.0,
              )),
            );
          }

          UserModel? user = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: user!.avatar.isNotEmpty
                  ? NetworkImage(user.avatar)
                  : AssetImage("assets/images/noProfile.png") as ImageProvider,
            ),
            title: RichText(
                text: TextSpan(
                    text: "${user.name} ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                  TextSpan(
                      text: comment.contents,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ))
                ])),
            subtitle: Text(
                timeago.format(comment.createdDate.toDate(), locale: "tr")),
          );
        });
  }

  addComment() {
    return ListTile(
      trailing: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color:
              _commentController.text.isNotEmpty ? Colors.blue : Colors.white,
        ),
        child: IconButton(
          icon: Icon(
            Icons.send,
            color: _commentController.text.isEmpty ? Colors.grey : Colors.white,
          ),
          onPressed: _commentController.text.isEmpty ? null : _sendComment,
        ),
      ),
      title: CupertinoTextField(
        padding: EdgeInsets.all(10.0),
        placeholder: 'Yorum Yazın...',
        controller: _commentController,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: CupertinoColors.activeBlue, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _sendComment() {
    String activeUserId =
        Provider.of<AuthService>(context, listen: false).activeUserId;

    FirestoreService().addComments(
        activeUserId: activeUserId,
        post: widget.post,
        content: _commentController.text);

    _commentController.clear();
  }
}
