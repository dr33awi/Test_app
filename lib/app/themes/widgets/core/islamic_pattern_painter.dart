// lib/core/shared/widgets/islamic_pattern_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// رسام الأنماط الإسلامية الموحد لجميع الشاشات
class IslamicPatternPainter extends CustomPainter {
  final double rotation;
  final Color color;
  final PatternType patternType;
  final double opacity;

  IslamicPatternPainter({
    required this.rotation,
    required this.color,
    this.patternType = PatternType.standard,
    this.opacity = 0.05,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = patternType == PatternType.bold ? 1.5 : 1.0;
    
    final fillPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    // رسم النمط حسب النوع
    switch (patternType) {
      case PatternType.standard:
        _drawStandardPattern(canvas, size, paint, fillPaint);
        break;
      case PatternType.geometric:
        _drawGeometricPattern(canvas, size, paint, fillPaint);
        break;
      case PatternType.floral:
        _drawFloralPattern(canvas, size, paint, fillPaint);
        break;
      case PatternType.bold:
        _drawBoldPattern(canvas, size, paint, fillPaint);
        break;
    }
    
    canvas.restore();
    
    // عناصر ثابتة
    _drawStaticElements(canvas, size, paint);
  }

  void _drawStandardPattern(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // دوائر متحدة المركز
    for (int i = 1; i <= 4; i++) {
      final radius = 50.0 + (i * 40);
      _drawDottedCircle(canvas, centerX, centerY, radius, strokePaint);
      
      if (i % 2 == 0) {
        _drawStarsOnCircle(canvas, centerX, centerY, radius, 8, fillPaint);
      }
    }
    
    _drawRadialLines(canvas, centerX, centerY, strokePaint);
  }

  void _drawGeometricPattern(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // أشكال هندسية
    for (int layer = 1; layer <= 3; layer++) {
      final layerRadius = 40.0 * layer;
      _drawHexagon(canvas, centerX, centerY, layerRadius, strokePaint);
      
      // نقاط على الزوايا
      for (int i = 0; i < 6; i++) {
        final angle = (i * math.pi / 3);
        final x = centerX + layerRadius * math.cos(angle);
        final y = centerY + layerRadius * math.sin(angle);
        canvas.drawCircle(Offset(x, y), 2, fillPaint);
      }
    }
    
    _drawOctagonalStars(canvas, size, strokePaint);
  }

  void _drawFloralPattern(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final positions = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.5),
    ];
    
    for (final pos in positions) {
      _drawIslamicFlower(canvas, pos, 15, strokePaint, fillPaint);
    }
    
