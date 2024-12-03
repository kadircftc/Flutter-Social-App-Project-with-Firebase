// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_field, unused_element, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/widgets/noDeleteFuture.dart';
import 'package:socialapp/widgets/postCart.dart';

class FlowPage extends StatefulWidget {
  const FlowPage({super.key});

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  List<Post> _gonderiler = [];

  _getFlowPosts() async {
    String activeUserId =
        Provider.of<AuthService>(context, listen: false).activeUserId;

    List<Post> gonderiler = await FirestoreService().getFlowPosts(activeUserId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getFlowPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SociaApp",
          style: TextStyle(fontFamily: 'SF'),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _getFlowPosts();
        },
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: _gonderiler.length,
            itemBuilder: (context, index) {
              Post post = _gonderiler[index];
              return NoDeleteFuture(
                future: FirestoreService().getUserById(post.postedId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: 0.0,
                    );
                  }
                  UserModel? user = snapshot.data;
                  return PostCard(post: post, user: user!);
                },
              );
            }),
      ),
    );
  }
}
