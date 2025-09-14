// lib/features/statistics/models/challenges_system.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';

/// نظام التحديات والمهام
class ChallengesSystem {
  static final ChallengesSystem _instance = ChallengesSystem._internal();
  factory ChallengesSystem() => _instance;
  ChallengesSystem._internal();
  
  final StorageService _storage = getIt<StorageService>();
  final _random = math.Random();
  
  // ==================== تعريف التحديات ====================
  
  /// قائمة التحديات اليومية المتاحة
  final List<ChallengeTemplate> dailyChallengeTemplates = [
    ChallengeTemplate(
      id: 'morning_early',
      title: 'الطائر المبكر',
      description: 'أكمل أذكار الصباح قبل الساعة 7',
      type: ChallengeType.daily,
      category: ChallengeCategory.timing,
      icon: Icons.wb_sunny,
      color: Colors.orange,
      requirements: {
        'action': 'complete_athkar',
        'category': 'morning',
        'before_time': '07:00',
      },
      rewardPoints: 50,
      difficulty: ChallengeDifficulty.easy,
    ),
    
    ChallengeTemplate(
      id: 'tasbih_100',
      title: 'المسبّح',
      description: 'أكمل 100 تسبيحة',
      type: ChallengeType.daily,
      category: ChallengeCategory.tasbih,
      icon: Icons.radio_button_checked,
      color: Colors.blue,
      requirements: {
        'action': 'tasbih_count',
        'count': 100,
      },
      rewardPoints: 30,
      difficulty: ChallengeDifficulty.easy,
    ),
    
    ChallengeTemplate(
      id: 'complete_all',
      title: 'الكامل',
      description: 'أكمل جميع فئات الأذكار',
      type: ChallengeType.daily,
      category: ChallengeCategory.completion,
      icon: Icons.check_circle,
      color: Colors.green,
      requirements: {
        'action': 'complete_all_categories',
      },
      rewardPoints: 100,
      difficulty: ChallengeDifficulty.hard,
    ),
    
    ChallengeTemplate(
      id: 'streak_maintain',
      title: 'المحافظ',
      description: 'حافظ على سلسلتك اليومية',
      type: ChallengeType.daily,
      category: ChallengeCategory.streak,
      icon: Icons.local_fire_department,
      color: Colors.red,
      requirements: {
        'action': 'maintain_streak',
      },
      rewardPoints: 40,
      difficulty: ChallengeDifficulty.medium,
    ),
    
    ChallengeTemplate(
      id: 'evening_time',
      title: 'ذاكر المساء',
      description: 'أكمل أذكار المساء بين المغرب والعشاء',
      type: ChallengeType.daily,
      category: ChallengeCategory.timing,
      icon: Icons.nights_stay,
      color: Colors.indigo,
      requirements: {
        'action': 'complete_athkar',
        'category': 'evening',
        'between_prayers': ['maghrib', 'isha'],
      },
      rewardPoints: 50,
      difficulty: ChallengeDifficulty.medium,
    ),
    
    ChallengeTemplate(
      id: 'specific_dhikr',
      title: 'ذكر مخصص',
      description: 'قل "سبحان الله وبحمده" 100 مرة',
      type: ChallengeType.daily,
      category: ChallengeCategory.tasbih,
      icon: Icons.stars,
      color: Colors.purple,
      requirements: {
        'action': 'specific_dhikr',
        'dhikr': 'سبحان الله وبحمده',
        'count': 100,
      },
      rewardPoints: 60,
      difficulty: ChallengeDifficulty.medium,
    ),
  ];
  
  /// قائمة التحديات الأسبوعية
  final List<ChallengeTemplate> weeklyChallengeTemplates = [
    ChallengeTemplate(
      id: 'week_perfect',
      title: 'الأسبوع المثالي',
      description: 'أكمل جميع الأذكار لمدة 7 أيام متتالية',
      type: ChallengeType.weekly,
      category: ChallengeCategory.streak,
      icon: Icons.emoji_events,
      color: Colors.amber,
      requirements: {
        'action': 'perfect_week',
        'days': 7,
      },
      rewardPoints: 500,
      difficulty: ChallengeDifficulty.hard,
    ),
    
    ChallengeTemplate(
      id: 'tasbih_1000',
      title: 'ألف تسبيحة',
      description: 'أكمل 1000 تسبيحة خلال الأسبوع',
      type: ChallengeType.weekly,
      category: ChallengeCategory.tasbih,
      icon: Icons.all_inclusive,
      color: Colors.cyan,
      requirements: {
        'action': 'weekly_tasbih',
        'count': 1000,
      },
      rewardPoints: 200,
      difficulty: ChallengeDifficulty.medium,
    ),
    
    ChallengeTemplate(
      id: 'points_collector',
      title: 'جامع النقاط',
      description: 'اجمع 1000 نقطة خلال الأسبوع',
      type: ChallengeType.weekly,
      category: ChallengeCategory.points,
      icon: Icons.star,
      color: Colors.yellow[700]!,
      requirements: {
        'action': 'collect_points',
        'points': 1000,
      },
      rewardPoints: 300,
      difficulty: ChallengeDifficulty.medium,
    ),
  ];
  
