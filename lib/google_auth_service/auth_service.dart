// Google 계정으로 Firebase에 로그인하기 위한 연동 클래스

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Google 로그인 실패: $e");
      return null;
    }
  }
}
