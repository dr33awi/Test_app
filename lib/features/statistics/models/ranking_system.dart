// lib/features/statistics/models/ranking_system.dart (مُصحح)

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';

/// نظام الرتب والمستويات
class RankingSystem {
  static final RankingSystem _instance = RankingSystem._internal();
  factory RankingSystem() => _instance;
  RankingSystem._internal();

  final StorageService _storage = getIt<StorageService>();
  final _random = math.Random();
  
  // ==================== تعريف الرتب ====================
  
  final List<UserRank> ranks = [
    UserRank(
      id: 'beginner',
      title: 'مبتدئ',
      subtitle: 'بداية الرحلة',
      minPoints: 0,
      maxPoints: 99,
      level: 1,
      icon: Icons.star_outline,
      color: Colors.grey,
      gradient: [Colors.grey[400]!, Colors.grey[600]!],
      benefits: [
        'فتح الأذكار الأساسية',
        'تتبع الإحصائيات اليومية',
      ],
    ),
    
    UserRank(
      id: 'committed',
      title: 'ملتزم',
      subtitle: 'على الطريق الصحيح',
      minPoints: 100,
      maxPoints: 299,
      level: 2,
      icon: Icons.star_half,
      color: Colors.blue,
      gradient: [Colors.blue[300]!, Colors.blue[600]!],
      benefits: [
        'فتح جميع الأذكار',
        'تخصيص الأهداف',
        'المقارنة مع الأصدقاء',
      ],
    ),
    
    UserRank(
      id: 'persistent',
      title: 'مثابر',
      subtitle: 'الثبات على الخير',
      minPoints: 300,
      maxPoints: 699,
      level: 3,
      icon: Icons.star,
      color: Colors.green,
      gradient: [Colors.green[300]!, Colors.green[600]!],
      benefits: [
        'تحديات خاصة',
        'شارات مميزة',
        'تصدير الإحصائيات',
      ],
    ),
    
    UserRank(
      id: 'devoted',
      title: 'مخلص',
      subtitle: 'الإخلاص في العبادة',
      minPoints: 700,
      maxPoints: 1499,
      level: 4,
      icon: Icons.workspace_premium,
      color: Colors.purple,
      gradient: [Colors.purple[300]!, Colors.purple[600]!],
      benefits: [
        'إنشاء مجموعات',
        'قيادة التحديات',
        'ثيمات خاصة',
      ],
    ),
    
    UserRank(
      id: 'expert',
      title: 'خبير',
      subtitle: 'قدوة للآخرين',
      minPoints: 1500,
      maxPoints: 2999,
      level: 5,
      icon: Icons.military_tech,
      color: Colors.orange,
      gradient: [Colors.orange[300]!, Colors.orange[600]!],
      benefits: [
        'إرشاد المبتدئين',
        'وضع تحديات مخصصة',
        'شارة الخبير الذهبية',
      ],
    ),
    
    UserRank(
      id: 'master',
      title: 'محترف',
      subtitle: 'مستوى الاحتراف',
      minPoints: 3000,
      maxPoints: 4999,
      level: 6,
      icon: Icons.emoji_events,
      color: Colors.amber,
      gradient: [Colors.amber[300]!, Colors.amber[700]!],
      benefits: [
        'لقب المحترف',
        'أولوية في الميزات الجديدة',
        'دعم مخصص',
      ],
    ),
    
    UserRank(
      id: 'legend',
      title: 'أسطورة',
      subtitle: 'قمة التميز',
      minPoints: 5000,
      maxPoints: 9999,
      level: 7,
      icon: Icons.diamond,
      color: Colors.cyan,
      gradient: [Colors.cyan[300]!, Colors.cyan[700]!],
      benefits: [
        'لقب الأسطورة الدائم',
        'تخصيص كامل',
        'إطار مميز للصورة',
      ],
    ),
    
    UserRank(
      id: 'immortal',
      title: 'خالد',
      subtitle: 'لا يُضاهى',
      minPoints: 10000,
      maxPoints: 999999,
      level: 8,
      icon: Icons.auto_awesome,
      color: ThemeConstants.primary,
      gradient: [
        Colors.purple[400]!,
        Colors.blue[400]!,
        Colors.cyan[400]!,
        Colors.amber[400]!,
      ],
      benefits: [
        'جميع المميزات',
        'لقب خاص متحرك',
        'قاعة الشرف الدائمة',
      ],
      isSpecial: true,
    ),
  ];

  // ==================== الشارات الخاصة ====================
  