  /// التحديات الخاصة (رمضان، الجمعة، إلخ)
  final List<ChallengeTemplate> specialChallengeTemplates = [
    ChallengeTemplate(
      id: 'ramadan_30',
      title: 'صائم رمضان',
      description: 'أكمل الأذكار كل يوم في رمضان',
      type: ChallengeType.special,
      category: ChallengeCategory.seasonal,
      icon: Icons.mosque,
      color: Colors.teal,
      requirements: {
        'action': 'ramadan_complete',
        'days': 30,
      },
      rewardPoints: 3000,
      difficulty: ChallengeDifficulty.extreme,
    ),
    
    ChallengeTemplate(
      id: 'friday_special',
      title: 'يوم الجمعة',
      description: 'أكمل أذكار الجمعة والصلاة على النبي 100 مرة',
      type: ChallengeType.special,
      category: ChallengeCategory.seasonal,
      icon: Icons.event,
      color: Colors.green[700]!,
      requirements: {
        'action': 'friday_special',
        'salawat': 100,
      },
      rewardPoints: 150,
      difficulty: ChallengeDifficulty.medium,
    ),
  ];
  
  // ==================== إدارة التحديات ====================
  
  /// الحصول على التحديات اليومية النشطة
  List<Challenge> getTodaysChallenges() {
    final today = DateTime.now();
    final key = 'challenges_daily_${_dateKey(today)}';
    
    // التحقق من وجود تحديات محفوظة لليوم
    final savedData = _storage.getMap(key);
    if (savedData != null) {
      return _loadChallenges(savedData);
    }
    
    // إنشاء تحديات جديدة
    final challenges = _generateDailyChallenges();
    _saveChallenges(key, challenges);
    
    return challenges;
  }
  
  /// الحصول على التحديات الأسبوعية النشطة
  List<Challenge> getWeeklyChallenges() {
    final weekKey = 'challenges_weekly_${_getWeekKey()}';
    
    final savedData = _storage.getMap(weekKey);
    if (savedData != null) {
      return _loadChallenges(savedData);
    }
    
    final challenges = _generateWeeklyChallenges();
    _saveChallenges(weekKey, challenges);
    
    return challenges;
  }
  
  /// الحصول على التحديات الخاصة النشطة
  List<Challenge> getSpecialChallenges() {
    final activeSpecials = <Challenge>[];
    
    // تحقق من رمضان
    if (_isRamadan()) {
      final ramadanChallenge = _createChallengeFromTemplate(
        specialChallengeTemplates.firstWhere((t) => t.id == 'ramadan_30'),
      );
      activeSpecials.add(ramadanChallenge);
    }
    
    // تحقق من الجمعة
    if (DateTime.now().weekday == DateTime.friday) {
      final fridayChallenge = _createChallengeFromTemplate(
        specialChallengeTemplates.firstWhere((t) => t.id == 'friday_special'),
      );
      activeSpecials.add(fridayChallenge);
    }
    
    return activeSpecials;
  }
  
  /// تحديث تقدم التحدي
  Future<void> updateChallengeProgress(String challengeId, Map<String, dynamic> progress) async {
    final challenge = _findChallenge(challengeId);
    if (challenge == null) return;
    
    challenge.currentProgress = progress;
    
    // التحقق من الإكمال
    if (_isChallengeCompleted(challenge)) {
      challenge.status = ChallengeStatus.completed;
      challenge.completedAt = DateTime.now();
      
      // منح المكافآت
      await _grantRewards(challenge);
    }
    
    // حفظ التحديث
    _saveChallenge(challenge);
  }
  
  /// إنشاء تحدي مخصص
  Challenge createCustomChallenge({
    required String title,
    required String description,
    required Map<String, dynamic> requirements,
    required int rewardPoints,
    required Duration duration,
  }) {
    final template = ChallengeTemplate(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: ChallengeType.custom,
      category: ChallengeCategory.custom,
      icon: Icons.flag,
      color: Colors.deepPurple,
      requirements: requirements,
      rewardPoints: rewardPoints,
      difficulty: ChallengeDifficulty.medium,
    );
    
    return _createChallengeFromTemplate(template, duration: duration);
  }
  
