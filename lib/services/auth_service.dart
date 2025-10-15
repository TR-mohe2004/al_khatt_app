import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream لمراقبة حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ✅ الـ method الصحيح اللي signup_screen بيستدعيه
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // إنشاء مستند المستخدم في Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'userName': name, // نفس الاسم
          'userType': userType,
          'phoneVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // تحديث رقم الهاتف بعد التحقق من OTP
  Future<void> updatePhoneNumber(String userId, String phoneNumber) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'phoneNumber': phoneNumber,
        'phoneVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل تحديث رقم الهاتف: ${e.toString()}';
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'فشل تسجيل الخروج: ${e.toString()}';
    }
  }

  // معالجة أخطاء Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (على الأقل 6 أحرف)';
      case 'operation-not-allowed':
        return 'العملية غير مسموح بها';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      default:
        return 'حدث خطأ: ${e.message ?? e.code}';
    }
  }

  // التحقق من حالة تسجيل الدخول
  bool get isSignedIn => currentUser != null;

  // الحصول على معلومات المستخدم من Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw 'فشل جلب بيانات المستخدم: ${e.toString()}';
    }
  }
}