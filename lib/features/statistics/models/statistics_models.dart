// lib/features/statistics/models/statistics_models.dart

import 'package:flutter/material.dart';

/// نوع النشاط (أذكار أو تسبيح)
enum ActivityType {
  athkar('أذكار', Icons.menu_book_rounded),
  tasbih('تسبيح', Icons.radio_button_checked);

  const ActivityType(this.title, this.icon);
  final String title;
  final IconData icon;
}

/// سجل نشاط موحد
class ActivityRecord {
  final String id;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final int points; // نقاط الإنجاز

  ActivityRecord({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.data,
    required this.points,
  });

  factory ActivityRecord.fromMap(Map<String, dynamic> map) {
    return ActivityRecord(
      id: map['id'],
      type: ActivityType.values.firstWhere(
        (t) => t.name == map['type'],
      ),
      timestamp: DateTime.parse(map['timestamp']),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      points: map['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'points': points,
    };
  }
}

/// إحصائيات يومية
class DailyStatistics {
  final DateTime date;
  final int athkarCompleted;
  final int athkarCategories;
  final int tasbihCount;
  final int totalPoints;
  final Duration totalTime;
  final List<String> completedGoals;

  DailyStatistics({
    required this.date,
    required this.athkarCompleted,
    required this.athkarCategories,
    required this.tasbihCount,
    required this.totalPoints,
    required this.totalTime,
    required this.completedGoals,
  });

  factory DailyStatistics.empty(DateTime date) {
    return DailyStatistics(
      date: date,
      athkarCompleted: 0,
      athkarCategories: 0,
      tasbihCount: 0,
      totalPoints: 0,
      totalTime: Duration.zero,
      completedGoals: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'athkarCompleted': athkarCompleted,
      'athkarCategories': athkarCategories,
      'tasbihCount': tasbihCount,
      'totalPoints': totalPoints,
      'totalTime': totalTime.inSeconds,
      'completedGoals': completedGoals,
    };
  }

  factory DailyStatistics.fromMap(Map<String, dynamic> map) {
    return DailyStatistics(
      date: DateTime.parse(map['date']),
      athkarCompleted: map['athkarCompleted'] ?? 0,
      athkarCategories: map['athkarCategories'] ?? 0,
      tasbihCount: map['tasbihCount'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      totalTime: Duration(seconds: map['totalTime'] ?? 0),
      completedGoals: List<String>.from(map['completedGoals'] ?? []),
    );
  }
}

/// إحصائيات أسبوعية/شهرية
class PeriodStatistics {
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int activeDays;
  final Map<ActivityType, int> activityBreakdown;
  final List<DailyStatistics> dailyStats;
  final int totalPoints;
  final Duration totalTime;
  final double averageDaily;
  final int currentStreak;
  final int longestStreak;

  PeriodStatistics({
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.activeDays,
    required this.activityBreakdown,
    required this.dailyStats,
    required this.totalPoints,
    required this.totalTime,
    required this.averageDaily,
    required this.currentStreak,
    required this.longestStreak,
  });
}

/// هدف يومي/أسبوعي
class StatisticsGoal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final int targetValue;
  final int currentValue;
  final DateTime deadline;
  final int rewardPoints;
  final bool isCompleted;

  StatisticsGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.deadline,
    required this.rewardPoints,
    required this.isCompleted,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  bool get isExpired => DateTime.now().isAfter(deadline);
}

enum GoalType {
  daily('يومي'),
  weekly('أسبوعي'),
  monthly('شهري'),
  custom('مخصص');

  const GoalType(this.title);
  final String title;
}

/// إنجاز
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final AchievementCategory category;
  final int requiredPoints;
  final DateTime? unlockedAt;
  final int level;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.category,
    required this.requiredPoints,
    this.unlockedAt,
    required this.level,
  });

  bool get isUnlocked => unlockedAt != null;
}

enum AchievementCategory {
  athkar('أذكار'),
  tasbih('تسبيح'),
  streak('استمرارية'),
  points('نقاط'),
  special('خاص');

  const AchievementCategory(this.title);
  final String title;
}

/// ملخص الإحصائيات العام
class OverallStatistics {
  final int totalAthkarCompleted;
  final int totalTasbihCount;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final Duration totalTime;
  final int totalDays;
  final double dailyAverage;
  final List<Achievement> achievements;
  final Map<String, int> favoriteAthkar;
  final Map<String, int> favoriteDhikr;
  final DateTime memberSince;

  OverallStatistics({
    required this.totalAthkarCompleted,
    required this.totalTasbihCount,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalTime,
    required this.totalDays,
    required this.dailyAverage,
    required this.achievements,
    required this.favoriteAthkar,
    required this.favoriteDhikr,
    required this.memberSince,
  });
}
