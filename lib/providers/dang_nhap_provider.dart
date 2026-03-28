import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DangNhapProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 1. Khởi tạo GoogleSignIn với Client ID (BẮT BUỘC cho nền tảng Web)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "600953862786-r4hget6vut32jdsv6aa241dhookpq5ku.apps.googleusercontent.com",
  );

  User? user;

  DangNhapProvider() {
    user = _auth.currentUser;
  }

  // Đăng nhập Email/Password
  Future<String?> dangNhap(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = credential.user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Đăng ký Email/Password
  Future<String?> dangKy(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = credential.user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Google Sign-In (Đã sửa để dùng instance _googleSignIn)
  Future<String?> dangNhapGoogle() async {
    try {
      // Sử dụng instance đã cấu hình clientId ở trên
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Đăng nhập Google bị hủy';

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      user = userCredential.user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      // Nếu lỗi trên Web thường là do popup bị chặn hoặc cấu hình thiếu
      return "Lỗi Google: ${e.toString()}";
    }
  }

  // Đăng xuất
  Future<void> dangXuat() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Sử dụng instance chung
    user = null;
    notifyListeners();
  }
}