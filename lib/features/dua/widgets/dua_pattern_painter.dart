// lib/features/dua/widgets/dua_pattern_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// رسام الأنماط الزخرفية لخلفية الأدعية
class DuaPatternPainter extends CustomPainter {
  final double rotation;
  final Color color;

  DuaPatternPainter({
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    // حفظ حالة الـ Canvas
    canvas.save();
    
    // تطبيق الدوران من المركز
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    // رسم النمط الإسلامي المتحرك للأدعية
    _drawIslamicPattern(canvas, size, paint, fillPaint);
    
    // استعادة حالة الـ Canvas
    canvas.restore();
    
    // رسم عناصر ثابتة
    _drawStaticElements(canvas, size, paint);
  }

  void _drawIslamicPattern(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // رسم دوائر متحدة المركز مع كتابات عربية مستوحاة
    for (int i = 1; i <= 5; i++) {
      final radius = 60.0 + (i * 35);
      
      // دوائر منقطة بنمط إسلامي
      _drawDottedCircleWithPattern(canvas, centerX, centerY, radius, strokePaint);
      
      // رموز إسلامية على محيط الدوائر
      _drawIslamicSymbolsOnCircle(canvas, centerX, centerY, radius, 8, fillPaint);
    }
    
    // خطوط شعاعية تشبه أشعة الشمس (رمز للنور)
    _drawRadialLinesPattern(canvas, centerX, centerY, strokePaint);
    
    // أنماط هندسية إسلامية
    _drawGeometricPatterns(canvas, centerX, centerY, fillPaint);
  }

  void _drawDottedCircleWithPattern(Canvas canvas, double centerX, double centerY, double radius, Paint paint) {
    const int dots = 72; // عدد يقبل القسمة على 8 و 9 (أرقام مهمة في الفن الإسلامي)
    const double dotSize = 1.5;
    
    for (int i = 0; i < dots; i++) {
      final angle = (i * 2 * math.pi) / dots;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      // نمط متنوع: نقطة، خط صغير، نقطة، فراغ
      if (i % 4 == 0) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      } else if (i % 4 == 2) {
        // خط صغير عمودي على الدائرة
        final angle2 = angle + math.pi / 2;
        final x2 = x + 3 * math.cos(angle2);
        final y2 = y + 3 * math.sin(angle2);
        canvas.drawLine(
          Offset(x - 3 * math.cos(angle2), y - 3 * math.sin(angle2)),
          Offset(x2, y2),
          paint,
        );
      }
    }
  }

