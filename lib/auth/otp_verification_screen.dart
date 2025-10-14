import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:go_router/go_router.dart'; // <--- Import مهم

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../services/otp_service.dart';
import '../services/firestore_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String userName;
  final String userId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.userName,
    required this.userId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final OTPService _otpService = OTPService();
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  bool _isResending = false;
  int _remainingSeconds = 300;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _errorMessage = 'الرجاء إدخال الكود كاملاً');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userCredential = await _otpService.verifyOTP(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );
      if (userCredential != null) {
        await _firestoreService.updatePhoneVerification(uid: widget.userId, verified: true);
        if (mounted) context.go('/home'); // <--- انتقال صحيح
      } else {
         if (mounted) setState(() => _errorMessage = "الكود الذي أدخلته غير صحيح.");
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "الكود الذي أدخلته غير صحيح. حاول مرة أخرى.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _otpController.clear();
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    try {
      await _otpService.resendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          if (mounted) {
            setState(() => _isResending = false);
            _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال الكود بنجاح'), backgroundColor: AppColors.successGreen),
            );
          }
        },
        onError: (error) {
          if (mounted) setState(() => _errorMessage = error);
        },
      );
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'فشل إعادة الإرسال. حاول مرة أخرى');
    } finally {
       if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: AppTextStyles.heading2.copyWith(color: AppColors.textDark),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text('التحقق من الهوية', style: AppTextStyles.heading1),
              const SizedBox(height: 12),
              Text('أدخل الرمز المكون من 6 أرقام الذي تم إرساله إلى رقمك:\n${widget.phoneNumber}', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: AppColors.primaryGold, width: 2))),
                  errorPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: AppColors.errorRed, width: 2))),
                  onCompleted: (pin) => _verifyOTP(),
                  autofocus: true,
                ),
              ),
              if (_errorMessage != null) Padding(padding: const EdgeInsets.only(top: 24), child: Text(_errorMessage!, style: const TextStyle(color: AppColors.errorRed), textAlign: TextAlign.center)),
              const SizedBox(height: 24),
              CustomButton(text: 'تحقق', onPressed: _isLoading ? null : _verifyOTP, isLoading: _isLoading),
              const SizedBox(height: 24),
              _remainingSeconds > 0
                  ? Text('إعادة الإرسال بعد: ${_formatTime(_remainingSeconds)}')
                  : TextButton(
                      onPressed: _isResending ? null : _resendOTP,
                      child: _isResending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إعادة إرسال الكود'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
