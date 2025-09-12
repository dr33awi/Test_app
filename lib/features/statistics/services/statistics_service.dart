// lib/features/statistics/services/statistics_service.dart

import 'package:athkar_app/features/statistics/models/statistics_models.dart';
import 'package:flutter/material.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';

/// خدمة الإحصائيات الموحدة
class StatisticsService extends ChangeNotifier {
  final StorageService _storage;
  final LoggerService _logger;

  // مفاتيح التخزين
  static const String _dailyStatsKey = 'statistics_daily';
  static const String _activitiesKey = 'statistics_activities';
  static const String _achievementsKey = 'statistics_achievements';
  static const String _goalsKey = 'statistics_goals';
  static const String _streakKey = 'statistics_streak';

  // البيانات المحلية
  final Map<DateTime, DailyStatistics> _dailyStats = {};
  final List<ActivityRecord> _recentActivities = [];
  final List<Achievement> _achievements = [];
  final List<StatisticsGoal> _activeGoals = [];
  
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalPoints = 0;

  StatisticsService({
    required StorageService storage,
    required LoggerService logger,
  })  : _storage = storage,
        _logger = logger {
    _loadData();
  }

  // ==================== Getters ====================
  
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalPoints => _totalPoints;
  
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  
  List<StatisticsGoal> get activeGoals => 
      _activeGoals.where((g) => !g.isExpired).toList();

  // ==================== تسجيل الأنشطة ====================

