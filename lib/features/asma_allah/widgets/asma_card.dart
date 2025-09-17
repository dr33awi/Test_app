// lib/features/asma_allah/widgets/asma_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';

class AsmaCard extends StatelessWidget {
  final AsmaAllahModel asmaAllah;
  final bool isGridView;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const AsmaCard({
    super.key,
    required this.asmaAllah,
    required this.isGridView,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B46C1).withValues(alpha: 0.9),
            const Color(0xFF9F7AEA).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Stack(
            children: [
              // محتوى البطاقة
              Padding(
                padding: const EdgeInsets.all(ThemeConstants.space4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // رقم الاسم
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          asmaAllah.id.toString().padLeft(2, '0'),
                          style: context.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: ThemeConstants.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    ThemeConstants.space3.h,
                    
                    // الاسم بالعربية
                    Text(
                      asmaAllah.name,
                      style: context.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: ThemeConstants.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    ThemeConstants.space2.h,
                    
                    // النطق
                    Text(
                      asmaAllah.transliteration,
                      style: context.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    ThemeConstants.space3.h,
                    
                    // المعنى
                    Text(
                      asmaAllah.meaning,
                      style: context.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: ThemeConstants.medium,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // زر المفضلة
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onFavoriteToggle();
                    },
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        asmaAllah.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            child: Row(
              children: [
                // رقم الاسم
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6B46C1),
                        Color(0xFF9F7AEA),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      asmaAllah.id.toString().padLeft(2, '0'),
                      style: context.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: ThemeConstants.bold,
                      ),
                    ),
                  ),
                ),
                
                ThemeConstants.space4.w,
                
                // معلومات الاسم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم والنطق
                      Row(
                        children: [
                          Text(
                            asmaAllah.name,
                            style: context.titleLarge?.copyWith(
                              fontWeight: ThemeConstants.bold,
                            ),
                          ),
                          ThemeConstants.space3.w,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ThemeConstants.space2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                            ),
                            child: Text(
                              asmaAllah.transliteration,
                              style: context.labelSmall?.copyWith(
                                color: const Color(0xFF6B46C1),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      ThemeConstants.space1.h,
                      
                      // المعنى
                      Text(
                        asmaAllah.meaning,
                        style: context.bodyMedium?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      
                      ThemeConstants.space2.h,
                      
                      // الشرح المختصر
                      Text(
                        asmaAllah.explanation,
                        style: context.bodySmall?.copyWith(
                          color: context.textSecondaryColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                ThemeConstants.space3.w,
                
                // أزرار الإجراءات
                Column(
                  children: [
                    // زر المفضلة
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onFavoriteToggle();
                      },
                      icon: Icon(
                        asmaAllah.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: asmaAllah.isFavorite 
                            ? const Color(0xFF6B46C1)
                            : context.textSecondaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    
                    // سهم التفاصيل
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.textSecondaryColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}