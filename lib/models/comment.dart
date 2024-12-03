import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String contents;
  final String userId;
  final Timestamp createdDate;

  Comment(
      {required this.id,
      required this.contents,
      required this.userId,
      required this.createdDate});

  factory Comment.createPost(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return Comment(
      id: doc.id,
      contents: data?["contents"] ?? "",
      userId: data?["userId"] ?? "",
      createdDate: data?["createdDate"] ?? "",
    );
  }
}
