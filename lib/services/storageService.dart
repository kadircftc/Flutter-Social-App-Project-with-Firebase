// ignore_for_file: prefer_final_fields, file_names, unused_field

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference _storage = FirebaseStorage.instance.ref();
  late String imageId;

  Future<String> postImageDownload(File imageFile) async {
    imageId = const Uuid().v4();
    UploadTask downloadManager =
        _storage.child("images/posts/post_$imageId.jpg").putFile(imageFile);
    TaskSnapshot snapshot = await downloadManager;
    String downloadedImageUrl = await snapshot.ref.getDownloadURL();
    return downloadedImageUrl;
  }

  Future<String> profileImageDownload(File? imageFile) async {
    imageId = const Uuid().v4();
    UploadTask downloadManager = _storage
        .child("images/profile/profile_$imageId.jpg")
        .putFile(imageFile!);
    TaskSnapshot snapshot = await downloadManager;
    String downloadedImageUrl = await snapshot.ref.getDownloadURL();
    return downloadedImageUrl;
  }

  void deletePostImage(String postImageUrl) {
    RegExp search = RegExp(r"post_.+\.jpg");
    var matchUrl = search.firstMatch(postImageUrl);
    String? fileName = matchUrl![0];
    if (fileName != null) {
      _storage.child("images/posts/$fileName").delete();
    }
  }

  void deleteProfileImage(String profileImageUrl) {
    RegExp search = RegExp(r"profile_.+\.jpg");
    var matchUrl = search.firstMatch(profileImageUrl);
    String? fileName = matchUrl![0];
    if (fileName != null) {
      _storage.child("images/profile/$fileName").delete();
    }
  }
}