  // ==================== دوال مساعدة خاصة ====================
  
  List<Challenge> _generateDailyChallenges() {
    final challenges = <Challenge>[];
    final selectedTemplates = <ChallengeTemplate>[];
    
    // اختر 3 تحديات عشوائية متنوعة
    final easyChallenge = _selectRandomChallenge(
      dailyChallengeTemplates.where((t) => t.difficulty == ChallengeDifficulty.easy).toList(),
    );
    if (easyChallenge != null) selectedTemplates.add(easyChallenge);
    
    final mediumChallenge = _selectRandomChallenge(
      dailyChallengeTemplates.where((t) => t.difficulty == ChallengeDifficulty.medium).toList(),
    );
    if (mediumChallenge != null) selectedTemplates.add(mediumChallenge);
    
    final hardChallenge = _selectRandomChallenge(
      dailyChallengeTemplates.where((t) => t.difficulty == ChallengeDifficulty.hard).toList(),
    );
    if (hardChallenge != null) selectedTemplates.add(hardChallenge);
    
    // إنشاء التحديات
    for (final template in selectedTemplates) {
      challenges.add(_createChallengeFromTemplate(template));
    }
    
    return challenges;
  }
  
  List<Challenge> _generateWeeklyChallenges() {
    final challenges = <Challenge>[];
    
    // اختر 2 تحديات أسبوعية
    final selected = <ChallengeTemplate>[];
    final available = List<ChallengeTemplate>.from(weeklyChallengeTemplates);
    
    for (int i = 0; i < 2 && available.isNotEmpty; i++) {
      final index = _random.nextInt(available.length);
      selected.add(available[index]);
      available.removeAt(index);
    }
    
    for (final template in selected) {
      challenges.add(_createChallengeFromTemplate(
        template,
        duration: const Duration(days: 7),
      ));
    }
    
    return challenges;
  }
  
  ChallengeTemplate? _selectRandomChallenge(List<ChallengeTemplate> templates) {
    if (templates.isEmpty) return null;
    return templates[_random.nextInt(templates.length)];
  }
  
  Challenge _createChallengeFromTemplate(ChallengeTemplate template, {Duration? duration}) {
    final now = DateTime.now();
    final endTime = duration != null 
        ? now.add(duration)
        : template.type == ChallengeType.daily
            ? DateTime(now.year, now.month, now.day, 23, 59, 59)
            : now.add(const Duration(days: 7));
    
    return Challenge(
      id: '${template.id}_${now.millisecondsSinceEpoch}',
      templateId: template.id,
      title: template.title,
      description: template.description,
      type: template.type,
      category: template.category,
      icon: template.icon,
      color: template.color,
      requirements: template.requirements,
      currentProgress: {},
      rewardPoints: template.rewardPoints,
      difficulty: template.difficulty,
      status: ChallengeStatus.active,
      startTime: now,
      endTime: endTime,
    );
  }
  
  bool _isChallengeCompleted(Challenge challenge) {
    final requirements = challenge.requirements;
    final progress = challenge.currentProgress;
    
    switch (requirements['action']) {
      case 'complete_athkar':
        return progress['completed'] == true;
      
      case 'tasbih_count':
        return (progress['count'] ?? 0) >= requirements['count'];
      
      case 'complete_all_categories':
        return progress['all_completed'] == true;
      
      case 'maintain_streak':
        return progress['streak_maintained'] == true;
      
      case 'collect_points':
        return (progress['points'] ?? 0) >= requirements['points'];
      
      default:
        return false;
    }
  }
  
  Future<void> _grantRewards(Challenge challenge) async {
    // TODO: تكامل مع نظام النقاط والإنجازات
    debugPrint('Granting ${challenge.rewardPoints} points for completing ${challenge.title}');
  }
  
  void _saveChallenges(String key, List<Challenge> challenges) {
    final data = challenges.map((c) => c.toMap()).toList();
    _storage.setList(key, data);
  }
  
  void _saveChallenge(Challenge challenge) {
    // حفظ تحدي واحد
    final key = _getChallengeKey(challenge);
    final challenges = _storage.getList(key) ?? [];
    
    final index = challenges.indexWhere((c) => c['id'] == challenge.id);
    if (index >= 0) {
      challenges[index] = challenge.toMap();
    } else {
      challenges.add(challenge.toMap());
    }
    
    _storage.setList(key, challenges);
  }
  
