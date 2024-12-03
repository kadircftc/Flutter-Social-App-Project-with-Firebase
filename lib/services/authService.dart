// ignore_for_file: file_names, unused_local_variable, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/models/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String activeUserId;

  UserModel? _createUser(User? user) {
    // ignore: unnecessary_null_comparison
    return user == null ? null : UserModel.firebasedenUret(user);
  }

  Stream<UserModel?> get statusFollower => _firebaseAuth
      .authStateChanges()
      .map((User? event) => _createUser(event!));

  Future<UserModel?> anonymousLogin() async {
    UserCredential authResult = await _firebaseAuth.signInAnonymously();
    return _createUser(authResult.user!);
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> signUpWithEmail(String email, String password) async {
    UserCredential loginCard = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    return _createUser(loginCard.user!);
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    UserCredential loginCard = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _createUser(loginCard.user!);
  }

  Future<void> logOut() {
    return _firebaseAuth.signOut();
  }

  Future<UserModel?> googleSignIn() async {
    GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuthCard =
        await googleAccount?.authentication;
    OAuthCredential passwordlessSignIn = GoogleAuthProvider.credential(
        idToken: googleAuthCard!.idToken,
        accessToken: googleAuthCard.accessToken);
    UserCredential loginCard =
        await _firebaseAuth.signInWithCredential(passwordlessSignIn);

    return _createUser(loginCard.user);
  }
}
