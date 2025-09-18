// File: lib/features/asma_allah/extensions/asma_allah_extensions.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:athkar_app/app/themes/theme_constants.dart';
import '../models/asma_allah_model.dart';

extension AsmaAllahExtensions on AsmaAllahModel {
  /// لون مميز ثابت لكل اسم باستخدام 3 ألوان فقط
  Color getColor() {
    const palette = <Color>[
      ThemeConstants.primary,    // اللون الأساسي
      ThemeConstants.accent,     // اللون الثانوي
      ThemeConstants.tertiary,   // اللون الثالث
    ];
    final idx = (id >= 0 ? id : name.hashCode.abs()) % palette.length;
    return palette[idx];
  }

  /// اختيار أيقونة تقريبية حسب دلالة الاسم
  IconData getIcon() {
    final n = name;
    if (n.contains('رحم') || n.contains('رحيم')) return Icons.favorite;
    if (n.contains('عزيز') || n.contains('قوي')) return Icons.shield;
    if (n.contains('حكيم') || n.contains('عليم')) return Icons.auto_awesome;
    if (n.contains('سميع') || n.contains('بصير')) return Icons.visibility;
    if (n.contains('غفور') || n.contains('غفار')) return Icons.healing;
    if (n.contains('ملك') || n.contains('مالك')) return Icons.star;
    if (n.contains('خالق') || n.contains('بارئ')) return Icons.brush;
    if (n.contains('رزاق')) return Icons.card_giftcard;
    if (n.contains('حفيظ') || n.contains('حافظ')) return Icons.security;
    if (n.contains('كريم') || n.contains('وهاب')) return Icons.volunteer_activism;
    return Icons.star_outline;
  }
}