  List<Challenge> _loadChallenges(Map<String, dynamic> data) {
    final list = data['challenges'] as List? ?? [];
    return list.map((item) => Challenge.fromMap(item)).toList();
  }
  
  Challenge? _findChallenge(String id) {
    // البحث في جميع التحديات النشطة
    final allChallenges = [
      ...getTodaysChallenges(),
      ...getWeeklyChallenges(),
      ...getSpecialChallenges(),
    ];
    
    return allChallenges.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Challenge not found'),
    );
  }
  
  String _getChallengeKey(Challenge challenge) {
    switch (challenge.type) {
      case ChallengeType.daily:
        return 'challenges_daily_${_dateKey(DateTime.now())}';
      case ChallengeType.weekly:
        return 'challenges_weekly_${_getWeekKey()}';
      case ChallengeType.special:
        return 'challenges_special_${challenge.templateId}';
      case ChallengeType.custom:
        return 'challenges_custom';
    }
  }
  
  String _dateKey(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }
  
  String _getWeekKey() {
    final now = DateTime.now();
    final weekNumber = ((now.day - now.weekday + 10) / 7).floor();
    return '${now.year}_${now.month}_week$weekNumber';
  }
  
  bool _isRamadan() {
    // TODO: تكامل مع التقويم الهجري
    return false;
  }
}

// ==================== النماذج ====================

/// نوع التحدي
enum ChallengeType {
  daily('يومي'),
  weekly('أسبوعي'),
  special('خاص'),
  custom('مخصص');
  
  final String title;
  const ChallengeType(this.title);
}

/// فئة التحدي
enum ChallengeCategory {
  athkar('أذكار'),
  tasbih('تسبيح'),
  timing('توقيت'),
  streak('استمرارية'),
  completion('إكمال'),
  points('نقاط'),
  seasonal('موسمي'),
  custom('مخصص');
  
  final String title;
  const ChallengeCategory(this.title);
}

/// صعوبة التحدي
enum ChallengeDifficulty {
  easy('سهل', Colors.green),
  medium('متوسط', Colors.orange),
  hard('صعب', Colors.red),
  extreme('متطرف', Colors.purple);
  
  final String title;
  final Color color;
  const ChallengeDifficulty(this.title, this.color);
}

/// حالة التحدي
enum ChallengeStatus {
  active('نشط'),
  completed('مكتمل'),
  failed('فشل'),
  expired('منتهي');
  
  final String title;
  const ChallengeStatus(this.title);
}

/// قالب التحدي
class ChallengeTemplate {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeCategory category;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> requirements;
  final int rewardPoints;
  final ChallengeDifficulty difficulty;
  
  ChallengeTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.icon,
    required this.color,
    required this.requirements,
    required this.rewardPoints,
    required this.difficulty,
  });
}

/// التحدي النشط
class Challenge {
  final String id;
  final String templateId;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeCategory category;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> requirements;
  Map<String, dynamic> currentProgress;
  final int rewardPoints;
  final ChallengeDifficulty difficulty;
  ChallengeStatus status;
  final DateTime startTime;
  final DateTime endTime;
  DateTime? completedAt;
  
  Challenge({
    required this.id,
    required this.templateId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.icon,
    required this.color,
    required this.requirements,
    required this.currentProgress,
    required this.rewardPoints,
    required this.difficulty,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.completedAt,
  });
  
  double get progress {
    if (status == ChallengeStatus.completed) return 1.0;
    
    final required = requirements['count'] ?? requirements['points'] ?? 1;
    final current = currentProgress['count'] ?? 
                   currentProgress['points'] ?? 
                   (currentProgress['completed'] == true ? 1 : 0);
    
    return (current / required).clamp(0.0, 1.0);
  }
  
  Duration get timeRemaining => endTime.difference(DateTime.now());
  
