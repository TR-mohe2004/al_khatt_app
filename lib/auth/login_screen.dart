import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('شاشة تسجيل الدخول'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/signup');
              },
              child: const Text('ليس لدي حساب، إنشاء حساب جديد'),
            ),
          ],
        ),
      ),
    );
  }
}
