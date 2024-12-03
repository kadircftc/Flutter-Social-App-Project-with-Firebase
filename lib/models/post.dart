import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String postImageUrl;
  final String description;
  final String postedId;
  final int likeCount;
  final String location;
  final Timestamp createdDate;

  Post(
      {required this.id,
      required this.postImageUrl,
      required this.description,
      required this.postedId,
      required this.likeCount,
      required this.location,
      required this.createdDate});

  factory Post.createPost(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return Post(
      id: doc.id,
      postImageUrl: data?["postImageUrl"] ?? "",
      description: data?["description"] ?? "",
      postedId: data?["postedId"] ?? "",
      likeCount: data?["likeCount"] ?? "",
      location: data?["location"] ?? "",
      createdDate: data?["createdDate"] ?? "",
    );
  }
}