  final List<SpecialBadge> specialBadges = [
    SpecialBadge(
      id: 'first_week',
      title: 'الأسبوع الأول',
      description: 'أكمل أسبوعك الأول',
      icon: Icons.looks_one,
      color: Colors.blue,
      requiredCondition: (stats) {
        // تحقق من نوع البيانات قبل الوصول إلى الخصائص
        if (stats is Map<String, dynamic>) {
          final totalDays = stats['totalDays'] as int? ?? 0;
          return totalDays >= 7;
        }
        return false;
      },
    ),
    
    SpecialBadge(
      id: 'month_warrior',
      title: 'محارب الشهر',
      description: 'حافظ على نشاط يومي لمدة شهر',
      icon: Icons.calendar_month,
      color: Colors.green,
      requiredCondition: (stats) {
        if (stats is Map<String, dynamic>) {
          final currentStreak = stats['currentStreak'] as int? ?? 0;
          return currentStreak >= 30;
        }
        return false;
      },
    ),
    
    SpecialBadge(
      id: 'century',
      title: 'المئوية',
      description: 'سلسلة 100 يوم متواصل',
      icon: Icons.looks_one_outlined,
      color: Colors.amber,
      requiredCondition: (stats) {
        if (stats is Map<String, dynamic>) {
          final longestStreak = stats['longestStreak'] as int? ?? 0;
          return longestStreak >= 100;
        }
        return false;
      },
    ),
    
    SpecialBadge(
      id: 'early_bird',
      title: 'الطائر المبكر',
      description: 'أكمل الأذكار قبل الساعة 7 صباحاً 30 مرة',
      icon: Icons.wb_twilight,
      color: Colors.orange,
      requiredCondition: (stats) => false, // تحتاج لمنطق خاص
    ),
    
    SpecialBadge(
      id: 'night_owl',
      title: 'بومة الليل',
      description: 'أكمل أذكار المساء بعد العشاء 30 مرة',
      icon: Icons.nights_stay,
      color: Colors.indigo,
      requiredCondition: (stats) => false, // تحتاج لمنطق خاص
    ),
    
    SpecialBadge(
      id: 'perfectionist',
      title: 'الكمال',
      description: 'أكمل جميع الأذكار في يوم واحد 10 مرات',
      icon: Icons.verified,
      color: Colors.teal,
      requiredCondition: (stats) => false, // تحتاج لمنطق خاص
    ),
  ];

  // ==================== الوظائف ====================
  
  /// الحصول على الرتبة الحالية بناءً على النقاط
  UserRank getCurrentRank(int points) {
    return ranks.firstWhere(
      (rank) => points >= rank.minPoints && points <= rank.maxPoints,
      orElse: () => ranks.first,
    );
  }
  
  /// الحصول على الرتبة التالية
  UserRank? getNextRank(int points) {
    final currentRank = getCurrentRank(points);
    final currentIndex = ranks.indexOf(currentRank);
    
    if (currentIndex < ranks.length - 1) {
      return ranks[currentIndex + 1];
    }
    return null;
  }
  
  /// حساب التقدم للرتبة التالية
  double getProgressToNextRank(int points) {
    final currentRank = getCurrentRank(points);
    final pointsInCurrentRank = points - currentRank.minPoints;
    final totalPointsNeeded = currentRank.maxPoints - currentRank.minPoints + 1;
    
    return (pointsInCurrentRank / totalPointsNeeded).clamp(0.0, 1.0);
  }
  
  /// الحصول على النقاط المتبقية للرتبة التالية
  int getPointsToNextRank(int points) {
    final nextRank = getNextRank(points);
    if (nextRank == null) return 0;
    
    return nextRank.minPoints - points;
  }
  
  /// التحقق من الشارات المفتوحة
  List<SpecialBadge> getUnlockedBadges(dynamic stats) {
    // تحقق من أن stats هو Map قبل تمريره للشارات
    if (stats is! Map<String, dynamic>) {
      return [];
    }
    
    return specialBadges.where((badge) {
      try {
        return badge.requiredCondition(stats);
      } catch (e) {
        // في حالة حدوث خطأ، أرجع false
        return false;
      }
    }).toList();
  }
}

// ==================== النماذج ====================

/// نموذج الرتبة
class UserRank {
  final String id;
  final String title;
  final String subtitle;
  final int minPoints;
  final int maxPoints;
  final int level;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final List<String> benefits;
  final bool isSpecial;
  
  UserRank({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minPoints,
    required this.maxPoints,
    required this.level,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.benefits,
    this.isSpecial = false,
  });
}

