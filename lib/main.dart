import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // تم التعليق عليه لأنه غير مستخدم حالياً
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- استيراد الملفات التي أنشأناها ---
import 'auth/login_screen.dart'; // استيراد شاشة تسجيل الدخول
import 'utils/app_colors.dart'; // استيراد ملف الألوان
// import 'utils/app_text_styles.dart'; // تم التعليق عليه لأنه غير مستخدم في هذا الملف

// --- تعريفات وهمية (مؤقتة) للملفات التي لم ننشئها بعد ---
// ✅ تم تصحيح أسماء المتغيرات لتبدأ بحرف صغير
const splashScreen = Center(child: CircularProgressIndicator());
const homeWrapper = Center(child: Text("Home Screen"));

void main() async {
  // التأكد من تهيئة فلاتر قبل تشغيل أي شيء
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Firebase (إذا كنت تستخدمه، إذا لا، يمكن إزالة هذا السطر)
  // await Firebase.initializeApp(); 
  
  // تشغيل التطبيق مع Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // إنشاء وتكوين الـ Router
    final router = GoRouter(
      // -- نقطة البداية للتطبيق (للتجربة) --
      initialLocation: '/login', 
      
      routes: [
        // تعريف المسارات التي يعرفها التطبيق
        GoRoute(
          path: '/splash',
          builder: (context, state) => splashScreen, // ✅ تم استخدام الاسم الصحيح
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(), // <-- هذه هي واجهتنا
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => homeWrapper, // ✅ تم استخدام الاسم الصحيح
        ),
      ],
    );

    // بناء التطبيق الرئيسي
    return MaterialApp.router(
      title: 'تطبيق الخط',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Tajawal', // <-- تطبيق الخط الافتراضي على كل التطبيق
        scaffoldBackgroundColor: AppColors.background,
        // يمكنك إضافة المزيد من إعدادات الثيم هنا
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
