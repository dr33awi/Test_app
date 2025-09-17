// lib/features/qibla/widgets/compass_calibration_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../app/themes/app_theme.dart';

class CompassCalibrationSheet extends StatefulWidget {
  final VoidCallback onStartCalibration;
  final double initialAccuracy;
  
  const CompassCalibrationSheet({
    super.key,
    required this.onStartCalibration,
    this.initialAccuracy = 0.0,
  });

  @override
  State<CompassCalibrationSheet> createState() => _CompassCalibrationSheetState();
}

class _CompassCalibrationSheetState extends State<CompassCalibrationSheet> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _figure8Animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _figure8Animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final accuracyPercentage = (widget.initialAccuracy * 100).clamp(0, 100).toInt();
    final accuracyColor = _getAccuracyColor(accuracyPercentage);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.space4,
        vertical: ThemeConstants.space4,
      ),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeConstants.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: ThemeConstants.space4),
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  color: ThemeConstants.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore_rounded,
                  color: ThemeConstants.warning,
                  size: ThemeConstants.iconMd,
                ),
              ),
              ThemeConstants.space3.w,
              Text(
                'معايرة البوصلة',
                style: context.titleLarge?.copyWith(
                  fontWeight: ThemeConstants.bold,
                ),
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // Warning message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ThemeConstants.space3),
            decoration: BoxDecoration(
              color: ThemeConstants.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: ThemeConstants.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: ThemeConstants.warning,
                  size: ThemeConstants.iconMd,
                ),
                ThemeConstants.space2.w,
                Expanded(
                  child: Text(
                    'البوصلة تحتاج إلى معايرة',
                    style: context.bodyLarge?.copyWith(
                      color: ThemeConstants.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          ThemeConstants.space4.h,
          
          // Accuracy indicator
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space3),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'دقة البوصلة:',
                      style: context.bodyLarge,
                    ),
                    Text(
                      '$accuracyPercentage%',
                      style: context.titleMedium?.copyWith(
                        color: accuracyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ThemeConstants.space3.h,
                LinearProgressIndicator(
                  value: accuracyPercentage / 100,
                  backgroundColor: context.dividerColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(accuracyColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          
          ThemeConstants.space5.h,
          
          // Phone animation with figure-8 motion
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Figure-8 background - bigger and clearer
                CustomPaint(
                  size: const Size(240, 100),
                  painter: Figure8BackgroundPainter(
                    color: ThemeConstants.primary.withValues(alpha: 0.4),
                  ),
                ),
                // Animated phone
                AnimatedBuilder(
                  animation: _figure8Animation,
                  builder: (context, child) {
                    // Calculate figure-8 path
                    final t = _figure8Animation.value;
                    final x = math.sin(t) * 75;
                    final y = math.sin(2 * t) * 30;
                    
                    // Calculate tilt based on position
                    final tilt = math.sin(t) * 0.2;
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(tilt)
                          ..rotateZ(tilt * 0.5),
                        child: PhoneAnimationWidget(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          ThemeConstants.space5.h,
          
          // Instructions title
          Text(
            'كيفية معايرة البوصلة:',
            style: context.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // Calibration steps
          _buildCalibrationStep(
            context: context,
            number: '1',
            text: 'ابتعد عن الأجهزة الإلكترونية والمعادن',
            icon: Icons.phone_android_rounded,
          ),
          _buildCalibrationStep(
            context: context,
            number: '2',
            text: 'احمل الهاتف وحركه على شكل رقم 8',
            icon: Icons.gesture,
          ),
          _buildCalibrationStep(
            context: context,
            number: '3',
            text: 'كرر الحركة 3-4 مرات ببطء',
            icon: Icons.loop_rounded,
          ),
          _buildCalibrationStep(
            context: context,
            number: '4',
            text: 'انتظر حتى تستقر القراءات',
            icon: Icons.check_circle_outline,
          ),
          
          ThemeConstants.space6.h,
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeConstants.space3,
                    ),
                    side: BorderSide(
                      color: context.dividerColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: context.bodyLarge,
                  ),
                ),
              ),
              ThemeConstants.space3.w,
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onStartCalibration();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeConstants.space3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'بدء المعايرة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Safe area for bottom sheet
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
  
  Widget _buildCalibrationStep({
    required BuildContext context,
    required String number,
    required String text,
    required IconData icon,
  }) {
    final bool isStep2 = number == '2';
    
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.space3),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.primary,
                ),
              ),
            ),
          ),
          ThemeConstants.space3.w,
          if (isStep2) ...[
            // Small figure-8 icon for step 2
            CustomPaint(
              size: const Size(30, 15),
              painter: SmallFigure8Painter(
                color: ThemeConstants.primary,
              ),
            ),
            ThemeConstants.space2.w,
          ] else ...[
            Icon(
              icon,
              size: ThemeConstants.iconSm,
              color: context.textSecondaryColor,
            ),
            ThemeConstants.space2.w,
          ],
          Expanded(
            child: Text(
              text,
              style: context.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAccuracyColor(int percentage) {
    if (percentage >= 80) {
      return ThemeConstants.success;
    } else if (percentage >= 50) {
      return ThemeConstants.warning;
    } else {
      return ThemeConstants.error;
    }
  }
}

// Shared Phone Widget
class PhoneAnimationWidget extends StatelessWidget {
  const PhoneAnimationWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeConstants.primary,
            ThemeConstants.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primary.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Screen
          Positioned(
            top: 7,
            left: 12,
            right: 12,
            bottom: 7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore,
                    color: ThemeConstants.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  // Motion waves
                  ...List.generate(3, (index) => Container(
                    width: 3,
                    height: 14 - (index * 2),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primary.withValues(
                        alpha: 0.7 - (index * 0.2),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                ],
              ),
            ),
          ),
          // Camera notch
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Home indicator
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Volume buttons
          Positioned(
            left: 4,
            top: 14,
            child: Container(
              width: 3,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 14,
            child: Container(
              width: 3,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for drawing figure-8 path - Bigger and clearer
class Figure8BackgroundPainter extends CustomPainter {
  final Color color;
  
  Figure8BackgroundPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Main path
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    
    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radiusX = size.width * 0.42;
    final radiusY = size.height * 0.4;
    
    // Draw horizontal figure-8 (infinity symbol)
    path.moveTo(centerX - radiusX, centerY);
    
    // Left loop
    path.cubicTo(
      centerX - radiusX, centerY - radiusY,
      centerX - radiusX * 0.2, centerY - radiusY,
      centerX, centerY,
    );
    
    // Right loop
    path.cubicTo(
      centerX + radiusX * 0.2, centerY + radiusY,
      centerX + radiusX, centerY + radiusY,
      centerX + radiusX, centerY,
    );
    
    path.cubicTo(
      centerX + radiusX, centerY - radiusY,
      centerX + radiusX * 0.2, centerY - radiusY,
      centerX, centerY,
    );
    
    path.cubicTo(
      centerX - radiusX * 0.2, centerY + radiusY,
      centerX - radiusX, centerY + radiusY,
      centerX - radiusX, centerY,
    );
    
    // Draw glow
    canvas.drawPath(path, glowPaint);
    // Draw main path
    canvas.drawPath(path, paint);
    
    // Draw dots along the path for visual guidance
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final x = centerX + math.sin(angle) * radiusX * 0.95;
      final y = centerY + math.sin(2 * angle) * radiusY * 0.95;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
    
    // Draw arrow indicators
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Left arrow
    final leftArrowPath = Path();
    leftArrowPath.moveTo(centerX - radiusX * 0.65, centerY - 8);
    leftArrowPath.lineTo(centerX - radiusX * 0.75, centerY);
    leftArrowPath.lineTo(centerX - radiusX * 0.65, centerY + 8);
    canvas.drawPath(leftArrowPath, arrowPaint);
    
    // Right arrow
    final rightArrowPath = Path();
    rightArrowPath.moveTo(centerX + radiusX * 0.65, centerY - 8);
    rightArrowPath.lineTo(centerX + radiusX * 0.75, centerY);
    rightArrowPath.lineTo(centerX + radiusX * 0.65, centerY + 8);
    canvas.drawPath(rightArrowPath, arrowPaint);
  }
  
  @override
  bool shouldRepaint(Figure8BackgroundPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

// Small Figure-8 painter for step 2
class SmallFigure8Painter extends CustomPainter {
  final Color color;
  
  SmallFigure8Painter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radiusX = size.width * 0.4;
    final radiusY = size.height * 0.35;
    
    // Draw small horizontal figure-8
    path.moveTo(centerX - radiusX, centerY);
    
    // Left loop
    path.cubicTo(
      centerX - radiusX, centerY - radiusY,
      centerX - radiusX * 0.3, centerY - radiusY,
      centerX, centerY,
    );
    
    // Right loop
    path.cubicTo(
      centerX + radiusX * 0.3, centerY + radiusY,
      centerX + radiusX, centerY + radiusY,
      centerX + radiusX, centerY,
    );
    
    path.cubicTo(
      centerX + radiusX, centerY - radiusY,
      centerX + radiusX * 0.3, centerY - radiusY,
      centerX, centerY,
    );
    
    path.cubicTo(
      centerX - radiusX * 0.3, centerY + radiusY,
      centerX - radiusX, centerY + radiusY,
      centerX - radiusX, centerY,
    );
    
    canvas.drawPath(path, paint);
    
    // Small dots for emphasis
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - radiusX * 0.5, centerY), 1, dotPaint);
    canvas.drawCircle(Offset(centerX + radiusX * 0.5, centerY), 1, dotPaint);
    canvas.drawCircle(Offset(centerX, centerY), 1.5, dotPaint);
  }
  
  @override
  bool shouldRepaint(SmallFigure8Painter oldDelegate) {
    return color != oldDelegate.color;
  }
}

// Calibration Progress Dialog with Animation
void showCalibrationProgressDialog({
  required BuildContext context,
  required VoidCallback onStartCalibration,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CalibrationProgressDialog(
      onStartCalibration: onStartCalibration,
    ),
  );
}

class CalibrationProgressDialog extends StatefulWidget {
  final VoidCallback onStartCalibration;
  
  const CalibrationProgressDialog({
    super.key,
    required this.onStartCalibration,
  });
  
  @override
  State<CalibrationProgressDialog> createState() => _CalibrationProgressDialogState();
}

class _CalibrationProgressDialogState extends State<CalibrationProgressDialog>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _figure8Animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _figure8Animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start calibration
    widget.onStartCalibration();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'جاري المعايرة...',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Same animation as in the sheet
          Container(
            height: 150,
            width: 280,
            decoration: BoxDecoration(
              color: context.cardColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Figure-8 background
                CustomPaint(
                  size: const Size(240, 100),
                  painter: Figure8BackgroundPainter(
                    color: ThemeConstants.primary.withValues(alpha: 0.4),
                  ),
                ),
                // Animated phone
                AnimatedBuilder(
                  animation: _figure8Animation,
                  builder: (context, child) {
                    final t = _figure8Animation.value;
                    final x = math.sin(t) * 75;
                    final y = math.sin(2 * t) * 30;
                    final tilt = math.sin(t) * 0.2;
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(tilt)
                          ..rotateZ(tilt * 0.5),
                        child: const PhoneAnimationWidget(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ThemeConstants.space4.h,
          const Text(
            'حرك هاتفك على شكل الرقم 8 في الهواء',
            textAlign: TextAlign.center,
          ),
          ThemeConstants.space3.h,
          const LinearProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}

// Helper function to show the calibration sheet
void showCompassCalibrationSheet({
  required BuildContext context,
  required VoidCallback onStartCalibration,
  double initialAccuracy = 0.0,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CompassCalibrationSheet(
      onStartCalibration: onStartCalibration,
      initialAccuracy: initialAccuracy,
    ),
  );
}