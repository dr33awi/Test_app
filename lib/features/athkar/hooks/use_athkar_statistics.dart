// lib/features/athkar/hooks/use_athkar_statistics.dart

import 'package:flutter/material.dart';
import '../../../app/di/service_locator.dart';
import '../../statistics/services/statistics_service.dart';
import '../../statistics/integration/statistics_integration.dart';
import '../services/athkar_service.dart';

/// Hook للوصول السريع لإحصائيات الأذكار
class UseAthkarStatistics {
  final BuildContext context;
  late final StatisticsService _statsService;
  late final AthkarService _athkarService;
  late final StatisticsIntegration _integration;

  UseAthkarStatistics(this.context) {
    _statsService = getIt<StatisticsService>();
    _athkarService = getIt<AthkarService>();
    _integration = StatisticsIntegration();
  }

  /// بدء جلسة أذكار جديدة
  void startSession(String categoryId) {
    _integration.startAthkarSession(categoryId);
  }

  /// إنهاء جلسة أذكار
  Future<void> endSession({
    required String categoryId,
    required String categoryName,
    required int itemsCompleted,
    required int totalItems,
  }) async {
    await _integration.endAthkarSession(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: itemsCompleted,
      totalItems: totalItems,
    );
  }

  /// تسجيل إكمال ذكر واحد
  Future<void> recordSingleCompletion({
    required String categoryId,
    required String categoryName,
    required String itemText,
  }) async {
    await _integration.recordSingleAthkar(
      categoryId: categoryId,
      categoryName: categoryName,
      itemText: itemText,
    );
  }

  /// الحصول على إحصائيات فئة معينة
  Future<CategoryStatistics> getCategoryStats(String categoryId) async {
    return await _athkarService.getCategoryStatistics(categoryId);
  }

  /// الحصول على إحصائيات اليوم للأذكار
  int get todayAthkarCount => _statsService.getTodayStatistics().athkarCompleted;

  /// الحصول على عدد الفئات المكتملة اليوم
  int get todayCompletedCategories => _statsService.getTodayStatistics().athkarCategories;

  /// الحصول على النقاط المكتسبة من الأذكار اليوم
  int get todayAthkarPoints {
    final todayStats = _statsService.getTodayStatistics();
    // حساب تقريبي للنقاط من الأذكار فقط
    return todayStats.athkarCompleted * 5;
  }

  /// الحصول على السلسلة الحالية
  int get currentStreak => _statsService.currentStreak;

  /// التحقق من وجود إنجاز جديد
  bool checkForNewAchievements() {
    final previousCount = _statsService.unlockedAchievements.length;
    // يمكن إضافة منطق للتحقق من الإنجازات الجديدة
    return _statsService.unlockedAchievements.length > previousCount;
  }

  /// الحصول على التقدم نحو الهدف التالي
  double getProgressToNextGoal() {
    final activeGoals = _statsService.activeGoals;
    if (activeGoals.isEmpty) return 0.0;
    
    // البحث عن هدف يتعلق بالأذكار
    final athkarGoal = activeGoals.firstWhere(
      (goal) => goal.description.contains('أذكار'),
      orElse: () => activeGoals.first,
    );
    
    return athkarGoal.progress;
  }

  /// مزامنة البيانات مع نظام الإحصائيات
  Future<void> syncStatistics() async {
    await _athkarService.syncWithStatisticsService();
  }
}