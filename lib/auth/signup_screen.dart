import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _signUp() async {
    // احفظ الـ context في متغير محلي قبل العملية الغير متزامنة
    final currentContext = context;
    
    // عرض مؤشر تحميل
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. إنشاء المستخدم في نظام المصادقة (Authentication)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? newUser = userCredential.user;

      if (newUser != null) {
        // 2. تخزين بيانات المستخدم الإضافية في قاعدة البيانات (Firestore)
        await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'name': _nameController.text.trim(),
          'email': newUser.email,
          'role': 'contractor', // مؤقتاً سنجعل كل المسجلين الجدد "مقاول"
          'createdAt': Timestamp.now(),
        });
      }

      // إخفاء مؤشر التحميل مع التحقق من أن الشاشة لا تزال نشطة
      if (currentContext.mounted) {
        Navigator.of(currentContext).pop();
      }

    } on FirebaseAuthException catch (e) {
      // إخفاء مؤشر التحميل مع التحقق
      if (currentContext.mounted) {
        Navigator.of(currentContext).pop();
        // عرض رسالة خطأ للمستخدم
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('إنشاء حساب'),
            ),
          ],
        ),
      ),
    );
  }
}