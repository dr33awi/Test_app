// lib/app/routes/app_router.dart - مُحدث مع إضافة مسار أسماء الله الحسنى
import 'package:athkar_app/features/asma_allah/screens/asma_allah_screen.dart';
import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';
import '../../features/home/screens/home_screen.dart';

// Prayer Times
import '../../features/prayer_times/screens/prayer_time_screen.dart';
import '../../features/prayer_times/screens/prayer_settings_screen.dart';
import '../../features/prayer_times/screens/prayer_notifications_settings_screen.dart';

// Qibla
import '../../features/qibla/screens/qibla_screen.dart';

// Athkar
import '../../features/athkar/screens/athkar_categories_screen.dart';
import '../../features/athkar/screens/athkar_details_screen.dart';
import '../../features/athkar/screens/notification_settings_screen.dart';

// Dua
import '../../features/dua/screens/dua_categories_screen.dart';

// Tasbih
import '../../features/tasbih/screens/tasbih_screen.dart';

// Settings
import '../../features/settings/screens/main_settings_screen.dart';

class AppRouter {
  // Main Routes
  static const String initialRoute = '/';
  static const String home = '/';
  
  // Feature Routes
  static const String prayerTimes = '/prayer-times';
  static const String athkar = '/athkar';
  static const String asmaAllah = '/asma-allah';  // إضافة مسار أسماء الله الحسنى
  static const String quran = '/quran';  // للتوافق المستقبلي
  static const String qibla = '/qibla';
  static const String tasbih = '/tasbih';
  static const String dua = '/dua';
  
  // Settings Routes
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String progress = '/progress';
  static const String achievements = '/achievements';
  
  // Detail Routes
  static const String athkarDetails = '/athkar-details';
  static const String quranReader = '/quran-reader';
  static const String duaDetails = '/dua-details';
  
  // Prayer Settings Routes
  static const String prayerSettings = '/prayer-settings';
  static const String prayerNotificationsSettings = '/prayer-notifications-settings';
  
  // Athkar Settings Routes
  static const String athkarNotificationsSettings = '/athkar-notifications-settings';

  // Navigator key for global navigation
  static final GlobalKey<NavigatorState> _navigatorKey = 
      GlobalKey<NavigatorState>();
  
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    debugPrint('AppRouter: Generating route for ${settings.name}');
    
