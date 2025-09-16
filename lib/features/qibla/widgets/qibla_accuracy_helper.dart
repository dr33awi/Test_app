// lib/features/qibla/widgets/qibla_accuracy_helper.dart - جديد للدقة
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// مساعد موحد لدقة البوصلة
class QiblaAccuracyHelper {
  final double accuracy;

  QiblaAccuracyHelper(this.accuracy);

  Color get color {
    if (accuracy >= 0.8) return ThemeConstants.success;
    if (accuracy >= 0.5) return ThemeConstants.warning;
    return ThemeConstants.error;
  }

  IconData get icon {
    if (accuracy >= 0.8) return Icons.gps_fixed;
    if (accuracy >= 0.5) return Icons.gps_not_fixed;
    return Icons.gps_off;
  }

  String get text {
    final percentage = (accuracy * 100).toStringAsFixed(0);
    if (accuracy >= 0.8) return 'ممتازة ($percentage%)';
    if (accuracy >= 0.5) return 'متوسطة ($percentage%)';
    return 'ضعيفة ($percentage%)';
  }

  String get description {
    if (accuracy >= 0.8) return 'الدقة ممتازة';
    if (accuracy >= 0.6) return 'الدقة جيدة';
    if (accuracy >= 0.4) return 'الدقة مقبولة';
    return 'الدقة ضعيفة، يُنصح بالمعايرة';
  }

  List<String> get improvementTips {
    if (accuracy >= 0.8) return [];
    
    final tips = <String>[];
    if (accuracy < 0.7) {
      tips.add('ابتعد عن الأجهزة الإلكترونية');
    }
    if (accuracy < 0.5) {
      tips.add('انتقل إلى مكان مفتوح');
      tips.add('قم بمعايرة البوصلة');
    }
    return tips;
  }
}