// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/comments.dart';
import 'package:socialapp/pages/profile.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/services/numberFormating.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final Post post;
  final UserModel user;
  const PostCard({super.key, required this.post, required this.user});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _likes = 0;
  int _commentsCount = 0;
  bool _uLiked = false;

  late String _activeUserId;
  late String likesPost = "";

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    _activeUserId =
        Provider.of<AuthService>(context, listen: false).activeUserId;
    _likes = widget.post.likeCount;
    likeExists();
    commentCount();
    likesFormat();
  }

  commentCount() async {
    int commentCount = await FirestoreService().getCommentCount(widget.post);
    if (mounted) {
      setState(() {
        _commentsCount = commentCount;
      });
    }
  }

  likeExists() async {
    bool likeExists =
        await FirestoreService().isLikeExists(widget.post, _activeUserId);

    if (likeExists) {
      if (mounted) {
        setState(() {
          _uLiked = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _uLiked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          _postHeader(),
          postImage(),
          postFooter(),
        ],
      ),
    );
  }

  postchoice() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  "Gönderiyi silmek ister misiniz?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(
                thickness: 1,
                height: 20,
                color: Colors.grey,
              ),
              ListTile(
                title: Text(
                  "Gönderiyi sil",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                onTap: () {
                  FirestoreService().deletePost(_activeUserId, widget.post);
                  Navigator.pop(context);
                  deletePostSnackbar();
                },
              ),
              ListTile(
                title: Text(
                  "Vazgeç",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  likesFormat() {
    String likesPostNumber = NumberFormatFor().likeFormat(_likes);
    setState(() {
      likesPost = likesPostNumber;
    });
  }

  deletePostSnackbar() {
    var snackBar = SnackBar(
      content: Text("Gönderi başarıyla silindi!"),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _postHeader() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          profileOwnerId: widget.post.postedId,
                        )));
          },
          child: CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage: widget.user.avatar.isNotEmpty
                  ? NetworkImage(widget.user.avatar)
                  : AssetImage("assets/images/noProfile.png") as ImageProvider),
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            profileOwnerId: widget.post.postedId,
                          )));
            },
            child: Text(
              widget.user.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          widget.post.location.isNotEmpty
              ? Text(
                  "Konum:${widget.post.location}",
                  style: TextStyle(color: Colors.grey),
                )
              : SizedBox(
                  height: 0.0,
                )
        ],
      ),
      trailing: _activeUserId == widget.post.postedId
          ? IconButton(
              icon: Icon(
                Icons.more_vert,
              ),
              onPressed: () {
                postchoice();
              },
            )
          : SizedBox(
              height: 0.0,
            ),
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget postImage() {
    return GestureDetector(
      onDoubleTap: _changeLike,
      child: Hero(
        tag: "post_${widget.post.id}",
        child: Image.network(
          widget.post.postImageUrl,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget postFooter() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              !_uLiked
                  ? IconButton(
                      onPressed: () {
                        _changeLike();
                      },
                      icon: Icon(
                        Icons.favorite_border,
                        size: 35,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        _changeLike();
                      },
                      icon: Icon(
                        Icons.favorite,
                        size: 35,
                        color: Colors.red,
                      ),
                    ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => Comments(post: widget.post)));
                },
                icon: Icon(
                  Icons.comment,
                  size: 35,
                ),
              ),
            ],
          ),
          Text(
            "  $likesPost beğeni",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 3.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: widget.post.description.isNotEmpty
                ? RichText(
                    text: TextSpan(
                        text: widget.user.name + " ",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        children: [
                          TextSpan(
                              text: widget.post.description,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14))
                        ]),
                  )
                : SizedBox(
                    height: 0.0,
                  ),
          ),
          SizedBox(
            height: 2.0,
          ),
          _commentsCount > 0
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: ((context) => Comments(post: widget.post)),
                      ),
                    );
                  },
                  child: Text(
                    "  $_commentsCount yorumun tümünü gör",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        fontFamily: 'SF',
                        color: Colors.grey),
                  ),
                )
              : SizedBox(
                  height: 0.0,
                ),
          Text(
            "  ${timeago.format(widget.post.createdDate.toDate(), locale: "tr")}",
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                fontFamily: 'SF',
                color: Colors.grey),
          )
        ],
      ),
    );
  }

  void _changeLike() {
    if (_uLiked) {
      setState(() {
        _uLiked = false;
        _likes -= 1;
        likesFormat();
      });
      FirestoreService().likePostRemove(widget.post, _activeUserId);
    } else {
      setState(() {
        _uLiked = true;
        _likes += 1;
        likesFormat();
      });
      FirestoreService().likePost(widget.post, _activeUserId);
    }
  }
}