    switch (settings.name) {
      // ==================== Main Screen ====================
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      
      // ==================== Main Features ====================
      case prayerTimes:
        return _slideRoute(const PrayerTimesScreen(), settings);
        
      case athkar:
        return _slideRoute(const AthkarCategoriesScreen(), settings);
        
      case athkarDetails:
        final categoryId = settings.arguments as String?;
        if (categoryId != null) {
          return _slideRoute(
            AthkarDetailsScreen(categoryId: categoryId), 
            settings
          );
        }
        return _slideRoute(
          _buildErrorScreen('معرف الفئة مطلوب'), 
          settings
        );
        
      // ==================== أسماء الله الحسنى ====================
      case asmaAllah:
        return _slideRoute(const AsmaAllahScreen(), settings);
        
        
      case qibla:
        return _slideRoute(const QiblaScreen(), settings);

      case tasbih:
        return _slideRoute(const TasbihScreen(), settings);
        
      case dua:
        return _slideRoute(const DuaCategoriesScreen(), settings);
        
      // ==================== Settings ====================
      case '/settings':
        return _slideRoute(const MainSettingsScreen(), settings);
        
      // ==================== Feature Routes ====================
      case favorites:
        return _slideRoute(_buildComingSoonScreen('المفضلة'), settings);
        
      case progress:
        return _slideRoute(_buildComingSoonScreen('التقدم اليومي'), settings);
        
      case achievements:
        return _slideRoute(_buildComingSoonScreen('الإنجازات'), settings);
        
      // ==================== Prayer Settings ====================
      case prayerSettings:
        return _slideRoute(const PrayerSettingsScreen(), settings);
        
      case prayerNotificationsSettings:
        return _slideRoute(const PrayerNotificationsSettingsScreen(), settings);
        
      // ==================== Athkar Settings ====================
      case athkarNotificationsSettings:
        return _slideRoute(const AthkarNotificationSettingsScreen(), settings);
        
      // ==================== Default ====================
      default:
        return _fadeRoute(_buildNotFoundScreen(settings.name), settings);
    }
  }

  // ==================== Route Builders ====================
  
  static Route<T> _fadeRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: ThemeConstants.durationNormal,
      reverseTransitionDuration: ThemeConstants.durationFast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> _slideRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: ThemeConstants.durationNormal,
      reverseTransitionDuration: ThemeConstants.durationFast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // ==================== Screen Builders ====================
  
  static Widget _buildComingSoonScreen(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: ThemeConstants.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ThemeConstants.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForFeature(title),
                size: 60,
                color: ThemeConstants.primary,
              ),
            ),
            const SizedBox(height: ThemeConstants.space5),
            const Text(
              'قريباً',
              style: TextStyle(
                fontSize: 28,
                color: ThemeConstants.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConstants.space2),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: ThemeConstants.space1),
            Text(
              'هذه الميزة قيد التطوير',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: ThemeConstants.space6),
            ElevatedButton.icon(
              onPressed: () {
                if (_navigatorKey.currentState?.canPop() ?? false) {
                  _navigatorKey.currentState!.pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.space4,
                  vertical: ThemeConstants.space3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildNotFoundScreen(String? routeName) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ThemeConstants.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: ThemeConstants.error,
              ),
            ),
            const SizedBox(height: ThemeConstants.space5),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                color: ThemeConstants.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConstants.space2),
            const Text(
              'الصفحة غير موجودة',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: ThemeConstants.space1),
            Text(
              'لم نتمكن من العثور على الصفحة المطلوبة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (routeName != null) ...[
              const SizedBox(height: ThemeConstants.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.space3,
                  vertical: ThemeConstants.space1,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                ),
                child: Text(
                  routeName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const SizedBox(height: ThemeConstants.space6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    if (_navigatorKey.currentState?.canPop() ?? false) {
                      _navigatorKey.currentState!.pop();
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeConstants.primary,
                    side: const BorderSide(color: ThemeConstants.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space4,
                      vertical: ThemeConstants.space3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConstants.space3),
                ElevatedButton.icon(
                  onPressed: () => _navigatorKey.currentState!
                      .pushNamedAndRemoveUntil(home, (route) => false),
                  icon: const Icon(Icons.home),
                  label: const Text('الرئيسية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.space4,
                      vertical: ThemeConstants.space3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
        backgroundColor: ThemeConstants.error,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ThemeConstants.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: ThemeConstants.error,
              ),
            ),
            const SizedBox(height: ThemeConstants.space4),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: ThemeConstants.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.space6),
            ElevatedButton.icon(
              onPressed: () {
                if (_navigatorKey.currentState?.canPop() ?? false) {
                  _navigatorKey.currentState!.pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.space4,
                  vertical: ThemeConstants.space3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _getIconForFeature(String title) {
    switch (title) {
      case 'مواقيت الصلاة':
        return Icons.mosque;
      case 'الأذكار':
        return Icons.menu_book;
      case 'أسماء الله الحسنى':  // إضافة أيقونة أسماء الله الحسنى
        return Icons.star_purple500_outlined;
      case 'القرآن الكريم':
        return Icons.book;
      case 'اتجاه القبلة':
        return Icons.explore;
      case 'التسبيح':
        return Icons.touch_app;
      case 'الأدعية':
        return Icons.pan_tool_rounded;
      case 'المفضلة':
        return Icons.bookmark;
      case 'الإعدادات':
        return Icons.settings;
      case 'التقدم اليومي':
        return Icons.trending_up;
      case 'الإنجازات':
        return Icons.emoji_events;
      default:
        return Icons.construction;
    }
  }

  // ==================== Navigation Helper Methods ====================
  
  static Future<T?> push<T>(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacement<T, TO>(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return _navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    return _navigatorKey.currentState!.pop<T>(result);
  }

  static bool canPop() {
    return _navigatorKey.currentState!.canPop();
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    return _navigatorKey.currentState!.popUntil(predicate);
  }
}