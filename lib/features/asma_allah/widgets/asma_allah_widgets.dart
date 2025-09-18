// lib/features/asma_allah/widgets/asma_allah_widgets.dart
import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';

// ============================================================================
// AsmaAllahCard - بطاقة اسم من أسماء الله الحسنى (بدون أنيميشن)
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
    final color = item.getColor();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // الجزء الأيسر - الرقم والأيقونة
            Container(
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(ThemeConstants.radiusLg),
                  bottomRight: Radius.circular(ThemeConstants.radiusLg),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: ThemeConstants.space4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${item.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ThemeConstants.space2.h,
                  Icon(
                    item.getIcon(),
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
            
            // المحتوى
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الاسم
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    
                    ThemeConstants.space2.h,
                    
                    // المعنى
                    Text(
                      item.meaning,
                      style: context.bodyMedium,
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
      prefixIcon: const Icon(
        Icons.search,
        color: Color(0xFF6B46C1),
      ),
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                HapticFeedback.lightImpact();
                onClear();
              },
            )
          : null,
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
// AsmaAllahHeader - هيدر الصفحة (بدون أنيميشن)
// ============================================================================
class AsmaAllahHeader extends StatelessWidget {
  const AsmaAllahHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية المتدرجة
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6B46C1),
                Color(0xFF9F7AEA),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        
        // النمط الإسلامي
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(
              rotation: 0,
              color: Colors.white,
              patternType: PatternType.floral,
              opacity: 0.1,
            ),
          ),
        ),
        
        // المحتوى
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_purple500,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              ThemeConstants.space3.h,
              
              // العنوان
              const Text(
                'أسماء الله الحسنى',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              
              ThemeConstants.space2.h,
              
              // الوصف
              const Text(
                'له الأسماء الحسنى فادعوه بها',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// _CardPatternPainter - رسام النمط للبطاقة
// ============================================================================
class _CardPatternPainter extends CustomPainter {
  final Color color;
  
  _CardPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // رسم دوائر زخرفية
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      20,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.9),
      15,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}