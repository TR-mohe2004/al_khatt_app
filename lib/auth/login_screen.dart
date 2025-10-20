import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;
      // لا تستخدم print في الكود النهائي، هذا فقط للتجربة
      // print('Email: $email, Password: $password'); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تسجيل الدخول...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          // تم وضع الخلفية هنا لتغطي الشاشة كلها
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/header_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- Header with Logo Only ---
                Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                  ),
                ),
                
                // --- Login Form Area ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildLoginForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'مرحباً بعودتك! الرجاء إدخال بياناتك.',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 32),
          
          // --- Email Field ---
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              labelStyle: TextStyle(color: Colors.white.withAlpha(200)),
              hintText: 'example@email.com',
              hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withAlpha(200)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withAlpha(150)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'الرجاء إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
            style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
          const SizedBox(height: 20),

          // --- Password Field ---
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              labelStyle: TextStyle(color: Colors.white.withAlpha(200)),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withAlpha(200)),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withAlpha(200),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withAlpha(150)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال كلمة المرور';
              }
              return null;
            },
            style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
          const SizedBox(height: 32),

          // --- Login Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFD4AF37), // Gold color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'دخول',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // لون النص أسود ليكون واضحاً على الخلفية الذهبية
                ),
              ),
            ),
          ),
          const SizedBox(height: 50), // مسافة إضافية في الأسفل
        ],
      ),
    );
  }
}
