import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DartPluginRegistrant {
  static void ensureInitialized() {
    // 여기에 아무 것도 안 넣어도 Firebase 플러그인 로딩이 강제됨
    Firebase.initializeApp();
  }
}