  bool get isExpired => DateTime.now().isAfter(endTime);
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.name,
      'requirements': requirements,
      'currentProgress': currentProgress,
      'rewardPoints': rewardPoints,
      'difficulty': difficulty.name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
  
  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      templateId: map['templateId'],
      title: map['title'],
      description: map['description'],
      type: ChallengeType.values.firstWhere((t) => t.name == map['type']),
      category: ChallengeCategory.values.firstWhere((c) => c.name == map['category']),
      icon: Icons.flag, // TODO: حفظ الأيقونة
      color: Colors.blue, // TODO: حفظ اللون
      requirements: Map<String, dynamic>.from(map['requirements']),
      currentProgress: Map<String, dynamic>.from(map['currentProgress'] ?? {}),
      rewardPoints: map['rewardPoints'],
      difficulty: ChallengeDifficulty.values.firstWhere((d) => d.name == map['difficulty']),
      status: ChallengeStatus.values.firstWhere((s) => s.name == map['status']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}

// ==================== ويدجت عرض التحديات ====================

class ChallengesWidget extends StatefulWidget {
  final bool showDaily;
  final bool showWeekly;
  final bool showSpecial;
  final Function(Challenge)? onChallengeComplete;
  
  const ChallengesWidget({
    super.key,
    this.showDaily = true,
    this.showWeekly = true,
    this.showSpecial = true,
    this.onChallengeComplete,
  });
  
  @override
  State<ChallengesWidget> createState() => _ChallengesWidgetState();
}

class _ChallengesWidgetState extends State<ChallengesWidget> {
  final _challengesSystem = ChallengesSystem();
  
  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  List<Challenge> _specialChallenges = [];
  
  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }
  
  void _loadChallenges() {
    setState(() {
      if (widget.showDaily) {
        _dailyChallenges = _challengesSystem.getTodaysChallenges();
      }
      if (widget.showWeekly) {
        _weeklyChallenges = _challengesSystem.getWeeklyChallenges();
      }
      if (widget.showSpecial) {
        _specialChallenges = _challengesSystem.getSpecialChallenges();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_dailyChallenges.isNotEmpty) ...[
          _buildSectionHeader('التحديات اليومية', Icons.today),
          ..._dailyChallenges.map((c) => _buildChallengeCard(c)),
          const SizedBox(height: 20),
        ],
        
        if (_weeklyChallenges.isNotEmpty) ...[
          _buildSectionHeader('التحديات الأسبوعية', Icons.date_range),
          ..._weeklyChallenges.map((c) => _buildChallengeCard(c)),
          const SizedBox(height: 20),
        ],
        
        if (_specialChallenges.isNotEmpty) ...[
          _buildSectionHeader('التحديات الخاصة', Icons.star),
          ..._specialChallenges.map((c) => _buildChallengeCard(c)),
        ],
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: ThemeConstants.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.titleMedium?.copyWith(
              fontWeight: ThemeConstants.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeCard(Challenge challenge) {
    final isCompleted = challenge.status == ChallengeStatus.completed;
    final isExpired = challenge.isExpired;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isCompleted || isExpired ? null : () => _showChallengeDetails(challenge),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? ThemeConstants.success.withValues(alpha: 0.1)
                  : isExpired
                      ? Colors.grey.withValues(alpha: 0.1)
                      : context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted 
                    ? ThemeConstants.success.withValues(alpha: 0.3)
                    : isExpired
                        ? Colors.grey.withValues(alpha: 0.3)
                        : context.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الرأس
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: challenge.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        challenge.icon,
                        color: challenge.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: context.titleSmall?.copyWith(
                              fontWeight: ThemeConstants.semiBold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            challenge.description,
                            style: context.bodySmall?.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // المكافأة
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeConstants.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: ThemeConstants.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.rewardPoints}',
                            style: context.labelMedium?.copyWith(
                              color: ThemeConstants.warning,
                              fontWeight: ThemeConstants.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // شريط التقدم
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقدم',
                          style: context.labelSmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        Text(
                          '${(challenge.progress * 100).toInt()}%',
                          style: context.labelSmall?.copyWith(
                            color: challenge.color,
                            fontWeight: ThemeConstants.semiBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: challenge.progress,
                      backgroundColor: challenge.color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? ThemeConstants.success : challenge.color,
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // المعلومات السفلية
                Row(
                  children: [
                    // الصعوبة
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: challenge.difficulty.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        challenge.difficulty.title,
                        style: context.labelSmall?.copyWith(
                          color: challenge.difficulty.color,
                          fontWeight: ThemeConstants.medium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // النوع
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        challenge.type.title,
                        style: context.labelSmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // الوقت المتبقي
                    if (!isCompleted && !isExpired)
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeRemaining(challenge.timeRemaining),
                            style: context.labelSmall?.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    if (isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: ThemeConstants.success,
                        size: 20,
                      ),
                    if (isExpired && !isCompleted)
                      const Icon(
                        Icons.cancel,
                        color: Colors.grey,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showChallengeDetails(Challenge challenge) {
    //
  }
  
  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقيقة';
    } else {
      return 'قريباً';
    }
  }
}