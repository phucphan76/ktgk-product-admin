import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show VoidCallback;

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Preview mode: sign-out just calls this instead of Firebase.
  VoidCallback? demoSignOut;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() async {
    if (demoSignOut != null) return demoSignOut!();
    await _auth.signOut();
  }

  /// Vietnamese message for Firebase Auth error codes.
  static String messageFor(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Địa chỉ email không hợp lệ.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
          return 'Email hoặc mật khẩu không đúng. Vui lòng thử lại.';
        case 'too-many-requests':
          return 'Bạn đã thử quá nhiều lần. Vui lòng đợi một lúc rồi thử lại.';
        case 'network-request-failed':
          return 'Không có kết nối mạng. Kiểm tra Internet và thử lại.';
        case 'operation-not-allowed':
          return 'Đăng nhập bằng Email/Mật khẩu chưa được bật trong Firebase.';
        default:
          return 'Đăng nhập thất bại (${e.code}).';
      }
    }
    return 'Đã xảy ra lỗi: $e';
  }
}
