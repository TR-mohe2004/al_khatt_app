import 'package:flutter/material.dart';
import '../utils/app_colors.dart';      // استيراد ملف الألوان
import '../utils/app_text_styles.dart';  // استيراد ملف الأنماط

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للحصول على أبعاد الشاشة بشكل أفضل
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // --- الجزء العلوي: الشعار (مؤقتاً) ---
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Icon(
                        Icons.directions_car, // أيقونة سيارة مؤقتة
                        size: 100,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // --- الجزء السفلي: نموذج الإدخال ---
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      decoration: const BoxDecoration(
                        color: AppColors.formBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // حقل رقم الهاتف
                          _buildPhoneField(),
                          const SizedBox(height: 20),
                          // حقل كلمة المرور
                          _buildPasswordField(),
                          // رابط "نسيت كلمة المرور؟"
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () { /* منطق نسيت كلمة المرور لاحقاً */ },
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(color: AppColors.secondaryText),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // زر تسجيل الدخول
                          _buildLoginButton(),
                          const SizedBox(height: 20),
                          // فاصل ونص وزر "إنشاء حساب"
                          _buildSignupSection(),
                          const Spacer(), // يأخذ أي مساحة متبقية في الأسفل
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- الويدجتس المنفصلة لتنظيم الكود ---

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: AppTextStyles.bodyText, // تطبيق نمط النص
      decoration: InputDecoration(
        labelText: 'رقم الهاتف',
        labelStyle: const TextStyle(color: AppColors.secondaryText),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12.0, right: 8.0),
              child: Text('+218', style: AppTextStyles.bodyText),
            ),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBrown, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: AppTextStyles.bodyText,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: const TextStyle(color: AppColors.secondaryText),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryText),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondaryText,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBrown, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () { /* منطق تسجيل الدخول لاحقاً */ },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('تسجيل الدخول', style: AppTextStyles.buttonText),
      ),
    );
  }

  Widget _buildSignupSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'ليس لديك حساب؟',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
        ),
        TextButton(
          onPressed: () { /* منطق الانتقال لصفحة الإنشاء لاحقاً */ },
          child: const Text(
            'إنشاء حساب',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
