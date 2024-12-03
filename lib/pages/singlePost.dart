// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/widgets/postCart.dart';

class SinglePost extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  const SinglePost(
      {super.key, required this.postId, required this.postOwnerId});

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  late Post singlePost;
  late UserModel? postOwner;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPost();
  }

  getPost() async {
    Post post = await FirestoreService()
        .getSinglePost(widget.postId, widget.postOwnerId);
    if (post != null) {
      UserModel? ownerPost =
          await FirestoreService().getUserById(post.postedId);

      setState(() {
        singlePost = post;
        postOwner = ownerPost;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          "Gönderi",
          style: TextStyle(color: Colors.black, fontFamily: 'SF'),
        ),
      ),
      body: isLoading != true
          ? PostCard(post: singlePost, user: postOwner!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
