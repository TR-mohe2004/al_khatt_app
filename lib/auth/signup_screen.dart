import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- استيراد الأدوات والخدمات الجديدة ---
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

// Riverpod Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // سنضيف متغير لنوع المستخدم لاحقاً، الآن سنثبته
  final String _userType = "driver"; // مثال: سائق

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- هذا هو المنطق الجديد والمهم ---
  Future<void> _signUpAndProceed() async {
    // التحقق من صحة المدخلات
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. استدعاء خدمة المصادقة لإنشاء الحساب
      final authService = ref.read(authServiceProvider);
      final UserCredential? userCredential = await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        userType: _userType, // تحديد نوع المستخدم
      );

      if (userCredential != null && userCredential.user != null) {
        // 2. إذا نجح إنشاء الحساب، انتقل لشاشة إدخال الهاتف
        if (mounted) {
          // استخدام GoRouter للانتقال مع تمرير البيانات
          context.go(
            '/phone-input',
            extra: {
              'userId': userCredential.user!.uid,
              'userName': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'userType': _userType,
            },
          );
        }
      }
    } catch (e) {
      // عرض رسالة الخطأ
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // إيقاف التحميل في كل الحالات
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // هنا يمكنك بناء الواجهة التي تريدها
    // سأستخدم واجهة بسيطة كمثال، يمكنك استبدالها بواجهتك الخاصة
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        backgroundColor: AppColors.primaryGold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text('مرحباً بك في دالين', style: AppTextStyles.heading1),
              const SizedBox(height: 10),
              Text('الرجاء إدخال بياناتك للمتابعة', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 40),

              // --- استخدام Custom Widgets ---
              CustomTextField(
                controller: _nameController,
                label: 'الاسم الكامل',
                hint: 'مثال: محمد علي',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال الإيميل' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                hint: '******',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'كلمة المرور قصيرة جداً' : null,
              ),
              const SizedBox(height: 20),

              // --- عرض رسالة الخطأ ---
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // --- استخدام CustomButton ---
              CustomButton(
                text: 'متابعة إلى التحقق من الهاتف',
                onPressed: _isLoading ? null : _signUpAndProceed,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟'),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
