// lib/features/asma_allah/models/asma_allah_model.dart
import 'package:flutter/material.dart';

/// نموذج أسماء الله الحسنى (مبسط)
class AsmaAllahModel {
  final int id;
  final String name;        // الاسم
  final String meaning;     // المعنى
  final String? reference;  // المرجع القرآني
  
  const AsmaAllahModel({
    required this.id,
    required this.name,
    required this.meaning,
    this.reference,
  });
  
  /// تحويل من JSON
  factory AsmaAllahModel.fromJson(Map<String, dynamic> json) {
    return AsmaAllahModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      meaning: json['meaning'] ?? '',
      reference: json['reference'],
    );
  }
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'meaning': meaning,
      'reference': reference,
    };
  }
  
  /// الحصول على اللون حسب الترتيب
  Color getColor() {
    // تدرج ألوان جميل لكل اسم
    final colors = [
      const Color(0xFF6B46C1), // بنفسجي
      const Color(0xFF9F7AEA), // بنفسجي فاتح
      const Color(0xFF5D7052), // أخضر زيتي
      const Color(0xFF7A8B6F), // أخضر زيتي فاتح
      const Color(0xFFB8860B), // ذهبي
      const Color(0xFFDAA520), // ذهبي فاتح
      const Color(0xFF8B6F47), // بني دافئ
      const Color(0xFFA68B5B), // بني فاتح
    ];
    
    return colors[id % colors.length];
  }
  
  /// الحصول على أيقونة
  IconData getIcon() {
    // أيقونات متنوعة حسب المعنى
    if (name.contains('رحم') || name.contains('رحيم')) return Icons.favorite;
    if (name.contains('عزيز') || name.contains('قوي')) return Icons.shield;
    if (name.contains('حكيم') || name.contains('عليم')) return Icons.auto_awesome;
    if (name.contains('سميع') || name.contains('بصير')) return Icons.visibility;
    if (name.contains('غفور') || name.contains('غفار')) return Icons.healing;
    if (name.contains('ملك') || name.contains('مالك')) return Icons.star_purple500;
    if (name.contains('خالق') || name.contains('بارئ')) return Icons.brush;
    if (name.contains('رزاق')) return Icons.card_giftcard;
    if (name.contains('حفيظ') || name.contains('حافظ')) return Icons.security;
    if (name.contains('كريم') || name.contains('وهاب')) return Icons.volunteer_activism;
    
    return Icons.star_outline;
  }
}