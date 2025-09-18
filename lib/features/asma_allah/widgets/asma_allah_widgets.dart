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
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _rotationController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    
    // Scale Animation Controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Glow Animation Controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Rotation Animation Controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // Setup Animations
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    _elevationAnimation = Tween<double>(
      begin: 4,
      end: 12,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  void _startGlow() {
    _glowController.forward().then((_) {
      if (mounted) _glowController.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.item.getColor();
    final isDark = context.isDarkMode;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _startGlow();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleController.forward();
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glowAnimation,
            _rotationAnimation,
            _elevationAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 130,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.cardColor,
                      isDark 
                          ? color.withValues(alpha: 0.15)
                          : color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isHovered || _isPressed 
                        ? color.withValues(alpha: 0.6)
                        : color.withValues(alpha: 0.2),
                    width: _isHovered || _isPressed ? 2 : 1,
                  ),
                  boxShadow: [
                    // Main shadow
                    BoxShadow(
                      color: color.withValues(alpha: _isPressed ? 0.4 : 0.2),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                      spreadRadius: _isHovered ? 1 : 0,
                    ),
                    // Glow effect
                    if (_isHovered)
                      BoxShadow(
                        color: color.withValues(alpha: _glowAnimation.value),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                        spreadRadius: 3,
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Rotating background pattern
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Rotating geometric pattern
                            Positioned(
                              right: -30,
                              bottom: -30,
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                            // Additional decorative circle
                            Positioned(
                              right: 10,
                              top: -20,
                              child: Transform.rotate(
                                angle: -_rotationAnimation.value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Main content
                    Row(
                      children: [
                        // Enhanced left section - number and icon
                        Container(
                          width: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withValues(alpha: 0.85),
                                color.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(2, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Enhanced number container
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (value * 0.2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${widget.item.id}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Enhanced icon with pulse animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.7 + (value * 0.3),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        widget.item.getIcon(),
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Enhanced text content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Enhanced name with gradient effect
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.8),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    widget.item.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                      height: 1.1,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 10),
                                
                                // Enhanced meaning with better typography
                                Text(
                                  widget.item.meaning,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : Colors.grey[700],
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Enhanced arrow with animation
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 200),
                            tween: Tween(begin: 0.0, end: _isHovered ? 1.0 : 0.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(-4 * value, 0),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: color.withValues(alpha: 0.6 + (0.4 * value)),
                                  size: 20,
                                ),
                              );
                            },
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
      ),
    );
  }
}

// ============================================================================
// AsmaAllahGridCard - بطاقة شبكة محسنة لاسم من أسماء الله الحسنى
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
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }
  
  void _startGlow() {
    _glowController.forward().then((_) {
      if (mounted) _glowController.reverse();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.item.getColor();
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _startGlow();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glowAnimation,
            _floatAnimation,
            _rotationAnimation,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_floatAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.95),
                          color,
                          color.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        // Main elevated shadow
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 15 + _floatAnimation.value,
                          offset: Offset(0, 8 + _floatAnimation.value),
                          spreadRadius: 1,
                        ),
                        // Glow effect
                        if (_isHovered)
                          BoxShadow(
                            color: color.withValues(alpha: _glowAnimation.value),
                            blurRadius: 25,
                            offset: const Offset(0, 0),
                            spreadRadius: 4,
                          ),
                        // Inner highlight
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 0,
                          offset: const Offset(0, -1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Animated background pattern
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              children: [
                                // Rotating decorative element
                                Positioned(
                                  right: -15,
                                  top: -15,
                                  child: AnimatedBuilder(
                                    animation: _floatController,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _floatController.value * 2 * math.pi,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Additional floating circles
                                ...List.generate(3, (index) {
                                  return Positioned(
                                    left: (index * 30.0) - 10,
                                    bottom: (index * 20.0) - 10,
                                    child: AnimatedBuilder(
                                      animation: _floatController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            math.sin(_floatController.value * 2 * math.pi + index) * 5,
                                            math.cos(_floatController.value * 2 * math.pi + index) * 3,
                                          ),
                                          child: Container(
                                            width: 15.0 + (index * 5),
                                            height: 15.0 + (index * 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.05 + (index * 0.02)),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        
                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Enhanced number with scale animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 500),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.5 + (value * 0.5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.4),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${widget.item.id}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Enhanced icon with pulse effect
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.3 + (value * 0.7),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                          // Inner glow
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            blurRadius: 0,
                                            offset: const Offset(0, -1),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: AnimatedBuilder(
                                        animation: _floatController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 + (math.sin(_floatController.value * 2 * math.pi) * 0.05),
                                            child: Icon(
                                              widget.item.getIcon(),
                                              color: Colors.white,
                                              size: 36,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Enhanced name with fade-in effect
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (1 - value) * 20),
                                    child: Opacity(
                                      opacity: value,
                                      child: Text(
                                        widget.item.name,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Hover indicator
                        if (_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// EnhancedAsmaAllahHeader - هيدر محسن للصفحة مع تحسينات بصرية متقدمة
// ============================================================================
class EnhancedAsmaAllahHeader extends StatefulWidget {
  const EnhancedAsmaAllahHeader({super.key});
  
  @override
  State<EnhancedAsmaAllahHeader> createState() => _EnhancedAsmaAllahHeaderState();
}

class _EnhancedAsmaAllahHeaderState extends State<EnhancedAsmaAllahHeader> 
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _starController;
  late AnimationController _particleController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _starAnimation;
  late Animation<double> _particleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Rotation animation for Islamic pattern
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // Scale animation for pulsing effect
    _scaleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    // Star sparkle animation
    _starController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    // Floating particles animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _starAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.linear,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _starController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Multi-layered gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6B46C1),
                Color(0xFF8B5CF6),
                Color(0xFF9F7AEA),
                Color(0xFF6B46C1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        
        // Overlay gradient for depth
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
                const Color(0xFF6B46C1).withValues(alpha: 0.3),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        
        // Animated Islamic pattern
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  rotation: _rotationAnimation.value,
                  color: Colors.white,
                  patternType: PatternType.geometric,
                  opacity: 0.12,
                ),
              ),
            );
          },
        ),
        
        // Floating particles
        ...List.generate(12, (index) {
          return AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              final offset = (_particleAnimation.value + (index * 0.1)) % 1.0;
              final x = (math.sin(offset * 2 * math.pi + index) * 150) + 50;
              final y = (math.cos(offset * 2 * math.pi + index * 0.7) * 100) + 100;
              final size = 4.0 + (math.sin(offset * 4 * math.pi) * 3.0);
              
              return Positioned(
                left: x,
                top: y,
                child: Transform.scale(
                  scale: math.max(0.1, size / 7.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3 + (math.sin(offset * 2 * math.pi) * 0.2)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        
        // Animated decorative circles
        ...List.generate(4, (index) {
          return Positioned(
            left: index * 120.0 - 60,
            top: index * 40.0 + 30,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value + (index * 0.05),
                  child: Container(
                    width: 180 - (index * 20),
                    height: 180 - (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1 - (index * 0.02)),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        
        // Sparkling stars
        ...List.generate(8, (index) {
          return AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              final angle = (_starAnimation.value + (index * 0.3)) % (2 * math.pi);
              final radius = 80.0 + (index * 15);
              final x = math.cos(angle) * radius + 200;
              final y = math.sin(angle) * radius + 150;
              final sparkle = math.sin(_starAnimation.value * 4 + index) * 0.5 + 0.5;
              
              return Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: angle,
                  child: Icon(
                    Icons.star,
                    size: 12 + (sparkle * 8),
                    color: Colors.white.withValues(alpha: 0.4 + (sparkle * 0.4)),
                  ),
                ),
              );
            },
          );
        }),
        
        // Main content with enhanced animations
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced main icon with multiple effects
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value * 0.1,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.star_purple500_outlined,
                              size: 55,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Enhanced title with advanced shader effects
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: Opacity(
                          opacity: value,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                const Color(0xFFFFC107),
                                Colors.white,
                                const Color(0xFFFFD54F),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ).createShader(bounds),
                            child: Text(
                              'أسماء الله الحسنى',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                  Shadow(
                                    color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Enhanced Quranic verse with better styling
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 30),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              '﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Enhanced description with fade-in animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.95),
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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