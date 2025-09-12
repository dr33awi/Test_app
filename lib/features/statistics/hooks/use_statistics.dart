// lib/features/statistics/hooks/use_statistics.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';

/// هوك للوصول السريع للإحصائيات
class UseStatistics {
  final BuildContext context;
  late final StatisticsService _service;

  UseStatistics(this.context) {
    _service = context.read<StatisticsService>();
  }

  /// الحصول على إحصائيات اليوم
  DailyStatistics get todayStats => _service.getTodayStatistics();

  /// الحصول على السلسلة الحالية
  int get currentStreak => _service.currentStreak;

  /// الحصول على إجمالي النقاط
  int get totalPoints => _service.totalPoints;

  /// الحصول على الأهداف النشطة
  List<StatisticsGoal> get activeGoals => _service.activeGoals;

  /// الحصول على الإنجازات المفتوحة
  List<Achievement> get unlockedAchievements => _service.unlockedAchievements;

  /// تسجيل نشاط أذكار
  Future<void> recordAthkar({
    required String categoryId,
    required String categoryName,
    required int completed,
    required int total,
  }) async {
    await _service.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: completed,
      totalItems: total,
      duration: const Duration(minutes: 5), // تقدير
    );
  }

  /// تسجيل نشاط تسبيح
  Future<void> recordTasbih({
    required String dhikrType,
    required int count,
  }) async {
    await _service.recordTasbihActivity(
      dhikrType: dhikrType,
      count: count,
      duration: Duration(seconds: count * 2), // تقدير: ثانيتان لكل تسبيحة
    );
  }

  /// الحصول على إحصائيات فترة معينة
  Future<PeriodStatistics> getPeriodStats({
    required DateTime start,
    required DateTime end,
  }) async {
    return _service.getPeriodStatistics(
      startDate: start,
      endDate: end,
    );
  }

  /// الحصول على الإحصائيات الإجمالية
  Future<OverallStatistics> getOverallStats() async {
    return _service.getOverallStatistics();
  }

  /// إضافة هدف جديد
  Future<void> addGoal(StatisticsGoal goal) async {
    await _service.addGoal(goal);
  }

  /// الاستماع للتغييرات
  void listen(VoidCallback callback) {
    _service.addListener(callback);
  }

  /// إلغاء الاستماع
  void removeListener(VoidCallback callback) {
    _service.removeListener(callback);
  }
}