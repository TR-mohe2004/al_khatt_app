import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // Stream للاستماع لحالة المستخدم
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // التسجيل بـ Email/Password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      // إنشاء حساب
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // حفظ بيانات المستخدم الأساسية في Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'userType': userType,
        'phoneVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // تحديث اسم المستخدم
      await userCredential.user!.updateDisplayName(name);

      debugPrint('✅ User registered: ${userCredential.user!.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Registration error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw 'حدث خطأ غير متوقع';
    }
  }

  // تسجيل الدخول بـ Email/Password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ User logged in: ${userCredential.user!.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Login error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw 'حدث خطأ غير متوقع';
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw 'فشل تسجيل الخروج';
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw 'حدث خطأ غير متوقع';
    }
  }

  // حذف الحساب
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // حذف بيانات المستخدم من Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // حذف الحساب
        await user.delete();
        debugPrint('✅ Account deleted');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Delete account error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw 'حدث خطأ غير متوقع';
    }
  }

  // التحقق من البريد الإلكتروني
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('✅ Verification email sent');
      }
    } catch (e) {
      debugPrint('❌ Email verification error: $e');
      throw 'فشل إرسال رابط التحقق';
    }
  }

  // معالجة أخطاء Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'user-disabled':
        return 'الحساب معطل';
      case 'too-many-requests':
        return 'محاولات كثيرة. حاول لاحقاً';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة';
      case 'network-request-failed':
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return e.message ?? 'حدث خطأ غير معروف';
    }
  }

  // التحقق من حالة تسجيل الدخول
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // الحصول على UID المستخدم الحالي
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // الحصول على بيانات المستخدم من Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      return null;
    }
  }
}