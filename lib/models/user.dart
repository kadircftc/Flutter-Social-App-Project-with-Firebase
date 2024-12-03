import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String name;
  final String surname;
  final String avatar;
  final String mail;
  final String about;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.avatar,
    required this.mail,
    required this.about,
  });

  factory UserModel.createUser(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return UserModel(
      id: doc.id,
      name: data?["userName"] ?? "",
      surname: data?["surname"] ?? "",
      avatar: data?["photoUrl"] ?? "",
      mail: data?["email"] ?? "",
      about: data?["about"] ?? "",
    );
  }
  factory UserModel.firebasedenUret(User user) {
    return UserModel(
        id: user.uid,
        name: user.displayName ?? "",
        surname: "null",
        mail: user.email ?? "",
        avatar: user.photoURL ?? "",
        about: "");
  }
}
