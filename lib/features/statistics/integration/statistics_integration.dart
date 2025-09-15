// lib/features/statistics/integration/statistics_integration.dart (محسن ومصحح نهائياً)

import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';
import '../models/statistics_models.dart';

/// مدير التكامل بين الإحصائيات والخدمات الأخرى
/// يحتوي على جميع دوال الإحصائيات المركزية
class StatisticsIntegration {
  static final StatisticsIntegration _instance = StatisticsIntegration._internal();
  factory StatisticsIntegration() => _instance;
  StatisticsIntegration._internal();

  late final StatisticsService _statisticsService;
  DateTime? _sessionStartTime;
  String? _currentSessionType;
  Map<String, dynamic>? _sessionData;

  /// تهيئة التكامل
  void initialize() {
    _statisticsService = getIt<StatisticsService>();
  }

  // ==================== جلسات الأذكار ====================

  /// بدء جلسة أذكار
  void startAthkarSession(String categoryId, {Map<String, dynamic>? metadata}) {
    _sessionStartTime = DateTime.now();
    _currentSessionType = 'athkar';
    _sessionData = {
      'categoryId': categoryId,
      'metadata': metadata ?? {},
      'startTime': _sessionStartTime,
    };
  }

  /// إنهاء جلسة أذكار وتسجيل النتائج
  Future<void> endAthkarSession({
    required String categoryId,
    required String categoryName,
    required int itemsCompleted,
    required int totalItems,
  }) async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!);
    
    await _statisticsService.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: itemsCompleted,
      totalItems: totalItems,
      duration: duration,
    );

    _resetSession();
  }

  /// تسجيل إكمال فئة أذكار كاملة
  Future<void> recordCategoryCompletion({
    required String categoryId,
    required String categoryName,
    required int itemsCount,
    Duration? duration,
  }) async {
    await _statisticsService.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: itemsCount,
      totalItems: itemsCount,
      duration: duration ?? const Duration(minutes: 5),
    );
  }

  /// تسجيل تقدم جزئي في فئة
  Future<void> recordPartialProgress({
    required String categoryId,
    required String categoryName,
    required int itemsCompleted,
    required int totalItems,
    Duration? duration,
  }) async {
    await _statisticsService.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: itemsCompleted,
      totalItems: totalItems,
      duration: duration ?? Duration(seconds: itemsCompleted * 30),
    );
  }

  /// تسجيل إكمال ذكر واحد
  Future<void> recordSingleAthkar({
    required String categoryId,
    required String categoryName,
    required String itemText,
  }) async {
    await _statisticsService.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: 1,
      totalItems: 1,
      duration: const Duration(seconds: 30),
    );
  }

  // ==================== جلسات التسبيح ====================

  /// بدء جلسة تسبيح
  void startTasbihSession(String dhikrType, {Map<String, dynamic>? metadata}) {
    _sessionStartTime = DateTime.now();
    _currentSessionType = 'tasbih';
    _sessionData = {
      'dhikrType': dhikrType,
      'metadata': metadata ?? {},
      'startTime': _sessionStartTime,
    };
  }

  /// إنهاء جلسة تسبيح وتسجيل النتائج
  Future<void> endTasbihSession({
    required String dhikrType,
    required int count,
  }) async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!);
    
    await _statisticsService.recordTasbihActivity(
      dhikrType: dhikrType,
      count: count,
      duration: duration,
    );

    _resetSession();
  }

  /// تسجيل تسبيحة واحدة
  Future<void> recordSingleTasbih(String dhikrType) async {
    await _statisticsService.recordTasbihActivity(
      dhikrType: dhikrType,
      count: 1,
      duration: const Duration(seconds: 1),
    );
  }

  /// تسجيل مجموعة تسابيح
  Future<void> recordBatchTasbih({
    required String dhikrType,
    required int count,
    Duration? estimatedDuration,
  }) async {
    await _statisticsService.recordTasbihActivity(
      dhikrType: dhikrType,
      count: count,
      duration: estimatedDuration ?? Duration(seconds: count * 2),
    );
  }

  // ==================== الإحصائيات المجمعة ====================

  /// الحصول على إحصائيات الأذكار
  Future<Map<String, dynamic>> getAthkarStatistics() async {
    final overallStats = await _statisticsService.getOverallStatistics();
    final todayStats = _statisticsService.getTodayStatistics();
    
    return {
      'today': {
        'completed': todayStats.athkarCompleted,
        'categories': todayStats.athkarCategories,
        'points': todayStats.totalPoints,
        'time': todayStats.totalTime.inMinutes,
      },
      'overall': {
        'total': overallStats.totalAthkarCompleted,
        'streak': overallStats.currentStreak,
        'longestStreak': overallStats.longestStreak,
        'favorites': overallStats.favoriteAthkar,
        'dailyAverage': overallStats.dailyAverage,
        'totalDays': overallStats.totalDays, // أضفت هذا السطر للتأكد من وجود totalDays
      },
      'progress': _calculateAthkarProgress(todayStats, overallStats),
    };
  }

  /// الحصول على إحصائيات التسبيح
  Future<Map<String, dynamic>> getTasbihStatistics() async {
    final overallStats = await _statisticsService.getOverallStatistics();
    final todayStats = _statisticsService.getTodayStatistics();
    
    return {
      'today': {
        'count': todayStats.tasbihCount,
        'points': _calculateTasbihPoints(todayStats.tasbihCount),
        'time': _estimateTasbihTime(todayStats.tasbihCount),
      },
      'overall': {
        'total': overallStats.totalTasbihCount,
        'streak': overallStats.currentStreak,
        'favorites': overallStats.favoriteDhikr,
        'dailyAverage': overallStats.totalDays > 0 
            ? (overallStats.totalTasbihCount / overallStats.totalDays).toStringAsFixed(1)
            : '0',
        'totalDays': overallStats.totalDays,
      },
      'achievements': _getTasbihAchievements(overallStats),
    };
  }

  /// الحصول على إحصائيات مجمعة للوحة القيادة
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    final overallStats = await _statisticsService.getOverallStatistics();
    final todayStats = _statisticsService.getTodayStatistics();
    final periodStats = _statisticsService.getPeriodStatistics(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
    
    return {
      'summary': {
        'totalPoints': overallStats.totalPoints,
        'currentStreak': overallStats.currentStreak,
        'activeDays': periodStats.activeDays,
        'totalTime': overallStats.totalTime.inHours,
      },
      'today': {
        'athkar': todayStats.athkarCompleted,
        'tasbih': todayStats.tasbihCount,
        'points': todayStats.totalPoints,
        'goals': todayStats.completedGoals.length,
      },
      'weekly': {
        'activeDays': periodStats.activeDays,
        'totalDays': periodStats.totalDays,
        'averageDaily': periodStats.averageDaily,
        'breakdown': periodStats.activityBreakdown,
      },
      'achievements': {
        'unlocked': overallStats.achievements.length,
        'recent': _getRecentAchievements(overallStats.achievements),
      },
    };
  }

  // ==================== إدارة الأهداف ====================

  /// إنشاء هدف جديد
  Future<void> createGoal({
    required String title,
    required String description,
    required GoalType type,
    required int targetValue,
    required int rewardPoints,
  }) async {
    final deadline = _calculateGoalDeadline(type);
    
    final goal = StatisticsGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentValue: 0,
      deadline: deadline,
      rewardPoints: rewardPoints,
      isCompleted: false,
    );
    
    await _statisticsService.addGoal(goal);
  }

  /// تحديث تقدم هدف معين
  Future<void> updateGoalProgress(String goalId, int incrementValue) async {
    // يتم التحديث تلقائياً من خلال StatisticsService
  }

  // ==================== دوال مساعدة خاصة ====================

  void _resetSession() {
    _sessionStartTime = null;
    _currentSessionType = null;
    _sessionData = null;
  }

  Map<String, dynamic> _calculateAthkarProgress(
    DailyStatistics today,
    OverallStatistics overall,
  ) {
    final dailyTarget = 100; // هدف يومي افتراضي
    final weeklyTarget = 500; // هدف أسبوعي
    
    return {
      'daily': (today.athkarCompleted / dailyTarget * 100).clamp(0, 100),
      'weekly': (overall.totalAthkarCompleted / weeklyTarget * 100).clamp(0, 100),
      'streak': overall.currentStreak,
      'nextMilestone': _getNextMilestone(overall.totalAthkarCompleted),
    };
  }

  int _calculateTasbihPoints(int count) {
    return count ~/ 10; // نقطة لكل 10 تسبيحات
  }

  int _estimateTasbihTime(int count) {
    return count * 2; // تقدير: 2 ثانية لكل تسبيحة
  }

  List<Map<String, dynamic>> _getTasbihAchievements(OverallStatistics stats) {
    return stats.achievements
        .where((a) => a.category == AchievementCategory.tasbih)
        .map((a) => {
          'title': a.title,
          'unlocked': a.isUnlocked,
          'date': a.unlockedAt,
        })
        .toList();
  }

  List<Achievement> _getRecentAchievements(List<Achievement> achievements) {
    final sorted = achievements.where((a) => a.isUnlocked).toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
    
    return sorted.take(3).toList();
  }

  int _getNextMilestone(int current) {
    const milestones = [100, 250, 500, 1000, 2500, 5000, 10000];
    return milestones.firstWhere((m) => m > current, orElse: () => 10000);
  }

  DateTime _calculateGoalDeadline(GoalType type) {
    final now = DateTime.now();
    switch (type) {
      case GoalType.daily:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case GoalType.weekly:
        return now.add(const Duration(days: 7));
      case GoalType.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case GoalType.custom:
        return now.add(const Duration(days: 30));
    }
  }

  /// الحصول على معلومات الجلسة الحالية
  Map<String, dynamic>? getCurrentSessionInfo() {
    if (_sessionStartTime == null) return null;
    
    return {
      'type': _currentSessionType,
      'duration': DateTime.now().difference(_sessionStartTime!),
      'data': _sessionData,
    };
  }

  /// إلغاء الجلسة الحالية
  void cancelCurrentSession() {
    _resetSession();
  }
}