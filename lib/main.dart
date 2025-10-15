import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'firebase_options.dart';
import 'services/auth_service.dart';

// --- المسارات الصحيحة للشاشات ---
import 'screens/misc/splash_screen.dart';
import 'screens/home/home_wrapper.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/phone_input_screen.dart';
import 'auth/otp_verification_screen.dart';

// Riverpod Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _createRouter(ref);
    return MaterialApp.router(
      title: 'دالين',
      theme: ThemeData(primarySwatch: Colors.amber, fontFamily: 'Tajawal'),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- إعدادات GoRouter المُصلَحة ---
GoRouter _createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(
        path: '/phone-input',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PhoneInputScreen(
            userId: extra['userId']!,
            userName: extra['userName']!,
            email: extra['email']!,
            userType: extra['userType']!,
          );
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OTPVerificationScreen(
            phoneNumber: extra['phoneNumber']!,
            verificationId: extra['verificationId']!,
            userName: extra['userName']!,
            userId: extra['userId']!,
          );
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeWrapper()),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // ✅ التعديل الأساسي: السماح بشاشة Splash دائماً بدون إعادة توجيه
      if (location == '/splash') {
        return null; // لا تُعيد التوجيه من splash أبداً
      }

      // ✅ انتظار انتهاء التحميل قبل اتخاذ قرارات التوجيه
      if (authState.isLoading || authState.isRefreshing) {
        return null; // ابق في المكان الحالي حتى ينتهي التحميل
      }

      final loggedIn = authState.value != null;

      if (loggedIn) {
        // إذا كان المستخدم مسجلاً ويحاول الوصول لصفحات التسجيل، وجهه للرئيسية
        if (location == '/login' || location == '/signup') {
          return '/home';
        }
      } else {
        // إذا لم يكن مسجلاً ويحاول الوصول لأي صفحة محمية، وجهه لتسجيل الدخول
        final publicRoutes = ['/login', '/signup', '/splash'];
        if (!publicRoutes.contains(location)) {
          return '/login';
        }
      }
      
      return null;
    },
    refreshListenable: GoRouterRefreshStream(ref.read(authServiceProvider).authStateChanges),
  );
}

// كلاس مساعد لربط GoRouter مع Riverpod Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}