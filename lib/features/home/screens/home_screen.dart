// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../app/themes/app_theme.dart';
import '../widgets/category_grid.dart';
import 'package:athkar_app/features/home/daily_quotes/daily_quotes_card.dart';
import 'package:athkar_app/features/home/widgets/home_prayer_times_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with AutomaticKeepAliveClientMixin {
  
  // للحفاظ على الحالة
  @override
  bool get wantKeepAlive => true;
  
  // متغيرات للوقت والتاريخ
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // لا نفحص الأذونات هنا - سيتم من PermissionGateway
    
    // تحديث الوقت كل ثانية
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // دالة للحصول على رسالة الترحيب حسب الوقت
  Map<String, dynamic> _getMessage() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return {
        'greeting': 'صباح الخير',
        'icon': Icons.wb_sunny_outlined,
        'message': 'نسأل الله أن يجعل يومك مباركاً',
      };
    } else if (hour >= 12 && hour < 17) {
      return {
        'greeting': 'مساء النور',
        'icon': Icons.wb_twilight_outlined,
        'message': 'لا تنسَ أذكار المساء',
      };
    } else if (hour >= 17 && hour < 21) {
      return {
        'greeting': 'مساء الخير',
        'icon': Icons.nights_stay_outlined,
        'message': 'أسعد الله مساءك بكل خير',
      };
    } else {
      return {
        'greeting': 'أهلاً بك',
        'icon': Icons.nightlight_outlined,
        'message': 'لا تنسَ أذكار النوم',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            _buildCustomAppBar(context),
            
            // المحتوى الرئيسي
            Expanded(
              child: Stack(
                children: [
                  // خلفية ثابتة مبسطة
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: context.isDarkMode
                            ? [
                                ThemeConstants.darkBackground,
                                ThemeConstants.darkSurface.withValues(alpha: 0.8),
                                ThemeConstants.darkBackground,
                              ]
                            : [
                                ThemeConstants.lightBackground,
                                ThemeConstants.primarySoft.withValues(alpha: 0.1),
                                ThemeConstants.lightBackground,
                              ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                  
                  // المحتوى الرئيسي
                  RefreshIndicator(
                    onRefresh: _handlePullToRefresh,
                    color: context.primaryColor,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space4,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              ThemeConstants.space2.h,
                              
                              // بطاقة مواقيت الصلاة
                              const PrayerTimesCard(),
                              
                              ThemeConstants.space4.h,
                              
                              // بطاقة الاقتباسات
                              const DailyQuotesCard(),
                              
                              ThemeConstants.space6.h,
                              
                              // عنوان الأقسام
                              _buildSectionsHeader(context),
                              
                              ThemeConstants.space4.h,
                            ]),
                          ),
                        ),
                        
                        // شبكة الفئات
                        const CategoryGrid(),
                        
                        // مساحة في الأسفل
                        SliverToBoxAdapter(
                          child: ThemeConstants.space12.h,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final messageData = _getMessage();
    
    // تنسيق التاريخ والوقت
    final arabicFormatter = DateFormat('EEEE, d MMMM yyyy', 'ar');
    final timeFormatter = DateFormat('hh:mm a', 'ar');
    final dateString = arabicFormatter.format(_currentTime);
    final timeString = timeFormatter.format(_currentTime);
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // رسالة الترحيب على اليمين (البداية في RTL)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      messageData['icon'] as IconData,
                      color: context.primaryColor,
                      size: ThemeConstants.iconMd,
                    ),
                    ThemeConstants.space2.w,
                    Text(
                      messageData['greeting'] as String,
                      style: context.titleMedium?.copyWith(
                        fontWeight: ThemeConstants.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                ThemeConstants.space1.h,
                Padding(
                  padding: const EdgeInsets.only(right: ThemeConstants.space8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messageData['message'] as String,
                        style: context.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      ThemeConstants.space1.h,
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: context.textSecondaryColor.withValues(alpha: 0.7),
                          ),
                          ThemeConstants.space1.w,
                          Text(
                            dateString,
                            style: context.labelSmall?.copyWith(
                              color: context.textSecondaryColor.withValues(alpha: 0.8),
                            ),
                          ),
                          ThemeConstants.space3.w,
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: context.textSecondaryColor.withValues(alpha: 0.7),
                          ),
                          ThemeConstants.space1.w,
                          Text(
                            timeString,
                            style: context.labelSmall?.copyWith(
                              color: context.textSecondaryColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // زر الإعدادات على اليسار (النهاية في RTL)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/settings');
              },
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  border: Border.all(
                    color: context.dividerColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: context.textPrimaryColor,
                  size: ThemeConstants.iconMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.space4,
        vertical: ThemeConstants.space3,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              gradient: ThemeConstants.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ThemeConstants.space3.w,
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: Icon(
              Icons.apps_rounded,
              color: context.primaryColor,
              size: 20,
            ),
          ),
          ThemeConstants.space3.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأقسام الرئيسية',
                  style: context.titleMedium?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'اختر القسم المناسب لك',
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // معالج Pull to Refresh - بسيط
  Future<void> _handlePullToRefresh() async {
    HapticFeedback.mediumImpact();
    
    try {
      // تأخير قصير لإظهار التحديث
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      debugPrint('[HomeScreen] خطأ في التحديث: $e');
    }
  }
}