  void _drawIslamicSymbolsOnCircle(Canvas canvas, double centerX, double centerY, double radius, int count, Paint paint) {
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      // تنويع الرموز
      if (i % 3 == 0) {
        _drawCrescent(canvas, Offset(x, y), 4, paint);
      } else if (i % 3 == 1) {
        _drawStar8(canvas, Offset(x, y), 4, paint);
      } else {
        _drawDiamond(canvas, Offset(x, y), 3, paint);
      }
    }
  }

  void _drawCrescent(Canvas canvas, Offset center, double size, Paint paint) {
    // رسم هلال
    final path = Path();
    
    // الدائرة الخارجية
    path.addOval(Rect.fromCircle(center: center, radius: size));
    
    // الدائرة الداخلية المتداخلة لتكوين الهلال
    final innerCenter = Offset(center.dx + size * 0.3, center.dy);
    path.addOval(Rect.fromCircle(center: innerCenter, radius: size * 0.8));
    
    // استخدام fillType لإنشاء شكل الهلال
    path.fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
  }

  void _drawStar8(Canvas canvas, Offset center, double size, Paint paint) {
    // رسم نجمة ثمانية (رخامية إسلامية)
    const int points = 8;
    final path = Path();
    
    for (int i = 0; i < points; i++) {
      final outerAngle = (i * 2 * math.pi) / points - math.pi / 2;
      final innerAngle = ((i + 0.5) * 2 * math.pi) / points - math.pi / 2;
      
      final outerRadius = size;
      final innerRadius = size * 0.4;
      
      final outerX = center.dx + outerRadius * math.cos(outerAngle);
      final outerY = center.dy + outerRadius * math.sin(outerAngle);
      
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      
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

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    // رسم معين
    final path = Path();
    
    path.moveTo(center.dx, center.dy - size);      // أعلى
    path.lineTo(center.dx + size, center.dy);      // يمين
    path.lineTo(center.dx, center.dy + size);      // أسفل
    path.lineTo(center.dx - size, center.dy);      // يسار
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawRadialLinesPattern(Canvas canvas, double centerX, double centerY, Paint paint) {
    const int lines = 16;
    const double innerRadius = 100;
    const double outerRadius = 250;
    
    for (int i = 0; i < lines; i++) {
      final angle = (i * 2 * math.pi) / lines;
      
      final startX = centerX + innerRadius * math.cos(angle);
      final startY = centerY + innerRadius * math.sin(angle);
      
      final endX = centerX + outerRadius * math.cos(angle);
      final endY = centerY + outerRadius * math.sin(angle);
      
      // رسم خط متقطع مع نمط إسلامي
      _drawPatternedLine(canvas, Offset(startX, startY), Offset(endX, endY), paint);
    }
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
      
      // رسم الخط الطويل
      final dashStart = Offset.lerp(start, end, baseProgress)!;
      final dashEnd = Offset.lerp(start, end, baseProgress + (dashLength / distance))!;
      canvas.drawLine(dashStart, dashEnd, paint);
      
      // رسم النقطة
      final dotProgress = baseProgress + ((dashLength + gapLength) / distance);
      final dotPoint = Offset.lerp(start, end, dotProgress)!;
      canvas.drawCircle(dotPoint, 1, paint);
    }
  }

  void _drawGeometricPatterns(Canvas canvas, double centerX, double centerY, Paint paint) {
    // رسم أنماط هندسية إسلامية في الوسط
    _drawCentralRosette(canvas, centerX, centerY, paint);
  }

  void _drawCentralRosette(Canvas canvas, double centerX, double centerY, Paint paint) {
    // رسم وردة مركزية بنمط إسلامي
    const int petals = 12;
    const double radius = 30;
    
    final path = Path();
    
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals;
      
      // نقطة التحكم للبتلة
      final controlX = centerX + radius * 0.7 * math.cos(angle);
      final controlY = centerY + radius * 0.7 * math.sin(angle);
      
      // نقطة نهاية البتلة
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

  void _drawStaticElements(Canvas canvas, Size size, Paint paint) {
    // عناصر ثابتة في الزوايا مستوحاة من الفن الإسلامي
    final corners = [
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.85),
    ];
    
    for (int i = 0; i < corners.length; i++) {
      _drawCornerArabesque(canvas, corners[i], paint, i);
    }
  }

  void _drawCornerArabesque(Canvas canvas, Offset position, Paint paint, int cornerIndex) {
    // رسم زخرفة عربية في الزاوية
    final path = Path();
    
    // شكل زخرفي عربي مبسط
    switch (cornerIndex % 4) {
      case 0: // زاوية علوية يسرى
        _drawFlowerMotif(canvas, position, paint);
        break;
      case 1: // زاوية علوية يمنى
        _drawGeometricMotif(canvas, position, paint);
        break;
      case 2: // زاوية سفلية يسرى
        _drawLeafMotif(canvas, position, paint);
        break;
      case 3: // زاوية سفلية يمنى
        _drawStarMotif(canvas, position, paint);
        break;
    }
  }

  void _drawFlowerMotif(Canvas canvas, Offset position, Paint paint) {
    // رسم زهرة مبسطة
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi) / 3;
      final petalEnd = Offset(
        position.dx + 12 * math.cos(angle),
        position.dy + 12 * math.sin(angle),
      );
      
      canvas.drawLine(position, petalEnd, paint);
      canvas.drawCircle(petalEnd, 2, paint);
    }
    
    canvas.drawCircle(position, 3, paint);
  }

  void _drawGeometricMotif(Canvas canvas, Offset position, Paint paint) {
    // رسم نمط هندسي
    final size = 15.0;
    final path = Path();
    
    // مربع مدور
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: position, width: size, height: size),
      const Radius.circular(3),
    ));
    
    // مربع داخلي أصغر
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: position, width: size * 0.6, height: size * 0.6),
      const Radius.circular(2),
    ));
    
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  void _drawLeafMotif(Canvas canvas, Offset position, Paint paint) {
    // رسم ورقة
    final path = Path();
    
    path.moveTo(position.dx, position.dy);
    path.quadraticBezierTo(
      position.dx + 8, position.dy - 5,
      position.dx + 15, position.dy,
    );
    path.quadraticBezierTo(
      position.dx + 8, position.dy + 5,
      position.dx, position.dy,
    );
    
    canvas.drawPath(path, paint);
    
    // عرق الورقة
    canvas.drawLine(
      position,
      Offset(position.dx + 15, position.dy),
      paint,
    );
  }

  void _drawStarMotif(Canvas canvas, Offset position, Paint paint) {
    // رسم نجمة سداسية
    _drawStar8(canvas, position, 8, paint);
  }

  @override
  bool shouldRepaint(covariant DuaPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.color != color;
  }
}