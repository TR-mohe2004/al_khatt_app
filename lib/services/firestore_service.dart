import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // حفظ أو تحديث بيانات المستخدم
  Future<void> saveUser({
    required String uid,
    required String email,
    required String name,
    required String phone,
    required String userType,
    required bool phoneVerified,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'userType': userType,
        'phoneVerified': phoneVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // <--- الطريقة الصحيحة لكتابتها

      debugPrint('✅ User data saved/updated for: $uid');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
      rethrow;
    }
  }

  // جلب بيانات المستخدم
  Future<DocumentSnapshot?> getUser(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      return null;
    }
  }

  // تحديث حالة التحقق من الهاتف
  Future<void> updatePhoneVerification({
    required String uid,
    required bool verified,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'phoneVerified': verified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Phone verification updated for: $uid');
    } catch (e) {
      debugPrint('❌ Error updating phone verification: $e');
      rethrow;
    }
  }

  // التحقق من وجود رقم الهاتف مسبقاً
  Future<bool> isPhoneNumberExists(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking phone number: $e');
      return false; // نفترض عدم وجوده في حالة الخطأ
    }
  }
}