    _drawArabesquePattern(canvas, size, strokePaint);
  }

  void _drawBoldPattern(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // نمط أكثر وضوحاً للأدعية
    _drawCentralRosette(canvas, centerX, centerY, fillPaint);
    
    // خطوط شعاعية قوية
    const int lines = 16;
    for (int i = 0; i < lines; i++) {
      final angle = (i * 2 * math.pi) / lines;
      final innerRadius = 100.0;
      final outerRadius = 250.0;
      
      final startX = centerX + innerRadius * math.cos(angle);
      final startY = centerY + innerRadius * math.sin(angle);
      final endX = centerX + outerRadius * math.cos(angle);
      final endY = centerY + outerRadius * math.sin(angle);
      
      _drawPatternedLine(canvas, Offset(startX, startY), Offset(endX, endY), strokePaint);
    }
    
    _drawCalligraphicElements(canvas, size, strokePaint);
  }

  // باقي الدوال المساعدة...
  void _drawDottedCircle(Canvas canvas, double centerX, double centerY, double radius, Paint paint) {
    const int dots = 72;
    const double dotSize = 1.5;
    
    for (int i = 0; i < dots; i++) {
      final angle = (i * 2 * math.pi) / dots;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i % 4 == 0) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  void _drawStarsOnCircle(Canvas canvas, double centerX, double centerY, double radius, int count, Paint paint) {
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      _drawStar8(canvas, Offset(x, y), 4, paint);
    }
  }

  void _drawStar8(Canvas canvas, Offset center, double size, Paint paint) {
    const int points = 8;
    final path = Path();
    
    for (int i = 0; i < points; i++) {
      final outerAngle = (i * 2 * math.pi) / points - math.pi / 2;
      final innerAngle = ((i + 0.5) * 2 * math.pi) / points - math.pi / 2;
      
      final outerX = center.dx + size * math.cos(outerAngle);
      final outerY = center.dy + size * math.sin(outerAngle);
      final innerX = center.dx + (size * 0.4) * math.cos(innerAngle);
      final innerY = center.dy + (size * 0.4) * math.sin(innerAngle);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, double centerX, double centerY, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawOctagonalStars(Canvas canvas, Size size, Paint paint) {
    final positions = [
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.85),
    ];
    
    for (final pos in positions) {
      _drawStar8(canvas, pos, 15, paint);
    }
  }

  void _drawRadialLines(Canvas canvas, double centerX, double centerY, Paint paint) {
    const int lines = 12;
    const double innerRadius = 80;
    const double outerRadius = 200;
    
    for (int i = 0; i < lines; i++) {
      final angle = (i * 2 * math.pi) / lines;
      final startX = centerX + innerRadius * math.cos(angle);
      final startY = centerY + innerRadius * math.sin(angle);
      final endX = centerX + outerRadius * math.cos(angle);
      final endY = centerY + outerRadius * math.sin(angle);
      
      _drawDashedLine(canvas, Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 8.0;
    const double gapLength = 6.0;
    
    final distance = (end - start).distance;
    final dashCount = (distance / (dashLength + gapLength)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startProgress = (i * (dashLength + gapLength)) / distance;
      final endProgress = (i * (dashLength + gapLength) + dashLength) / distance;
      
      final dashStart = Offset.lerp(start, end, startProgress)!;
      final dashEnd = Offset.lerp(start, end, endProgress)!;
      
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawIslamicFlower(Canvas canvas, Offset center, double radius, Paint strokePaint, Paint fillPaint) {
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final petalCenter = Offset(
        center.dx + (radius * 0.7) * math.cos(angle),
        center.dy + (radius * 0.7) * math.sin(angle),
      );
      
      final path = Path();
      path.addOval(Rect.fromCenter(
        center: petalCenter,
        width: radius * 0.6,
        height: radius * 0.8,
      ));
      
      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle);
      canvas.translate(-petalCenter.dx, -petalCenter.dy);
      canvas.drawPath(path, strokePaint);
      canvas.restore();
    }
    
    canvas.drawCircle(center, radius * 0.3, fillPaint);
  }

  void _drawArabesquePattern(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    
    path.moveTo(size.width * 0.1, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.5,
      size.width * 0.9, size.height * 0.3,
    );
    
    canvas.drawPath(path, paint);
  }

  void _drawCentralRosette(Canvas canvas, double centerX, double centerY, Paint paint) {
    const int petals = 12;
    const double radius = 30;
    final path = Path();
    
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals;
      final controlX = centerX + radius * 0.7 * math.cos(angle);
      final controlY = centerY + radius * 0.7 * math.sin(angle);
      final endX = centerX + radius * math.cos(angle);
      final endY = centerY + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(centerX, centerY);
      }
      
      path.quadraticBezierTo(controlX, controlY, endX, endY);
      path.lineTo(centerX, centerY);
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawPatternedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 6.0;
    const double gapLength = 4.0;
    const double dotLength = 2.0;
    
    final distance = (end - start).distance;
    final totalPattern = dashLength + gapLength + dotLength + gapLength;
    final patternCount = (distance / totalPattern).floor();
    
    for (int i = 0; i < patternCount; i++) {
      final baseProgress = (i * totalPattern) / distance;
      
      final dashStart = Offset.lerp(start, end, baseProgress)!;
      final dashEnd = Offset.lerp(start, end, baseProgress + (dashLength / distance))!;
      canvas.drawLine(dashStart, dashEnd, paint);
      
      final dotProgress = baseProgress + ((dashLength + gapLength) / distance);
      final dotPoint = Offset.lerp(start, end, dotProgress)!;
      canvas.drawCircle(dotPoint, 1, paint);
    }
  }

  void _drawCalligraphicElements(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    
    path.moveTo(size.width * 0.2, size.height * 0.4);
    path.cubicTo(
      size.width * 0.3, size.height * 0.35,
      size.width * 0.4, size.height * 0.45,
      size.width * 0.5, size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.6, size.height * 0.35,
      size.width * 0.7, size.height * 0.45,
      size.width * 0.8, size.height * 0.4,
    );
    
    canvas.drawPath(path, paint);
  }

  void _drawStaticElements(Canvas canvas, Size size, Paint paint) {
    final corners = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.9),
    ];
    
    for (int i = 0; i < corners.length; i++) {
      _drawCornerOrnament(canvas, corners[i], paint, i);
    }
  }

  void _drawCornerOrnament(Canvas canvas, Offset position, Paint paint, int cornerIndex) {
    final path = Path();
    
    switch (cornerIndex % 2) {
      case 0:
        // زخرفة نوع 1
        path.moveTo(position.dx, position.dy);
        path.quadraticBezierTo(
          position.dx + 15, position.dy - 5,
          position.dx + 20, position.dy + 10,
        );
        path.quadraticBezierTo(
          position.dx + 5, position.dy + 15,
          position.dx, position.dy,
        );
        break;
      case 1:
        // زخرفة نوع 2
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(position.dx + (i * 8), position.dy),
            1.5,
            paint,
          );
        }
        break;
    }
    
    if (path.getBounds().width > 0) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation || 
           oldDelegate.color != color ||
           oldDelegate.patternType != patternType ||
           oldDelegate.opacity != opacity;
  }
}

/// أنواع الأنماط
enum PatternType {
  standard,   // النمط الافتراضي
  geometric,  // هندسي
  floral,     // نباتي
  bold,       // قوي للأدعية
}