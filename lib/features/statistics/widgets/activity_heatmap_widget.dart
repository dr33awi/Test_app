// lib/features/statistics/widgets/activity_heatmap_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../app/themes/app_theme.dart';
import '../models/statistics_models.dart';
import '../services/statistics_service.dart';

/// خريطة حرارية للنشاط على مدار السنة (مثل GitHub)
class ActivityHeatMapWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<DateTime, int>? activityData;
  final Function(DateTime)? onDayTap;
  final bool showLabels;
  final bool showLegend;
  final bool isCompact;

  const ActivityHeatMapWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.activityData,
    this.onDayTap,
    this.showLabels = true,
    this.showLegend = true,
    this.isCompact = false,
  });

  @override
  State<ActivityHeatMapWidget> createState() => _ActivityHeatMapWidgetState();
}

class _ActivityHeatMapWidgetState extends State<ActivityHeatMapWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  late DateTime _startDate;
  late DateTime _endDate;
  Map<String, DayActivity> _processedData = {};
  
  // للتفاعل
  String? _hoveredDay;
  
  // أيام الأسبوع
  final _weekDays = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
  final _weekDaysFull = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  
  // الأشهر
  final _months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                   'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeDates();
    _processActivityData();
  }
  
  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  
  void _initializeDates() {
    _endDate = widget.endDate ?? DateTime.now();
    _startDate = widget.startDate ?? _endDate.subtract(const Duration(days: 364));
    
    // تأكد من أن البداية يوم أحد
    while (_startDate.weekday != DateTime.sunday) {
      _startDate = _startDate.subtract(const Duration(days: 1));
    }
  }
  
  void _processActivityData() {
    _processedData.clear();
    
    // معالجة البيانات الواردة
    if (widget.activityData != null) {
      widget.activityData!.forEach((date, value) {
        final key = _dateKey(date);
        _processedData[key] = DayActivity(
          date: date,
          value: value,
          level: _getActivityLevel(value),
        );
      });
    }
    
    // ملء الأيام الفارغة
    DateTime currentDate = _startDate;
    while (currentDate.isBefore(_endDate) || _isSameDay(currentDate, _endDate)) {
      final key = _dateKey(currentDate);
      if (!_processedData.containsKey(key)) {
        _processedData[key] = DayActivity(
          date: currentDate,
          value: 0,
          level: 0,
        );
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(widget.isCompact ? 12 : 20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
          border: Border.all(
            color: context.dividerColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
            if (!widget.isCompact)
              _buildHeader(),
            
            // الخريطة الحرارية
            _buildHeatMap(),
            
            // المفتاح/Legend
            if (widget.showLegend)
              _buildLegend(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final totalDays = _processedData.length;
    final activeDays = _processedData.values.where((d) => d.value > 0).length;
    final totalActivity = _processedData.values.fold(0, (sum, d) => sum + d.value);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_view_month,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خريطة النشاط السنوية',
                  style: context.titleMedium?.copyWith(
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                Text(
                  '$totalActivity نشاط في $activeDays يوم من أصل $totalDays يوم',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // إحصائية سريعة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeConstants.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ThemeConstants.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: ThemeConstants.success,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_getCurrentStreak()} يوم',
                  style: context.labelMedium?.copyWith(
                    color: ThemeConstants.success,
                    fontWeight: ThemeConstants.semiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeatMap() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أسماء الأشهر
          if (widget.showLabels)
            _buildMonthLabels(),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيام الأسبوع
              if (widget.showLabels)
                _buildWeekDayLabels(),
              
              // الخريطة
              _buildGrid(),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthLabels() {
    final cellSize = widget.isCompact ? 12.0 : 16.0;
    final cellSpacing = widget.isCompact ? 2.0 : 3.0;
    
    return Container(
      margin: EdgeInsets.only(
        left: widget.showLabels ? (cellSize + 15) : 0,
        bottom: 4,
      ),
      height: 20,
      child: CustomPaint(
        painter: _MonthLabelsPainter(
          startDate: _startDate,
          endDate: _endDate,
          cellSize: cellSize,
          cellSpacing: cellSpacing,
          months: _months,
          textStyle: context.labelSmall?.copyWith(
            color: context.textSecondaryColor,
            fontSize: widget.isCompact ? 10 : 11,
          ),
        ),
      ),
    );
  }
  
  Widget _buildWeekDayLabels() {
    final cellSize = widget.isCompact ? 12.0 : 16.0;
    final cellSpacing = widget.isCompact ? 2.0 : 3.0;
    
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 24),
      child: Column(
        children: _weekDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          
          // عرض فقط الأيام الفردية في الوضع المضغوط
          if (widget.isCompact && index % 2 == 0) {
            return SizedBox(height: cellSize + cellSpacing);
          }
          
          return Container(
            height: cellSize + cellSpacing,
            alignment: Alignment.centerRight,
            child: Text(
              day,
              style: context.labelSmall?.copyWith(
                color: context.textSecondaryColor,
                fontSize: widget.isCompact ? 10 : 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildGrid() {
    final cellSize = widget.isCompact ? 12.0 : 16.0;
    final cellSpacing = widget.isCompact ? 2.0 : 3.0;
    
    // حساب عدد الأسابيع
    final totalDays = _endDate.difference(_startDate).inDays + 1;
    final weeksCount = (totalDays / 7).ceil();
    
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Row(
        children: List.generate(weeksCount, (weekIndex) {
          return Column(
            children: List.generate(7, (dayIndex) {
              final date = _startDate.add(Duration(days: weekIndex * 7 + dayIndex));
              
              // تخطي الأيام خارج النطاق
              if (date.isAfter(_endDate)) {
                return SizedBox(
                  width: cellSize + cellSpacing,
                  height: cellSize + cellSpacing,
                );
              }
              
              return _buildDayCell(date, cellSize, cellSpacing);
            }),
          );
        }),
      ),
    );
  }
  
  Widget _buildDayCell(DateTime date, double size, double spacing) {
    final key = _dateKey(date);
    final activity = _processedData[key];
    
    if (activity == null) {
      return SizedBox(
        width: size + spacing,
        height: size + spacing,
      );
    }
    
    final isToday = _isSameDay(date, DateTime.now());
    final isHovered = _hoveredDay == key;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredDay = key),
      onExit: (_) => setState(() => _hoveredDay = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onDayTap?.call(date);
          _showDayDetails(activity);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size + spacing,
          height: size + spacing,
          padding: EdgeInsets.all(spacing / 2),
          child: Container(
            decoration: BoxDecoration(
              color: _getActivityColor(activity.level),
              borderRadius: BorderRadius.circular(widget.isCompact ? 2 : 3),
              border: Border.all(
                color: isToday 
                    ? ThemeConstants.primary 
                    : isHovered 
                        ? context.textPrimaryColor.withValues(alpha: 0.3)
                        : Colors.transparent,
                width: isToday ? 2 : 1,
              ),
              boxShadow: isHovered ? [
                BoxShadow(
                  color: _getActivityColor(activity.level).withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'أقل',
            style: context.labelSmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(5, (level) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: widget.isCompact ? 12 : 16,
              height: widget.isCompact ? 12 : 16,
              decoration: BoxDecoration(
                color: _getActivityColor(level),
                borderRadius: BorderRadius.circular(widget.isCompact ? 2 : 3),
              ),
            );
          }),
          const SizedBox(width: 8),
          Text(
            'أكثر',
            style: context.labelSmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDayDetails(DayActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor(activity.level).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today,
                color: _getActivityColor(activity.level),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDate(activity.date),
              style: context.titleMedium,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('إجمالي النشاط', '${activity.value}', Icons.trending_up),
            const Divider(),
            _buildDetailRow('المستوى', _getLevelText(activity.level), Icons.stars),
            const Divider(),
            _buildDetailRow('اليوم', _weekDaysFull[activity.date.weekday % 7], Icons.today),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.textSecondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: context.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ),
          Text(
            value,
            style: context.bodyMedium?.copyWith(
              fontWeight: ThemeConstants.semiBold,
            ),
          ),
        ],
      ),
    );
  }
  
  // ==================== Helper Methods ====================
  
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  int _getActivityLevel(int value) {
    if (value == 0) return 0;
    if (value <= 5) return 1;
    if (value <= 10) return 2;
    if (value <= 20) return 3;
    return 4;
  }
  
  Color _getActivityColor(int level) {
    final isDark = context.isDarkMode;
    
    switch (level) {
      case 0:
        return isDark 
            ? Colors.grey[800]!.withValues(alpha: 0.3)
            : Colors.grey[200]!;
      case 1:
        return ThemeConstants.success.withValues(alpha: 0.3);
      case 2:
        return ThemeConstants.success.withValues(alpha: 0.5);
      case 3:
        return ThemeConstants.success.withValues(alpha: 0.7);
      case 4:
        return ThemeConstants.success;
      default:
        return Colors.transparent;
    }
  }
  
  String _getLevelText(int level) {
    switch (level) {
      case 0: return 'لا يوجد نشاط';
      case 1: return 'نشاط خفيف';
      case 2: return 'نشاط متوسط';
      case 3: return 'نشاط جيد';
      case 4: return 'نشاط ممتاز';
      default: return '';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
  
  int _getCurrentStreak() {
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    while (true) {
      final key = _dateKey(currentDate);
      if ((_processedData[key]?.value ?? 0) > 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
}

// نموذج بيانات اليوم
class DayActivity {
  final DateTime date;
  final int value;
  final int level;
  
  DayActivity({
    required this.date,
    required this.value,
    required this.level,
  });
}

// رسام أسماء الأشهر
class _MonthLabelsPainter extends CustomPainter {
  final DateTime startDate;
  final DateTime endDate;
  final double cellSize;
  final double cellSpacing;
  final List<String> months;
  final TextStyle? textStyle;
  
  _MonthLabelsPainter({
    required this.startDate,
    required this.endDate,
    required this.cellSize,
    required this.cellSpacing,
    required this.months,
    this.textStyle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    DateTime currentDate = startDate;
    int currentMonth = -1;
    double xOffset = 0;
    
    while (currentDate.isBefore(endDate) || currentDate.day == endDate.day) {
      if (currentDate.month != currentMonth) {
        currentMonth = currentDate.month;
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: months[currentMonth - 1],
            style: textStyle,
          ),
          textDirection: TextDirection.rtl,
        );
        
        textPainter.layout();
        textPainter.paint(canvas, Offset(xOffset, 0));
      }
      
      xOffset += (cellSize + cellSpacing) / 7;
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}