  /// تسجيل نشاط أذكار
  Future<void> recordAthkarActivity({
    required String categoryId,
    required String categoryName,
    required int itemsCompleted,
    required int totalItems,
    required Duration duration,
  }) async {
    try {
      final points = _calculateAthkarPoints(itemsCompleted, totalItems);
      
      final record = ActivityRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ActivityType.athkar,
        timestamp: DateTime.now(),
        data: {
          'categoryId': categoryId,
          'categoryName': categoryName,
          'itemsCompleted': itemsCompleted,
          'totalItems': totalItems,
          'completionRate': (itemsCompleted / totalItems * 100).round(),
          'duration': duration.inSeconds,
        },
        points: points,
      );

      await _addActivityRecord(record);
      await _updateDailyStats(record);
      await _checkAchievements();
      await _updateGoalProgress(ActivityType.athkar, itemsCompleted);

      _logger.info(
        message: '[StatisticsService] Athkar activity recorded',
        data: {
          'category': categoryName,
          'completed': itemsCompleted,
          'points': points,
        },
      );

      notifyListeners();
    } catch (e) {
      _logger.error(
        message: '[StatisticsService] Error recording athkar activity',
        error: e,
      );
    }
  }

  /// تسجيل نشاط تسبيح
  Future<void> recordTasbihActivity({
    required String dhikrType,
    required int count,
    required Duration duration,
  }) async {
    try {
      final points = _calculateTasbihPoints(count);
      
      final record = ActivityRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ActivityType.tasbih,
        timestamp: DateTime.now(),
        data: {
          'dhikrType': dhikrType,
          'count': count,
          'duration': duration.inSeconds,
        },
        points: points,
      );

      await _addActivityRecord(record);
      await _updateDailyStats(record);
      await _checkAchievements();
      await _updateGoalProgress(ActivityType.tasbih, count);

      _logger.info(
        message: '[StatisticsService] Tasbih activity recorded',
        data: {
          'dhikr': dhikrType,
          'count': count,
          'points': points,
        },
      );

      notifyListeners();
    } catch (e) {
      _logger.error(
        message: '[StatisticsService] Error recording tasbih activity',
        error: e,
      );
    }
  }

  // ==================== الإحصائيات ====================

  /// الحصول على إحصائيات اليوم
  DailyStatistics getTodayStatistics() {
    final today = _normalizeDate(DateTime.now());
    return _dailyStats[today] ?? DailyStatistics.empty(today);
  }

  /// الحصول على إحصائيات فترة معينة
  PeriodStatistics getPeriodStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final normalizedStart = _normalizeDate(startDate);
    final normalizedEnd = _normalizeDate(endDate);
    
    final dailyStats = <DailyStatistics>[];
    final activityBreakdown = <ActivityType, int>{
      ActivityType.athkar: 0,
      ActivityType.tasbih: 0,
    };
    
    int totalPoints = 0;
    Duration totalTime = Duration.zero;
    int activeDays = 0;
    
    // جمع الإحصائيات اليومية
    for (var date = normalizedStart;
         !date.isAfter(normalizedEnd);
         date = date.add(const Duration(days: 1))) {
      
      final dayStats = _dailyStats[date];
      if (dayStats != null) {
        dailyStats.add(dayStats);
        activityBreakdown[ActivityType.athkar] = 
            (activityBreakdown[ActivityType.athkar] ?? 0) + dayStats.athkarCompleted;
        activityBreakdown[ActivityType.tasbih] = 
            (activityBreakdown[ActivityType.tasbih] ?? 0) + dayStats.tasbihCount;
        totalPoints += dayStats.totalPoints;
        totalTime += dayStats.totalTime;
        if (dayStats.athkarCompleted > 0 || dayStats.tasbihCount > 0) {
          activeDays++;
        }
      }
    }
    
    final totalDays = normalizedEnd.difference(normalizedStart).inDays + 1;
    final averageDaily = activeDays > 0 ? totalPoints / activeDays : 0.0;
    
    return PeriodStatistics(
      startDate: normalizedStart,
      endDate: normalizedEnd,
      totalDays: totalDays,
      activeDays: activeDays,
      activityBreakdown: activityBreakdown,
      dailyStats: dailyStats,
      totalPoints: totalPoints,
      totalTime: totalTime,
      averageDaily: averageDaily,
      currentStreak: _currentStreak,
      longestStreak: _longestStreak,
    );
  }

  /// الحصول على الإحصائيات الإجمالية
  Future<OverallStatistics> getOverallStatistics() async {
    int totalAthkar = 0;
    int totalTasbih = 0;
    Duration totalTime = Duration.zero;
    
    for (final stats in _dailyStats.values) {
      totalAthkar += stats.athkarCompleted;
      totalTasbih += stats.tasbihCount;
      totalTime += stats.totalTime;
    }
    
    final dailyAverage = _dailyStats.isNotEmpty 
        ? _totalPoints / _dailyStats.length 
        : 0.0;
    
    // تحليل الأذكار والتسابيح المفضلة
    final favoriteAthkar = await _analyzeFavoriteAthkar();
    final favoriteDhikr = await _analyzeFavoriteDhikr();
    
    // تاريخ أول استخدام
    final memberSince = _dailyStats.isEmpty 
        ? DateTime.now()
        : _dailyStats.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    
    return OverallStatistics(
      totalAthkarCompleted: totalAthkar,
      totalTasbihCount: totalTasbih,
      totalPoints: _totalPoints,
      currentStreak: _currentStreak,
      longestStreak: _longestStreak,
      totalTime: totalTime,
      totalDays: _dailyStats.length,
      dailyAverage: dailyAverage,
      achievements: _achievements.where((a) => a.isUnlocked).toList(),
      favoriteAthkar: favoriteAthkar,
      favoriteDhikr: favoriteDhikr,
      memberSince: memberSince,
    );
  }

  // ==================== الأهداف ====================

  /// إضافة هدف جديد
  Future<void> addGoal(StatisticsGoal goal) async {
    _activeGoals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  /// تحديث تقدم الهدف
  Future<void> _updateGoalProgress(ActivityType type, int value) async {
    bool updated = false;
    
    for (final goal in _activeGoals) {
      if (!goal.isCompleted && !goal.isExpired) {
        // تحديث الهدف بناءً على النوع
        if (_shouldUpdateGoal(goal, type)) {
          final updatedGoal = _updateGoalValue(goal, value);
          final index = _activeGoals.indexOf(goal);
          _activeGoals[index] = updatedGoal;
          
          // التحقق من إكمال الهدف
          if (updatedGoal.isCompleted && !goal.isCompleted) {
            await _onGoalCompleted(updatedGoal);
          }
          
          updated = true;
        }
      }
    }
    
    if (updated) {
      await _saveGoals();
      notifyListeners();
    }
  }

  // ==================== الإنجازات ====================

  /// التحقق من الإنجازات الجديدة
  Future<void> _checkAchievements() async {
    final allAchievements = _getAchievementDefinitions();
    bool hasNewAchievement = false;
    
    for (final achievement in allAchievements) {
      if (!achievement.isUnlocked) {
        final isUnlocked = await _checkAchievementCriteria(achievement);
        
        if (isUnlocked) {
          final unlockedAchievement = Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            iconAsset: achievement.iconAsset,
            category: achievement.category,
            requiredPoints: achievement.requiredPoints,
            level: achievement.level,
            unlockedAt: DateTime.now(),
          );
          
          _achievements.add(unlockedAchievement);
          hasNewAchievement = true;
          
          _logger.info(
            message: '[StatisticsService] Achievement unlocked',
            data: {'achievement': achievement.title},
          );
        }
      }
    }
    
    if (hasNewAchievement) {
      await _saveAchievements();
      notifyListeners();
    }
  }

  // ==================== السلاسل (Streaks) ====================

  /// تحديث السلسلة الحالية
  Future<void> _updateStreak() async {
    final today = _normalizeDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayStats = _dailyStats[today];
    final yesterdayStats = _dailyStats[yesterday];
    
    if (todayStats != null && 
        (todayStats.athkarCompleted > 0 || todayStats.tasbihCount > 0)) {
      
      if (yesterdayStats != null) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
      
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
      
      await _saveStreak();
    }
  }

  // ==================== المساعدة الخاصة ====================

  int _calculateAthkarPoints(int completed, int total) {
    final completionRate = completed / total;
    int basePoints = completed * 5;
    
    // مكافآت إضافية للإكمال
    if (completionRate >= 1.0) {
      basePoints += 50; // مكافأة الإكمال الكامل
    } else if (completionRate >= 0.75) {
      basePoints += 25;
    } else if (completionRate >= 0.5) {
      basePoints += 10;
    }
    
    return basePoints;
  }

  int _calculateTasbihPoints(int count) {
    int basePoints = count ~/ 10; // نقطة لكل 10 تسبيحات
    
    // مكافآت للأرقام الخاصة
    if (count >= 1000) {
      basePoints += 100;
    } else if (count >= 500) {
      basePoints += 50;
    } else if (count >= 100) {
      basePoints += 20;
    } else if (count >= 33) {
      basePoints += 10;
    }
    
    return basePoints;
  }

  Future<void> _addActivityRecord(ActivityRecord record) async {
    _recentActivities.insert(0, record);
    
    // الاحتفاظ بآخر 100 نشاط فقط
    if (_recentActivities.length > 100) {
      _recentActivities.removeRange(100, _recentActivities.length);
    }
    
    await _saveActivities();
  }

  Future<void> _updateDailyStats(ActivityRecord record) async {
    final date = _normalizeDate(record.timestamp);
    final existing = _dailyStats[date] ?? DailyStatistics.empty(date);
    
    // تحديث الإحصائيات بناءً على نوع النشاط
    final updated = DailyStatistics(
      date: date,
      athkarCompleted: existing.athkarCompleted + 
          (record.type == ActivityType.athkar 
              ? (record.data['itemsCompleted'] as int? ?? 0) 
              : 0),
      athkarCategories: existing.athkarCategories + 
          (record.type == ActivityType.athkar ? 1 : 0),
      tasbihCount: existing.tasbihCount + 
          (record.type == ActivityType.tasbih 
              ? (record.data['count'] as int? ?? 0) 
              : 0),
      totalPoints: existing.totalPoints + record.points,
      totalTime: existing.totalTime + 
          Duration(seconds: record.data['duration'] as int? ?? 0),
      completedGoals: existing.completedGoals,
    );
    
    _dailyStats[date] = updated;
    _totalPoints += record.points;
    
    await _saveDailyStats();
    await _updateStreak();
  }

  bool _shouldUpdateGoal(StatisticsGoal goal, ActivityType type) {
    // منطق تحديد ما إذا كان الهدف يجب تحديثه
    return true; // مبسط للمثال
  }

  StatisticsGoal _updateGoalValue(StatisticsGoal goal, int value) {
    return StatisticsGoal(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      type: goal.type,
      targetValue: goal.targetValue,
      currentValue: goal.currentValue + value,
      deadline: goal.deadline,
      rewardPoints: goal.rewardPoints,
      isCompleted: (goal.currentValue + value) >= goal.targetValue,
    );
  }

  Future<void> _onGoalCompleted(StatisticsGoal goal) async {
    _totalPoints += goal.rewardPoints;
    
    final today = _normalizeDate(DateTime.now());
    final todayStats = _dailyStats[today]!;
    
    _dailyStats[today] = DailyStatistics(
      date: todayStats.date,
      athkarCompleted: todayStats.athkarCompleted,
      athkarCategories: todayStats.athkarCategories,
      tasbihCount: todayStats.tasbihCount,
      totalPoints: todayStats.totalPoints + goal.rewardPoints,
      totalTime: todayStats.totalTime,
      completedGoals: [...todayStats.completedGoals, goal.id],
    );
    
    await _saveDailyStats();
  }

  List<Achievement> _getAchievementDefinitions() {
    // قائمة تعريفات الإنجازات
    return [
      Achievement(
        id: 'first_athkar',
        title: 'البداية المباركة',
        description: 'أكمل أول فئة أذكار',
        iconAsset: 'assets/icons/achievements/first_athkar.png',
        category: AchievementCategory.athkar,
        requiredPoints: 0,
        level: 1,
      ),
      Achievement(
        id: 'tasbih_100',
        title: 'المُسبِّح',
        description: 'سبِّح 100 مرة',
        iconAsset: 'assets/icons/achievements/tasbih_100.png',
        category: AchievementCategory.tasbih,
        requiredPoints: 0,
        level: 1,
      ),
      Achievement(
        id: 'streak_7',
        title: 'الثابت',
        description: 'حافظ على الاستمرارية لمدة 7 أيام',
        iconAsset: 'assets/icons/achievements/streak_7.png',
        category: AchievementCategory.streak,
        requiredPoints: 0,
        level: 2,
      ),
      // المزيد من الإنجازات...
    ];
  }

  Future<bool> _checkAchievementCriteria(Achievement achievement) async {
    // منطق التحقق من معايير الإنجاز
    switch (achievement.id) {
      case 'first_athkar':
        return _dailyStats.values.any((s) => s.athkarCategories > 0);
      case 'tasbih_100':
        return _dailyStats.values.any((s) => s.tasbihCount >= 100);
      case 'streak_7':
        return _currentStreak >= 7;
      default:
        return false;
    }
  }

  Future<Map<String, int>> _analyzeFavoriteAthkar() async {
    final frequency = <String, int>{};
    
    for (final activity in _recentActivities) {
      if (activity.type == ActivityType.athkar) {
        final categoryName = activity.data['categoryName'] as String?;
        if (categoryName != null) {
          frequency[categoryName] = (frequency[categoryName] ?? 0) + 1;
        }
      }
    }
    
    // ترتيب وأخذ أعلى 5
    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(5));
  }

  Future<Map<String, int>> _analyzeFavoriteDhikr() async {
    final frequency = <String, int>{};
    
    for (final activity in _recentActivities) {
      if (activity.type == ActivityType.tasbih) {
        final dhikrType = activity.data['dhikrType'] as String?;
        if (dhikrType != null) {
          frequency[dhikrType] = (frequency[dhikrType] ?? 0) + 1;
        }
      }
    }
    
    // ترتيب وأخذ أعلى 5
    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(5));
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ==================== التخزين والتحميل ====================

  Future<void> _loadData() async {
    await _loadDailyStats();
    await _loadActivities();
    await _loadAchievements();
    await _loadGoals();
    await _loadStreak();
  }

  Future<void> _loadDailyStats() async {
    try {
      final data = _storage.getMap(_dailyStatsKey);
      if (data != null) {
        _dailyStats.clear();
        data.forEach((key, value) {
          final date = DateTime.parse(key);
          _dailyStats[date] = DailyStatistics.fromMap(
            Map<String, dynamic>.from(value),
          );
        });
      }
    } catch (e) {
      _logger.error(
        message: '[StatisticsService] Error loading daily stats',
        error: e,
      );
    }
  }

  Future<void> _saveDailyStats() async {
    try {
      final data = <String, dynamic>{};
      _dailyStats.forEach((date, stats) {
        data[date.toIso8601String()] = stats.toMap();
      });
      await _storage.setMap(_dailyStatsKey, data);
    } catch (e) {
      _logger.error(
        message: '[StatisticsService] Error saving daily stats',
        error: e,
      );
    }
  }

  Future<void> _loadActivities() async {
    try {
      final data = _storage.getList(_activitiesKey);
      if (data != null) {
        _recentActivities.clear();
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            _recentActivities.add(ActivityRecord.fromMap(item));
          }
        }
      }
    } catch (e) {
      _logger.error(
        message: '[StatisticsService] Error loading activities',
        error: e,
      );
    }
  }

  Future<void> _saveActivities() async {
    try {
      final data = _recentActivities.map((a) => a.toMap()).toList();
      await _storage.setList(_activitiesKey, data);
    } catch (e) {
      _logger.error(
        message: '[StatisticsService] Error saving activities',
        error: e,
      );
    }
  }

  Future<void> _loadAchievements() async {
    // تحميل الإنجازات المحفوظة
  }

  Future<void> _saveAchievements() async {
    // حفظ الإنجازات
  }

  Future<void> _loadGoals() async {
    // تحميل الأهداف
  }

  Future<void> _saveGoals() async {
    // حفظ الأهداف
  }

  Future<void> _loadStreak() async {
    _currentStreak = _storage.getInt('${_streakKey}_current') ?? 0;
    _longestStreak = _storage.getInt('${_streakKey}_longest') ?? 0;
  }

  Future<void> _saveStreak() async {
    await _storage.setInt('${_streakKey}_current', _currentStreak);
    await _storage.setInt('${_streakKey}_longest', _longestStreak);
  }

  @override
  void dispose() {
    // تنظيف الموارد
    super.dispose();
  }
}