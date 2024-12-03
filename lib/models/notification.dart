import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  final String id;
  final String activityUserId;
  final String activityType;
  final String postId;
  final String postImage;
  final String content;
  final Timestamp createdDate;

  UserNotification(
      {required this.id,
      required this.activityUserId,
      required this.activityType,
      required this.postId,
      required this.postImage,
      required this.content,
      required this.createdDate});

  factory UserNotification.createNotification(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return UserNotification(
      id: doc.id,
      activityUserId: data?["activityUserId"] ?? "",
      activityType: data?["activityType"] ?? "",
      postId: data?["postId"] ?? "",
      postImage: data?["postImage"] ?? "",
      content: data?["content"] ?? "",
      createdDate: data?["createdDate"] ?? "",
    );
  }
}
