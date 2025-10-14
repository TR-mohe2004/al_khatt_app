import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _verificationId;
  int? _resendToken;

  // إرسال OTP إلى رقم الهاتف
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // عند إرسال الكود بنجاح
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto verification completed');
          onAutoVerify(credential);
        },
        
        // عند فشل التحقق
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.message}');
          if (e.code == 'invalid-phone-number') {
            onError('رقم الهاتف غير صحيح');
          } else if (e.code == 'too-many-requests') {
            onError('محاولات كثيرة جداً. حاول لاحقاً');
          } else {
            onError(e.message ?? 'حدث خطأ في الإرسال');
          }
        },
        
        // عند إرسال الكود
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ Code sent to $phoneNumber');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // انتهاء المهلة
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Auto retrieval timeout');
          _verificationId = verificationId;
        },
        
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError('حدث خطأ غير متوقع');
    }
  }

  // التحقق من الكود المُدخل
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ OTP verified successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification failed: ${e.message}');
      if (e.code == 'invalid-verification-code') {
        throw 'الكود غير صحيح';
      } else if (e.code == 'session-expired') {
        throw 'انتهت صلاحية الكود. أعد المحاولة';
      } else {
        throw e.message ?? 'فشل التحقق';
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw 'حدث خطأ غير متوقع';
    }
  }

  // ربط رقم الهاتف بحساب موجود
  Future<void> linkPhoneToExistingUser({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw 'لا يوجد مستخدم مسجل دخول';

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await currentUser.linkWithCredential(credential);
      debugPrint('✅ Phone linked to user: ${currentUser.uid}');
    } catch (e) {
      debugPrint('❌ Error linking phone: $e');
      rethrow;
    }
  }

  // إعادة إرسال OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerify: (credential) {},
    );
  }

  // الحصول على VerificationId الحالي
  String? get currentVerificationId => _verificationId;
}