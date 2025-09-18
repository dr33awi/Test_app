// lib/features/asma_allah/widgets/asma_allah_widgets.dart
import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';
import 'dart:math' as math;

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
class EnhancedAsmaAllahCard extends StatefulWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;
  
  const EnhancedAsmaAllahCard({
    super.key,
    required this.item,
    required this.onTap,
  });
  
  @override
  State<EnhancedAsmaAllahCard> createState() => _EnhancedAsmaAllahCardState();
}

class _EnhancedAsmaAllahCardState extends State<EnhancedAsmaAllahCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.item.getColor();
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.cardColor,
                    context.isDarkMode 
                        ? color.withValues(alpha: 0.1)
                        : color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed 
                      ? color
                      : color.withValues(alpha: 0.3),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: _isPressed ? 0.3 : 0.15),
                    blurRadius: _isPressed ? 15 : 10,
                    offset: Offset(0, _isPressed ? 6 : 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // النمط الزخرفي
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  
                  // المحتوى
                  Row(
                    children: [
                      // الجزء الأيسر - الرقم والأيقونة
                      Container(
                        width: 100,
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
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // الرقم
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.item.id}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // الأيقونة
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.item.getIcon(),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // المحتوى النصي
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // الاسم
                              Text(
                                widget.item.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  fontFamily: 'Cairo',
                                  height: 1,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // المعنى
                              Text(
                                widget.item.meaning,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // سهم
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: color.withValues(alpha: 0.5),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// AsmaAllahGridCard - بطاقة شبكة لاسم من أسماء الله الحسنى
// ============================================================================
class AsmaAllahGridCard extends StatefulWidget {
  final AsmaAllahModel item;
  final VoidCallback onTap;
  
  const AsmaAllahGridCard({
    super.key,
    required this.item,
    required this.onTap,
  });
  
  @override
  State<AsmaAllahGridCard> createState() => _AsmaAllahGridCardState();
}

class _AsmaAllahGridCardState extends State<AsmaAllahGridCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.item.getColor();
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.9),
                    color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // النمط الزخرفي
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // المحتوى
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الرقم
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.item.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // الأيقونة
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.item.getIcon(),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // الاسم
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// EnhancedAsmaAllahHeader - هيدر محسن للصفحة
// ============================================================================
class EnhancedAsmaAllahHeader extends StatefulWidget {
  const EnhancedAsmaAllahHeader({super.key});
  
  @override
  State<EnhancedAsmaAllahHeader> createState() => _EnhancedAsmaAllahHeaderState();
}

class _EnhancedAsmaAllahHeaderState extends State<EnhancedAsmaAllahHeader> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
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
                Color(0xFF6B46C1),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        
        // النمط الإسلامي المتحرك
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  rotation: _rotationAnimation.value,
                  color: Colors.white,
                  patternType: PatternType.geometric,
                  opacity: 0.08,
                ),
              ),
            );
          },
        ),
        
        // دوائر زخرفية متحركة
        ...List.generate(3, (index) {
          return Positioned(
            left: index * 100.0 - 50,
            top: index * 50.0 + 20,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value + (index * 0.1),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        
        // المحتوى
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الأيقونة المتحركة
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.3),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_purple500_outlined,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // العنوان
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(0xFFFFC107),
                        Colors.white,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'أسماء الله الحسنى',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // الآية
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // الوصف
                  Text(
                    'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontFamily: 'Cairo',
                    ),
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
// AsmaAllahHeader - هيدر الصفحة (الأصلي)
// ============================================================================
class AsmaAllahHeader extends StatelessWidget {
  const AsmaAllahHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const EnhancedAsmaAllahHeader();
  }
}