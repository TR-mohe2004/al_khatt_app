import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../services/otp_service.dart';
import '../services/firestore_service.dart';
import 'otp_verification_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;
  final String userType;

  const PhoneInputScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
    required this.userType,
  });

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final OTPService _otpService = OTPService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCountryCode = '+218'; // ليبيا افتراضياً

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // التحقق من صحة رقم الهاتف
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (value.length < 9) {
      return 'رقم الهاتف قصير جداً';
    }
    if (value.length > 10) {
      return 'رقم الهاتف طويل جداً';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'يجب أن يحتوي على أرقام فقط';
    }
    return null;
  }

  // إرسال OTP
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullPhoneNumber = _selectedCountryCode + _phoneController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // التحقق من عدم وجود الرقم مسبقاً
      final exists = await _firestoreService.isPhoneNumberExists(fullPhoneNumber);
      if (exists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'رقم الهاتف مسجل مسبقاً';
        });
        return;
      }

      // إرسال OTP
      await _otpService.sendOTP(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId) {
          setState(() {
            _isLoading = false;
          });

          // حفظ رقم الهاتف في Firestore (غير مُتحقق)
          _firestoreService.saveUser(
            uid: widget.userId,
            email: widget.email,
            name: widget.userName,
            phone: fullPhoneNumber,
            userType: widget.userType,
            phoneVerified: false,
          );

          // الانتقال لشاشة التحقق
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: fullPhoneNumber,
                verificationId: verificationId,
                userName: widget.userName,
                userId: widget.userId,
              ),
            ),
          );
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
        onAutoVerify: (credential) async {
          // في حالة التحقق التلقائي (نادر)
          setState(() {
            _isLoading = false;
          });

          await _firestoreService.updatePhoneVerification(
            uid: widget.userId,
            verified: true,
          );

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/success',
              arguments: {'userName': widget.userName},
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // الأيقونة
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.lightGold.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_iphone,
                      size: 50,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // العنوان
                Text(
                  'تأكيد رقم الهاتف',
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // الوصف
                Text(
                  'سنرسل لك رمز التحقق عبر رسالة نصية للتأكد من ملكيتك للرقم',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // حقل رقم الهاتف
                Text(
                  'رقم الهاتف (مطلوب)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اختيار كود الدولة
                    Container(
                      width: 100,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.whiteBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderGrey,
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textDark,
                          ),
                          style: AppTextStyles.bodyLarge,
                          dropdownColor: AppColors.whiteBackground,
                          items: const [
                            DropdownMenuItem(
                              value: '+218',
                              child: Center(child: Text('+218')),
                            ),
                            DropdownMenuItem(
                              value: '+966',
                              child: Center(child: Text('+966')),
                            ),
                            DropdownMenuItem(
                              value: '+20',
                              child: Center(child: Text('+20')),
                            ),
                            DropdownMenuItem(
                              value: '+213',
                              child: Center(child: Text('+213')),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // حقل الرقم
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        validator: _validatePhone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: '912345678',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                          filled: true,
                          fillColor: AppColors.whiteBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderGrey,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderGrey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGold,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.errorRed,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.errorRed,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // رسالة الخطأ
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.errorRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.errorRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // زر الإرسال
                CustomButton(
                  text: 'إرسال رمز التحقق',
                  onPressed: _isLoading ? null : _sendOTP,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 32),

                // ملاحظة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warningOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warningOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تنبيه مهم',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warningOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تأكد من إدخال رقم هاتف صحيح وفعّال، حيث سيتم استخدامه للتحقق من حسابك وإرسال الإشعارات المهمة.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}