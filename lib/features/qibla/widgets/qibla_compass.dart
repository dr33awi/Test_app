// lib/features/qibla/widgets/qibla_compass.dart - نسخة مبسطة
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// بوصلة القبلة المبسطة
class QiblaCompass extends StatelessWidget {
  final double qiblaDirection;
  final double currentDirection;
  final double accuracy;

  const QiblaCompass({
    super.key,
    required this.qiblaDirection,
    required this.currentDirection,
    this.accuracy = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final qiblaAngle = (qiblaDirection - currentDirection + 360) % 360;
    final isPointingToQibla = (qiblaAngle - 180).abs() < 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          alignment: Alignment.center,
          children: [
            // خلفية البوصلة
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardColor,
                boxShadow: ThemeConstants.shadowMd,
                border: Border.all(
                  color: context.dividerColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),

            // البوصلة الدوارة
            Transform.rotate(
              angle: -currentDirection * (math.pi / 180),
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: CompassPainter(context: context),
                ),
              ),
            ),

            // مؤشر القبلة
            Transform.rotate(
              angle: qiblaAngle * (math.pi / 180),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.navigation,
                    size: 40,
                    color: isPointingToQibla 
                        ? ThemeConstants.success 
                        : context.primaryColor,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space2,
                      vertical: ThemeConstants.space1,
                    ),
                    decoration: BoxDecoration(
                      color: isPointingToQibla 
                          ? ThemeConstants.success 
                          : context.primaryColor,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                    ),
                    child: Text(
                      'قبلة',
                      style: context.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: ThemeConstants.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // النقطة المركزية
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isPointingToQibla 
                    ? ThemeConstants.success 
                    : context.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.cardColor,
                  width: 2,
                ),
              ),
            ),

            // معلومات الاتجاه
            Positioned(
              bottom: size * 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.space3,
                  vertical: ThemeConstants.space2,
                ),
                decoration: BoxDecoration(
                  color: context.cardColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  boxShadow: ThemeConstants.shadowSm,
                ),
                child: Column(
                  children: [
                    Text(
                      '${currentDirection.toStringAsFixed(1)}°',
                      style: context.titleMedium?.bold,
                    ),
                    if (isPointingToQibla)
                      Text(
                        '🕋 تشير نحو القبلة',
                        style: context.labelSmall?.copyWith(
                          color: ThemeConstants.success,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// رسام البوصلة المبسط
class CompassPainter extends CustomPainter {
  final BuildContext context;

  CompassPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // رسم الدوائر
    final circlePaint = Paint()
      ..color = Theme.of(context).dividerColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (0.3 + i * 0.2), circlePaint);
    }

    // رسم العلامات
    final linePaint = Paint()
      ..color = Theme.of(context).textTheme.bodySmall!.color!
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 30) {
      final angle = i * (math.pi / 180);
      final isMain = i % 90 == 0;
      
      final startRadius = radius - (isMain ? 25 : 15);
      final endRadius = radius - 5;

      final startPoint = Offset(
        center.dx + startRadius * math.cos(angle - math.pi / 2),
        center.dy + startRadius * math.sin(angle - math.pi / 2),
      );

      final endPoint = Offset(
        center.dx + endRadius * math.cos(angle - math.pi / 2),
        center.dy + endRadius * math.sin(angle - math.pi / 2),
      );

      canvas.drawLine(
        startPoint, 
        endPoint, 
        linePaint..strokeWidth = isMain ? 3 : 1,
      );
    }

    // رسم الاتجاهات
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final directions = ['N', 'E', 'S', 'W'];
    final positions = [
      Offset(center.dx, center.dy - radius + 40),
      Offset(center.dx + radius - 40, center.dy),
      Offset(center.dx, center.dy + radius - 40),
      Offset(center.dx - radius + 40, center.dy),
    ];

    for (int i = 0; i < directions.length; i++) {
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? ThemeConstants.error : Theme.of(context).textTheme.bodyLarge!.color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        positions[i] - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
