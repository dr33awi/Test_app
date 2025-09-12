// lib/features/qibla/widgets/qibla_compass.dart - نسخة محسنة
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';

/// بوصلة القبلة المحسنة مع أداء أفضل وتفاعل محسن
class QiblaCompass extends StatefulWidget {
  final double qiblaDirection; // اتجاه القبلة (درجات من الشمال الحقيقي)
  final double currentDirection; // الاتجاه الحالي للجهاز (درجات من الشمال المغناطيسي)
  final double accuracy; // دقة البوصلة (0.0 - 1.0)
  final bool isCalibrated;
  final VoidCallback? onCalibrate;
  final bool showAccuracyIndicator;
  final bool enableHapticFeedback;

  const QiblaCompass({
    super.key,
    required this.qiblaDirection,
    required this.currentDirection,
    this.accuracy = 1.0,
    this.isCalibrated = true,
    this.onCalibrate,
    this.showAccuracyIndicator = true,
    this.enableHapticFeedback = true,
  });

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass>
    with TickerProviderStateMixin {
  
  // Controllers للرسوم المتحركة
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _qiblaFoundController;
  late AnimationController _accuracyController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _qiblaFoundAnimation;
  late Animation<double> _accuracyAnimation;
  late Animation<Color?> _qiblaColorAnimation;

  // حالة البوصلة
  double _previousDirection = 0;
  double _smoothDirection = 0;
  bool _hasVibratedForQibla = false;
  bool _isPointingToQibla = false;
  Timer? _smoothingTimer;
  Timer? _hapticTimer;

  // إعدادات الأداء
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Duration _smoothingInterval = Duration(milliseconds: 50);
  static const double _qiblaThreshold = 5.0; // درجات للاعتبار أن الجهاز يشير للقبلة
  static const double _smoothingFactor = 0.3; // عامل تنعيم الحركة

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousDirection = widget.currentDirection;
    _smoothDirection = widget.currentDirection;
    _startSmoothingTimer();
  }

