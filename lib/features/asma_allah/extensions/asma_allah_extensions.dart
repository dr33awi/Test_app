// ============================================
// File: lib/features/asma_allah/extensions/asma_allah_extensions.dart
// ============================================
import 'package:flutter/material.dart';
import '../models/asma_allah_model.dart';

extension AsmaAllahExtensions on AsmaAllahModel {
  /// لون مميز ثابت لكل اسم (توافق واسع مع Flutter عبر withOpacity)
  Color getColor() {
    const palette = <Color>[
      Color(0xFF6B46C1),
      Color(0xFF9F7AEA),
      Color(0xFF5D7052),
      Color(0xFF7A8B6F),
      Color(0xFFB8860B),
      Color(0xFFDAA520),
      Color(0xFF8B6F47),
      Color(0xFFA68B5B),
    ];
    final idx = (id >= 0 ? id : name.hashCode.abs()) % palette.length;
    return palette[idx];
  }

  /// اختيار أيقونة تقريبية حسب دلالة الاسم (تجنب أيقونات غير متاحة)
  IconData getIcon() {
    final n = name;
    if (n.contains('رحم') || n.contains('رحيم')) return Icons.favorite;
    if (n.contains('عزيز') || n.contains('قوي')) return Icons.shield;
    if (n.contains('حكيم') || n.contains('عليم')) return Icons.auto_awesome;
    if (n.contains('سميع') || n.contains('بصير')) return Icons.visibility;
    if (n.contains('غفور') || n.contains('غفار')) return Icons.healing;
    if (n.contains('ملك') || n.contains('مالك')) return Icons.star; // أوسع توافقًا
    if (n.contains('خالق') || n.contains('بارئ')) return Icons.brush;
    if (n.contains('رزاق')) return Icons.card_giftcard;
    if (n.contains('حفيظ') || n.contains('حافظ')) return Icons.security;
    if (n.contains('كريم') || n.contains('وهاب')) return Icons.volunteer_activism;
    return Icons.star_outline;
  }
}
