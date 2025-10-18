import 'package:flutter/material.dart';
import 'app_colors.dart';

// ملف مركزي لجميع أنماط النصوص
class AppTextStyles {
  // نمط نص الأزرار الرئيسية
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Tajawal',
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  // نمط النصوص العادية داخل التطبيق
  static const TextStyle bodyText = TextStyle(
    fontFamily: 'Tajawal',
    color: AppColors.primaryText,
    fontSize: 16,
  );

  // نمط نص زر "إنشاء حساب"
  static const TextStyle outlineButtonText = TextStyle(
    fontFamily: 'Tajawal',
    color: AppColors.primaryBrown,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
}