  /// تهيئة الرسوم المتحركة
  void _initializeAnimations() {
    // تحكم في دوران البوصلة
    _rotationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    // نبض للدقة المنخفضة
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // رسوم متحركة عند العثور على القبلة
    _qiblaFoundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _qiblaFoundAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _qiblaFoundController,
      curve: Curves.elasticOut,
    ));

    // تحريك لون القبلة
    _qiblaColorAnimation = ColorTween(
      begin: ThemeConstants.primary,
      end: ThemeConstants.success,
    ).animate(_qiblaFoundController);

    // رسوم متحركة للدقة
    _accuracyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _accuracyAnimation = Tween<double>(
      begin: 0.0,
      end: widget.accuracy,
    ).animate(CurvedAnimation(
      parent: _accuracyController,
      curve: Curves.easeOut,
    ));

    _accuracyController.forward();
  }

  /// بدء مؤقت التنعيم
  void _startSmoothingTimer() {
    _smoothingTimer = Timer.periodic(_smoothingInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateSmoothDirection();
    });
  }

  /// تحديث الاتجاه المنعم
  void _updateSmoothDirection() {
    final targetDirection = widget.currentDirection;
    final difference = _calculateAngleDifference(_smoothDirection, targetDirection);
    
    // تطبيق التنعيم
    _smoothDirection = (_smoothDirection + difference * _smoothingFactor) % 360;
    
    if (mounted) {
      setState(() {});
    }
  }

  /// حساب الفرق بين زاويتين مع مراعاة الدوران الدائري
  double _calculateAngleDifference(double from, double to) {
    double diff = to - from;
    
    // تطبيع الفرق ليكون بين -180 و 180
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;
    
    return diff;
  }

  @override
  void didUpdateWidget(QiblaCompass oldWidget) {
    super.didUpdateWidget(oldWidget);

    // تحديث الدقة
    if (oldWidget.accuracy != widget.accuracy) {
      _accuracyAnimation = Tween<double>(
        begin: oldWidget.accuracy,
        end: widget.accuracy,
      ).animate(CurvedAnimation(
        parent: _accuracyController,
        curve: Curves.easeOut,
      ));
      _accuracyController.forward(from: 0);
    }

    // فحص التوجه نحو القبلة
    _checkQiblaAlignment();
  }

  /// فحص ما إذا كان الجهاز يشير نحو القبلة
  void _checkQiblaAlignment() {
    final qiblaAngle = _calculateQiblaAngle();
    final wasPointingToQibla = _isPointingToQibla;
    _isPointingToQibla = qiblaAngle.abs() <= _qiblaThreshold;

    // تفعيل الاهتزاز عند العثور على القبلة
    if (widget.enableHapticFeedback && _isPointingToQibla && !_hasVibratedForQibla) {
      _triggerQiblaFoundFeedback();
    } else if (!_isPointingToQibla && _hasVibratedForQibla) {
      _hasVibratedForQibla = false;
    }

    // رسوم متحركة عند العثور على القبلة
    if (_isPointingToQibla && !wasPointingToQibla) {
      _qiblaFoundController.forward().then((_) {
        if (mounted) {
          _qiblaFoundController.reverse();
        }
      });
    }
  }

  /// تفعيل ردود الفعل عند العثور على القبلة
  void _triggerQiblaFoundFeedback() {
    _hasVibratedForQibla = true;
    
    // اهتزاز خفيف
    HapticFeedback.lightImpact();
    
    // اهتزاز إضافي بعد قليل للتأكيد
    _hapticTimer?.cancel();
    _hapticTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _isPointingToQibla) {
        HapticFeedback.selectionClick();
      }
    });
  }

  /// حساب زاوية القبلة النسبية
  double _calculateQiblaAngle() {
    final relativeAngle = (widget.qiblaDirection - _smoothDirection + 360) % 360;
    // تحويل إلى أقصر مسار (-180 إلى 180)
    return relativeAngle > 180 ? relativeAngle - 360 : relativeAngle;
  }

  @override
  void dispose() {
    _smoothingTimer?.cancel();
    _hapticTimer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    _qiblaFoundController.dispose();
    _accuracyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaAngle = _calculateQiblaAngle();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          alignment: Alignment.center,
          children: [
            // خلفية البوصلة مع مؤشر الدقة
            _buildCompassBackground(size),
            
            // البوصلة الدوارة
            _buildRotatingCompass(size),
            
            // مؤشر القبلة
            _buildQiblaIndicator(size, qiblaAngle),
            
            // النقطة المركزية
            _buildCenterDot(),
            
            // مؤشر اتجاه الجهاز
            _buildDeviceIndicator(size),
            
            // معلومات الحالة
            _buildStatusInfo(size),
            
            // مؤشر الدقة إذا كان مطلوباً
            if (widget.showAccuracyIndicator)
              _buildAccuracyRing(size),
          ],
        );
      },
    );
  }

  /// بناء خلفية البوصلة
  Widget _buildCompassBackground(double size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: size * (0.9 + (widget.accuracy < 0.7 ? _pulseAnimation.value * 0.05 : 0)),
          height: size * (0.9 + (widget.accuracy < 0.7 ? _pulseAnimation.value * 0.05 : 0)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                context.cardColor,
                context.cardColor.darken(0.02),
                context.cardColor.darken(0.05),
                context.cardColor.darken(0.1),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: context.primaryColor.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(
              color: context.dividerColor.withOpacity(0.2),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  /// بناء البوصلة الدوارة
  Widget _buildRotatingCompass(double size) {
    return Transform.rotate(
      angle: -_smoothDirection * (math.pi / 180), // دوران عكس اتجاه الجهاز
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: EnhancedCompassPainter(
            accuracy: widget.accuracy,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
            isCalibrated: widget.isCalibrated,
          ),
        ),
      ),
    );
  }

  /// بناء مؤشر القبلة
  Widget _buildQiblaIndicator(double size, double qiblaAngle) {
    return AnimatedBuilder(
      animation: Listenable.merge([_qiblaFoundAnimation, _qiblaColorAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: qiblaAngle * (math.pi / 180),
          child: Transform.scale(
            scale: _qiblaFoundAnimation.value,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size * 0.8,
              height: size * 0.8,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // السهم الرئيسي
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: 60,
                      height: size * 0.4,
                      child: CustomPaint(
                        painter: QiblaArrowPainter(
                          color: _qiblaColorAnimation.value ?? context.primaryColor,
                          isPointingToQibla: _isPointingToQibla,
                          glowIntensity: widget.accuracy,
                        ),
                      ),
                    ),
                  ),
                  
                  // تسمية "قبلة"
                  Positioned(
                    top: size * 0.08,
                    child: AnimatedContainer(
                      duration: _animationDuration,
                      padding: EdgeInsets.symmetric(
                        horizontal: _isPointingToQibla ? ThemeConstants.space4 : ThemeConstants.space3,
                        vertical: _isPointingToQibla ? ThemeConstants.space2 : ThemeConstants.space1,
                      ),
                      decoration: BoxDecoration(
                        color: _qiblaColorAnimation.value ?? context.primaryColor,
                        borderRadius: BorderRadius.circular(
                          _isPointingToQibla ? ThemeConstants.radiusLg : ThemeConstants.radiusMd
                        ),
                        boxShadow: _isPointingToQibla ? [
                          BoxShadow(
                            color: (context.primaryColor).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        'قبلة',
                        style: context.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: _isPointingToQibla 
                              ? ThemeConstants.bold 
                              : ThemeConstants.semiBold,
                          fontSize: _isPointingToQibla ? 14 : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء النقطة المركزية
  Widget _buildCenterDot() {
    return AnimatedContainer(
      duration: _animationDuration,
      width: _isPointingToQibla ? ThemeConstants.iconLg : ThemeConstants.iconMd,
      height: _isPointingToQibla ? ThemeConstants.iconLg : ThemeConstants.iconMd,
      decoration: BoxDecoration(
        color: _isPointingToQibla ? ThemeConstants.success : context.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.cardColor,
          width: ThemeConstants.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isPointingToQibla ? ThemeConstants.success : context.primaryColor)
                .withOpacity(0.3),
            blurRadius: _isPointingToQibla ? 8 : 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  /// بناء مؤشر اتجاه الجهاز
  Widget _buildDeviceIndicator(double size) {
    return Positioned(
      top: (size * 0.05),
      child: AnimatedContainer(
        duration: _animationDuration,
        width: 0,
        height: 0,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: _isPointingToQibla ? 12 : 10, 
              color: Colors.transparent
            ),
            right: BorderSide(
              width: _isPointingToQibla ? 12 : 10, 
              color: Colors.transparent
            ),
            bottom: BorderSide(
              width: _isPointingToQibla ? 24 : 20, 
              color: _isPointingToQibla ? ThemeConstants.success : ThemeConstants.error
            ),
          ),
        ),
      ),
    );
  }

  /// بناء معلومات الحالة
  Widget _buildStatusInfo(double size) {
    return Positioned(
      bottom: size * 0.1,
      child: Column(
        children: [
          // عرض الاتجاه الحالي
          AnimatedContainer(
            duration: _animationDuration,
            padding: EdgeInsets.symmetric(
              horizontal: _isPointingToQibla ? ThemeConstants.space4 : ThemeConstants.space3,
              vertical: _isPointingToQibla ? ThemeConstants.space2 : ThemeConstants.space1,
            ),
            decoration: BoxDecoration(
              color: context.cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              border: Border.all(
                color: _isPointingToQibla 
                    ? ThemeConstants.success.withOpacity(0.3)
                    : context.primaryColor.withOpacity(0.3),
                width: _isPointingToQibla ? 2 : 1,
              ),
              boxShadow: ThemeConstants.shadowMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPointingToQibla ? Icons.gps_fixed : Icons.screen_rotation_alt,
                  size: _isPointingToQibla ? ThemeConstants.iconMd : ThemeConstants.iconSm,
                  color: _isPointingToQibla ? ThemeConstants.success : context.primaryColor,
                ),
                ThemeConstants.space2.w,
                Text(
                  '${_smoothDirection.toStringAsFixed(1)}°',
                  style: context.titleMedium?.copyWith(
                    fontWeight: _isPointingToQibla ? ThemeConstants.bold : ThemeConstants.semiBold,
                    color: _isPointingToQibla ? ThemeConstants.success : context.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          ThemeConstants.space2.h,

          // مؤشر الدقة المبسط
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space3,
              vertical: ThemeConstants.space1,
            ),
            decoration: BoxDecoration(
              color: _getAccuracyColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: _getAccuracyColor().withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getAccuracyIcon(),
                  size: ThemeConstants.iconSm,
                  color: _getAccuracyColor(),
                ),
                ThemeConstants.space1.w,
                Text(
                  _getAccuracyText(),
                  style: context.bodySmall?.copyWith(
                    color: _getAccuracyColor(),
                    fontWeight: ThemeConstants.medium,
                  ),
                ),
              ],
            ),
          ),

          // رسالة القبلة
          if (_isPointingToQibla) ...[
            ThemeConstants.space2.h,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space3,
                vertical: ThemeConstants.space1,
              ),
              decoration: BoxDecoration(
                color: ThemeConstants.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                border: Border.all(
                  color: ThemeConstants.success.withOpacity(0.3),
                ),
              ),
              child: Text(
                '🕋 تشير نحو القبلة',
                style: context.bodySmall?.copyWith(
                  color: ThemeConstants.success,
                  fontWeight: ThemeConstants.semiBold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// بناء حلقة الدقة
  Widget _buildAccuracyRing(double size) {
    return AnimatedBuilder(
      animation: _accuracyAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: AccuracyRingPainter(
            accuracy: _accuracyAnimation.value,
            color: _getAccuracyColor(),
          ),
        );
      },
    );
  }

  /// الحصول على لون الدقة
  Color _getAccuracyColor() {
    if (widget.accuracy >= 0.8) return ThemeConstants.success;
    if (widget.accuracy >= 0.5) return ThemeConstants.warning;
    return ThemeConstants.error;
  }

  /// الحصول على أيقونة الدقة
  IconData _getAccuracyIcon() {
    if (widget.accuracy >= 0.8) return Icons.gps_fixed;
    if (widget.accuracy >= 0.5) return Icons.gps_not_fixed;
    return Icons.gps_off;
  }

  /// الحصول على نص الدقة
  String _getAccuracyText() {
    if (widget.accuracy >= 0.8) return 'دقة عالية';
    if (widget.accuracy >= 0.5) return 'دقة متوسطة';
    return 'دقة منخفضة';
  }
}

// ==================== Painters المحسنة ====================

/// رسام البوصلة المحسن
class EnhancedCompassPainter extends CustomPainter {
  final double accuracy;
  final bool isDarkMode;
  final bool isCalibrated;

  EnhancedCompassPainter({
    this.accuracy = 1.0,
    required this.isDarkMode,
    this.isCalibrated = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ضبط الألوان حسب الدقة والثيم
    final primaryLineColor = Color.lerp(
      ThemeConstants.error.withOpacity(0.6),
      isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8),
      accuracy,
    )!;

    final secondaryLineColor = Color.lerp(
      ThemeConstants.error.withOpacity(0.3),
      isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
      accuracy,
    )!;

    // رسم الدوائر
    _drawCircles(canvas, center, radius, primaryLineColor);
    
    // رسم العلامات
    _drawMarkings(canvas, center, radius, primaryLineColor, secondaryLineColor);
    
    // رسم تسميات الاتجاهات
    _drawDirectionLabels(canvas, center, radius, primaryLineColor);
  }

  void _drawCircles(Canvas canvas, Offset center, double radius, Color color) {
    final circlePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // دوائر متحدة المركز
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center, 
        radius * (0.3 + i * 0.2), 
        circlePaint..strokeWidth = i == 3 ? 2 : 1,
      );
    }
  }

  void _drawMarkings(Canvas canvas, Offset center, double radius, 
                     Color primaryColor, Color secondaryColor) {
    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180);
      final isMainDirection = i % 90 == 0;
      final isMediumDirection = i % 45 == 0;
      final isMinorDirection = i % 15 == 0;

      Paint linePaint;
      double lineLength;
      double startRadius;

      if (isMainDirection) {
        lineLength = 30;
        startRadius = radius - lineLength;
        linePaint = Paint()
          ..color = primaryColor
          ..strokeWidth = 3;
      } else if (isMediumDirection) {
        lineLength = 20;
        startRadius = radius - lineLength;
        linePaint = Paint()
          ..color = primaryColor.withOpacity(0.8)
          ..strokeWidth = 2;
      } else if (isMinorDirection) {
        lineLength = 15;
        startRadius = radius - lineLength;
        linePaint = Paint()
          ..color = secondaryColor
          ..strokeWidth = 1.5;
      } else {
        lineLength = 10;
        startRadius = radius - lineLength;
        linePaint = Paint()
          ..color = secondaryColor.withOpacity(0.6)
          ..strokeWidth = 1;
      }

      final startPoint = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );

      final endPoint = Offset(
        center.dx + (radius - 2) * math.cos(angle - math.pi / 2),
        center.dy + (radius - 2) * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(startPoint, endPoint, linePaint);
    }
  }

  void _drawDirectionLabels(Canvas canvas, Offset center, double radius, Color color) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final positions = [
      Offset(center.dx, center.dy - radius + 45), // N
      Offset(center.dx + radius - 45, center.dy), // E
      Offset(center.dx, center.dy + radius - 45), // S
      Offset(center.dx - radius + 45, center.dy), // W
    ];

    for (int i = 0; i < directions.length; i++) {
      final textSpan = TextSpan(text: directions[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // رسم دائرة خلف النص
      if (directions[i] == 'N') {
        canvas.drawCircle(
          positions[i],
          18,
          Paint()..color = ThemeConstants.error.withOpacity(0.2),
        );
      }
      
      textPainter.paint(
        canvas, 
        positions[i] - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedCompassPainter oldDelegate) {
    return oldDelegate.accuracy != accuracy || 
           oldDelegate.isDarkMode != isDarkMode ||
           oldDelegate.isCalibrated != isCalibrated;
  }
}

/// رسام سهم القبلة المحسن
class QiblaArrowPainter extends CustomPainter {
  final Color color;
  final bool isPointingToQibla;
  final double glowIntensity;

  QiblaArrowPainter({
    required this.color,
    this.isPointingToQibla = false,
    this.glowIntensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // رسم الظل/التوهج
    if (isPointingToQibla) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      _drawArrowPath(canvas, size, glowPaint);
    }

    // رسم السهم الرئيسي
    _drawArrowPath(canvas, size, paint);

    // إضافة تأثير لامع
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withOpacity(isPointingToQibla ? 0.4 : 0.2),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

    _drawArrowPath(canvas, size, glossPaint);
  }

  void _drawArrowPath(Canvas canvas, Size size, Paint paint) {
    final path = Path();

    // تصميم سهم محسن
    path.moveTo(size.width / 2, 0); // القمة
    path.lineTo(size.width * 0.75, size.height * 0.3); // الجناح الأيمن
    path.lineTo(size.width * 0.65, size.height * 0.3); // الداخل الأيمن
    path.lineTo(size.width * 0.65, size.height * 0.85); // الجانب الأيمن
    path.lineTo(size.width * 0.35, size.height * 0.85); // الجانب الأيسر
    path.lineTo(size.width * 0.35, size.height * 0.3); // الداخل الأيسر
    path.lineTo(size.width * 0.25, size.height * 0.3); // الجناح الأيسر
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant QiblaArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.isPointingToQibla != isPointingToQibla ||
           oldDelegate.glowIntensity != glowIntensity;
  }
}

/// رسام حلقة الدقة
class AccuracyRingPainter extends CustomPainter {
  final double accuracy;
  final Color color;

  AccuracyRingPainter({
    required this.accuracy,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // خلفية الحلقة
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // حلقة الدقة
    final accuracyPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * accuracy;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // البدء من الأعلى
      sweepAngle,
      false,
      accuracyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AccuracyRingPainter oldDelegate) {
    return oldDelegate.accuracy != accuracy || oldDelegate.color != color;
  }
}