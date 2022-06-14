import 'package:firebase_app/variables..dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseHelper {
  FirebaseHelper._();
  static final FirebaseHelper firebaseHelper = FirebaseHelper._();

  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static GoogleSignInAccount? googleUser;
  static GoogleSignIn googleSignIn = GoogleSignIn();

  Future<String> logInAnonymously() async {
    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        return "Your account is disabled...";
      } else {
        return "Unknown Error";
      }
    }
  }

  Future<String> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      Global.user = userCredential.user;

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<User?> signInWithGoogle() async {
    googleUser = await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await firebaseAuth.signInWithCredential(credential);

    return userCredential.user;
  }

  Future<void> logOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();

    Global.user = null;

  }
}
