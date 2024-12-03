// ignore_for_file: file_names, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/models/notification.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/services/storageService.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime date = DateTime.now();

  Future<void> createuser(
      {id, email, username, photoUrl = "", about = "", token = ""}) async {
    await _firestore.collection("users").doc(id).set({
      "userName": username,
      "email": email,
      "about": about,
      "photoUrl": photoUrl,
      "createdDate": date,
      "token": token
    });
  }

  Future<UserModel?> getUserById(id) async {
    DocumentSnapshot doc = await _firestore.collection("users").doc(id).get();
    if (doc.exists) {
      UserModel user = UserModel.createUser(doc);
      return user;
    }
    return null;
  }

  Future<int> followerCount(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .doc(userId)
        .collection("kullanicininTakipcileri")
        .get();
    return snapshot.docs.length;
  }

  Future<int> followCount(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipEdilenler")
        .doc(userId)
        .collection("kullanicininTakipleri")
        .get();
    return snapshot.docs.length;
  }

  void editUser(
      {String? userId, String? about, String? userName, String photoUrl = ""}) {
    _firestore
        .collection("users")
        .doc(userId)
        .update({"about": about, "userName": userName, "photoUrl": photoUrl});
  }

  Future<void> createPost(
      {postImageUrl, description, createdUserId, location}) async {
    await _firestore
        .collection("posts")
        .doc(createdUserId)
        .collection("usersPosts")
        .add({
      "postImageUrl": postImageUrl,
      "description": description,
      "location": location,
      "postedId": createdUserId,
      "likeCount": 0,
      "createdDate": date
    });
  }

  Future<List<Post>> getPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("posts")
        .doc(userId)
        .collection("usersPosts")
        .orderBy("createdDate", descending: true)
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.createPost(doc)).toList();
    return posts;
  }

  Future<List<Post>> getFlowPosts(userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("akislar")
        .doc(userId)
        .collection("kullaniciAkisGonderileri")
        .orderBy("createdDate", descending: true)
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.createPost(doc)).toList();
    return posts;
  }

  Future<Post> getSinglePost(String postId, String postOwnerId) async {
    DocumentSnapshot doc = await _firestore
        .collection("posts")
        .doc(postOwnerId)
        .collection("usersPosts")
        .doc(postId)
        .get();

    Post post = Post.createPost(doc);
    return post;
  }

  Future<int> getCommentCount(Post post) async {
    QuerySnapshot snapshot = await _firestore
        .collection("comments")
        .doc(post.id)
        .collection("postComments")
        .get();

    return snapshot.docs.length;
  }

  Future<void> likePost(Post post, String activeUserId) async {
    DocumentReference docRef = _firestore
        .collection("posts")
        .doc(post.postedId)
        .collection("usersPosts")
        .doc(post.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Post post = Post.createPost(doc);
      int newLikeCount = post.likeCount + 1;

      docRef.update({"likeCount": newLikeCount});

      _firestore
          .collection("likesPost")
          .doc(post.id)
          .collection("postLikes")
          .doc(activeUserId)
          .set({});

      addNotification(
          activityUserId: activeUserId,
          profileOwnerId: post.postedId,
          activityType: "beğeni",
          post: post);
    }
  }

  likePostRemove(Post post, String activeUserId) async {
    DocumentReference docRef = _firestore
        .collection("posts")
        .doc(post.postedId)
        .collection("usersPosts")
        .doc(post.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Post post = Post.createPost(doc);
      int newLikeCount = post.likeCount - 1;

      docRef.update({"likeCount": newLikeCount});

      DocumentSnapshot docLike = await _firestore
          .collection("likesPost")
          .doc(post.id)
          .collection("postLikes")
          .doc(activeUserId)
          .get();

      if (docLike.exists) {
        docLike.reference.delete();
      }
    }
  }

  Future<bool> isLikeExists(Post post, String activeUserId) async {
    DocumentSnapshot docLike = await _firestore
        .collection("likesPost")
        .doc(post.id)
        .collection("postLikes")
        .doc(activeUserId)
        .get();

    if (docLike.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection("comments")
        .doc(postId)
        .collection("postComments")
        .orderBy("createdDate", descending: true)
        .snapshots();
  }

  void addComments({String? activeUserId, Post? post, String? content}) {
    _firestore
        .collection("comments")
        .doc(post!.id)
        .collection("postComments")
        .add(
            {"contents": content, "createdDate": date, "userId": activeUserId});

    addNotification(
        activityUserId: activeUserId!,
        profileOwnerId: post.postedId,
        activityType: "yorum",
        post: post,
        content: content);
  }

  Future<List<UserModel>> searchUser(String word) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .where("userName", isGreaterThanOrEqualTo: word)
        .get();

    List<UserModel> kullanicilar =
        snapshot.docs.map((doc) => UserModel.createUser(doc)).toList();
    return kullanicilar;
  }

  void followUser(String profileOwnerId, String activeUserId) {
    _firestore
        .collection("takipciler")
        .doc(profileOwnerId)
        .collection("kullanicininTakipcileri")
        .doc(activeUserId)
        .set({});

    _firestore
        .collection("takipEdilenler")
        .doc(activeUserId)
        .collection("kullanicininTakipleri")
        .doc(profileOwnerId)
        .set({});

    addNotification(
      activityUserId: activeUserId,
      profileOwnerId: profileOwnerId,
      activityType: "takip",
    );
  }

  void unfollowUser(String profileOwnerId, String activeUserId) {
    _firestore
        .collection("takipciler")
        .doc(profileOwnerId)
        .collection("kullanicininTakipcileri")
        .doc(activeUserId)
        .get()
        .then((DocumentSnapshot doc) {
      doc.reference.delete();
    });

    _firestore
        .collection("takipEdilenler")
        .doc(activeUserId)
        .collection("kullanicininTakipleri")
        .doc(profileOwnerId)
        .get()
        .then((DocumentSnapshot doc) {
      doc.reference.delete();
    });
  }

  Future<bool> isFollowExists(
      {String? profileOwnerId, String? activeUserId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipEdilenler")
        .doc(activeUserId)
        .collection("kullanicininTakipleri")
        .doc(profileOwnerId)
        .get();

    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isFollowBack(
      {String? profileOwnerId, String? activeUserId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipEdilenler")
        .doc(profileOwnerId)
        .collection("kullanicininTakipleri")
        .doc(activeUserId)
        .get();

    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<UserNotification>> getNotifications(String profileOwnerId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("userNotifications")
        .doc(profileOwnerId)
        .collection("usersNotifications")
        .orderBy("createdDate", descending: true)
        .limit(20)
        .get();

    List<UserNotification> notifications = [];
    snapshot.docs.forEach((DocumentSnapshot doc) {
      UserNotification notification = UserNotification.createNotification(doc);
      notifications.add(notification);
    });

    return notifications;
  }

  void addNotification(
      {required String activityUserId,
      required String profileOwnerId,
      required String activityType,
      String? content,
      Post? post}) {
    if (activityUserId == profileOwnerId) {
      return;
    }

    _firestore
        .collection("userNotifications")
        .doc(profileOwnerId)
        .collection("usersNotifications")
        .add({
      "activityUserId": activityUserId,
      "activityType": activityType,
      "content": content,
      "postId": post?.id ?? "",
      "postImage": post?.postImageUrl ?? "",
      "createdDate": date
    });
  }

  Future<void> deletePost(String activityUserId, Post post) async {
    await _firestore
        .collection("posts")
        .doc(activityUserId)
        .collection("usersPosts")
        .doc(post.id)
        .get()
        .then((DocumentSnapshot doc) => doc.reference.delete());

    QuerySnapshot commentSnapshot = await _firestore
        .collection("comments")
        .doc(post.id)
        .collection("postComments")
        .get();

    commentSnapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    QuerySnapshot notificationsSnapshot = await _firestore
        .collection("userNotifications")
        .doc(post.postedId)
        .collection("usersNotifications")
        .where("postId", isEqualTo: post.id)
        .get();

    notificationsSnapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    StorageService().deletePostImage(post.postImageUrl);
  }
}