/// نموذج الشارة الخاصة
class SpecialBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(dynamic stats) requiredCondition;
  DateTime? unlockedAt;
  
  SpecialBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredCondition,
    this.unlockedAt,
  });
  
  bool get isUnlocked => unlockedAt != null;
}

// ==================== ويدجت عرض الرتبة ====================

class RankDisplayWidget extends StatefulWidget {
  final int currentPoints;
  final bool showProgress;
  final bool isCompact;
  final VoidCallback? onTap;
  
  const RankDisplayWidget({
    super.key,
    required this.currentPoints,
    this.showProgress = true,
    this.isCompact = false,
    this.onTap,
  });
  
  @override
  State<RankDisplayWidget> createState() => _RankDisplayWidgetState();
}

class _RankDisplayWidgetState extends State<RankDisplayWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  final _rankingSystem = RankingSystem();
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // تكرار الأنيميشن للرتب الخاصة
    final currentRank = _rankingSystem.getCurrentRank(widget.currentPoints);
    if (currentRank.isSpecial) {
      _animationController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentRank = _rankingSystem.getCurrentRank(widget.currentPoints);
    final nextRank = _rankingSystem.getNextRank(widget.currentPoints);
    final progress = _rankingSystem.getProgressToNextRank(widget.currentPoints);
    final pointsToNext = _rankingSystem.getPointsToNextRank(widget.currentPoints);
    
    if (widget.isCompact) {
      return _buildCompactView(currentRank, progress);
    }
    
    return GestureDetector(
      onTap: widget.onTap ?? () => _showRankDetails(currentRank, nextRank),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: currentRank.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: currentRank.color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // الرأس
            Row(
              children: [
                // الأيقونة المتحركة
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: currentRank.isSpecial ? _rotationAnimation.value : 0,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            currentRank.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                // معلومات الرتبة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRank.title,
                        style: context.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                      Text(
                        currentRank.subtitle,
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // المستوى
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المستوى',
                        style: context.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${currentRank.level}',
                        style: context.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (widget.showProgress && nextRank != null) ...[
              const SizedBox(height: 20),
              
              // شريط التقدم
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.currentPoints} نقطة',
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.semiBold,
                        ),
                      ),
                      Text(
                        'باقي $pointsToNext نقطة',
                        style: context.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 8,
                        width: MediaQuery.of(context).size.width * progress,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'الرتبة التالية: ${nextRank.title}',
                    style: context.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompactView(UserRank rank, double progress) {
    return GestureDetector(
      onTap: widget.onTap ?? () => _showRankDetails(rank, null),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: rank.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              rank.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              rank.title,
              style: context.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.semiBold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Lv.${rank.level}',
                style: context.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: ThemeConstants.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showRankDetails(UserRank currentRank, UserRank? nextRank) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // المحتوى
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // الرتبة الحالية
                    _buildRankCard(currentRank, true),
                    
                    if (nextRank != null) ...[
                      const SizedBox(height: 20),
                      
                      // سهم التقدم
                      Icon(
                        Icons.arrow_downward,
                        color: context.textSecondaryColor,
                        size: 32,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // الرتبة التالية
                      _buildRankCard(nextRank, false),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // جميع الرتب
                    Text(
                      'جميع الرتب',
                      style: context.titleLarge?.copyWith(
                        fontWeight: ThemeConstants.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ..._rankingSystem.ranks.map((rank) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRankListItem(rank),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRankCard(UserRank rank, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: rank.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: isCurrent ? Border.all(
          color: Colors.white,
          width: 2,
        ) : null,
      ),
      child: Column(
        children: [
          Icon(
            rank.icon,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            rank.title,
            style: context.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          Text(
            rank.subtitle,
            style: context.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المميزات:',
                  style: context.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                ...rank.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: context.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRankListItem(UserRank rank) {
    final isCurrent = rank == _rankingSystem.getCurrentRank(widget.currentPoints);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? rank.color.withValues(alpha: 0.1) : context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? rank.color : context.dividerColor.withValues(alpha: 0.3),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: rank.gradient),
              shape: BoxShape.circle,
            ),
            child: Icon(
              rank.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.title,
                  style: context.titleSmall?.copyWith(
                    fontWeight: ThemeConstants.semiBold,
                    color: isCurrent ? rank.color : null,
                  ),
                ),
                Text(
                  '${rank.minPoints} - ${rank.maxPoints} نقطة',
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rank.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv.${rank.level}',
              style: context.labelMedium?.copyWith(
                color: rank.color,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}