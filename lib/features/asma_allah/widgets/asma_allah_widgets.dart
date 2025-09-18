// lib/features/asma_allah/widgets/asma_allah_widgets.dart
import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';

// Extension methods لإضافة الوظائف المطلوبة
extension AsmaAllahExtensions on AsmaAllahModel {
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

// ============================================================================
// EnhancedAsmaAllahCard - بطاقة محسنة لاسم من أسماء الله الحسنى
// ============================================================================
class EnhancedAsmaAllahCard extends StatelessWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;

  const EnhancedAsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.getColor();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: context.cardColor, // خلفية مسطحة بدون تدرج أو ظل
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${item.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                          fontFamily: 'Cairo',
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.meaning,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.isDarkMode ? Colors.white70 : Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// EnhancedAsmaAllahHeader - هيدر محسن للصفحة
// ============================================================================
class EnhancedAsmaAllahHeader extends StatelessWidget {
  const EnhancedAsmaAllahHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA), Color(0xFF6B46C1)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(
              rotation: 0, // ثابت بدون حركة
              color: Colors.white,
              patternType: PatternType.geometric,
              opacity: 0.08,
            ),
          ),
        ),
        // دوائر ثابتة بسيطة
        Positioned(
          left: 10,
          top: 40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      '﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Amiri'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// AsmaAllahCard - بطاقة اسم من أسماء الله الحسنى (الأصلية محسنة)
// ============================================================================
class AsmaAllahCard extends StatelessWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;
  
  const AsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return EnhancedAsmaAllahCard(
      item: item,
      onTap: onTap,
    );
  }
}

// ============================================================================
// AsmaAllahSearchBar - شريط البحث
// ============================================================================
class AsmaAllahSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  
  const AsmaAllahSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: 'ابحث في الأسماء أو المعاني...',
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      // تمت إزالة الأيقونات بناءً على الطلب
      filled: true,
      fillColor: context.isDarkMode 
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFF6B46C1).withValues(alpha: 0.05),
      borderColor: const Color(0xFF6B46C1).withValues(alpha: 0.2),
      focusedBorderColor: const Color(0xFF6B46C1),
    );
  }
}

// ============================================================================
// AsmaAllahHeader - هيدر الصفحة (الأصلي)
// ============================================================================
class AsmaAllahHeader extends StatelessWidget {
  const AsmaAllahHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const EnhancedAsmaAllahHeader();
  }
}