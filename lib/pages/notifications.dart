// ignore_for_file: prefer_const_constructors, unused_field, unused_local_variable, unnecessary_string_interpolations

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/notification.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/profile.dart';
import 'package:socialapp/pages/singlePost.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/widgets/noDeleteFuture.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<UserNotification> _userNotifications;
  late String _activeUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _activeUserId =
        Provider.of<AuthService>(context, listen: false).activeUserId;
    _getUserNotifications();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> _getUserNotifications() async {
    List<UserNotification> notifications =
        await FirestoreService().getNotifications(_activeUserId);
    if (mounted) {
      setState(() {
        _userNotifications = notifications;
        isLoading = false;
      });
    }
  }

  viewNotifications() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userNotifications.isEmpty) {
      return Center(
        child: Text("Henüz bildirim yok."),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.black,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: _getUserNotifications,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: ListView.builder(
          itemCount: _userNotifications.length,
          itemBuilder: (context, index) {
            UserNotification notfi = _userNotifications[index];
            return notificationIndex(notfi);
          },
        ),
      ),
    );
  }

  Widget notificationIndex(UserNotification userNotification) {
    String message = createMessage(userNotification.activityType);

    return NoDeleteFuture(
      future: FirestoreService().getUserById(userNotification.activityUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 0.0,
          );
        }

        UserModel? activityUser = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    blurStyle: BlurStyle.solid,
                  )
                ],
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: ListTile(
              leading: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ProfilePage(
                              profileOwnerId:
                                  userNotification.activityUserId)));
                },
                child: CircleAvatar(
                  backgroundImage: activityUser!.avatar.isNotEmpty
                      ? NetworkImage(activityUser.avatar)
                      : AssetImage("assets/images/noProfile.png")
                          as ImageProvider,
                ),
              ),
              title: RichText(
                text: TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => ProfilePage(
                                    profileOwnerId:
                                        userNotification.activityUserId)));
                      },
                    text: "${activityUser.name}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: " $message",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      userNotification.activityType == "yorum"
                          ? TextSpan(
                              text: "'${userNotification.content}'",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'SF'))
                          : TextSpan(text: "")
                    ]),
              ),
              trailing: notificationpostImage(
                userNotification.activityType,
                userNotification.postImage,
                userNotification.postId,
              ),
              subtitle: Text(timeago
                  .format(userNotification.createdDate.toDate(), locale: "tr")),
            ),
          ),
        );
      },
    );
  }

  notificationpostImage(String activityType, String postImage, String postId) {
    if (activityType == "takip") {
      return null;
    } else if (activityType == "yorum" || activityType == "beğeni") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SinglePost(
                        postId: postId,
                        postOwnerId: _activeUserId,
                      )));
        },
        child: Image.network(
          postImage,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  createMessage(String activityType) {
    if (activityType == "beğeni") {
      return "gönderini beğendi.";
    } else if (activityType == "takip") {
      return "seni takip etti.";
    } else if (activityType == "yorum") {
      return "gönderine yorum yaptı.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.white,
        title: Text(
          "Bildirimler",
          style: TextStyle(color: Colors.black, fontFamily: 'SF', fontSize: 25),
        ),
      ),
      body: viewNotifications(),
    );
  }
}
