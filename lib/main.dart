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

// --- إعدادات GoRouter النهائية والصحيحة ---
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
      final loggedIn = authState.value != null;
      final location = state.matchedLocation;

      if (authState.isLoading || authState.isRefreshing) {
        return '/splash'; // ابق في شاشة البداية أثناء التحميل
      }

      if (loggedIn) {
        // إذا كان المستخدم مسجلاً ويحاول الوصول لصفحات التسجيل أو البداية، وجهه للرئيسية
        if (location == '/login' || location == '/signup' || location == '/splash') {
          return '/home';
        }
      } else {
        // إذا لم يكن مسجلاً ويحاول الوصول لأي صفحة غير صفحات التسجيل أو البداية، وجهه لتسجيل الدخول
        if (location != '/login' && location != '/signup' && location != '/splash') {
          return '/login';
        }
      }
      
      // في كل الحالات الأخرى، ابق في مكانك
      return null;
    },
    // --- هذا هو السطر الذي تم تصحيحه بالطريقة المضمونة ---
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
