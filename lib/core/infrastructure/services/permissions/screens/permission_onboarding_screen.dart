// lib/core/infrastructure/services/permissions/screens/permission_onboarding_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../permission_service.dart';
import '../permission_constants.dart';
import '../widgets/permission_dialogs.dart';

/// نتيجة شاشة Onboarding
class OnboardingResult {
  final bool skipped;
  final List<AppPermissionType> selectedPermissions;

  OnboardingResult({
    required this.skipped,
    required this.selectedPermissions,
  });
}

/// شاشة Onboarding المحدثة للتطبيق
class PermissionOnboardingScreen extends StatefulWidget {
  final PermissionService permissionService;
  final List<AppPermissionType>? criticalPermissions;
  final List<AppPermissionType>? optionalPermissions;
  final Function(OnboardingResult)? onComplete;

  const PermissionOnboardingScreen({
    super.key,
    required this.permissionService,
    this.criticalPermissions,
    this.optionalPermissions,
    this.onComplete,
  });

  @override
  State<PermissionOnboardingScreen> createState() =>
      _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState extends State<PermissionOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  int _currentPage = 0;
  final int _totalPages = 6; // زيادة عدد الصفحات

  // الأذونات المختارة
  final Set<AppPermissionType> _selectedPermissions = {};

  // حالة معالجة الأذونات
  bool _isProcessingPermissions = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // إضافة الأذونات الحرجة تلقائياً
    final criticalPermissions =
        widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    _selectedPermissions.addAll(criticalPermissions);

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // في الصفحة الأخيرة - معالجة الأذونات
      _processPermissionsAndComplete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() {
    HapticFeedback.mediumImpact();
    _showSkipConfirmation();
  }

  void _showSkipConfirmation() {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber, color: scheme.tertiary),
            ),
            const SizedBox(width: 12),
            const Text('تخطي الإعداد؟'),
          ],
        ),
        content: const Text(
          'قد تفوتك الإشعارات التذكيرية للأذكار والصلوات.\n\nيمكنك تفعيل الأذونات لاحقاً من الإعدادات.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(context);
              _completeWithResult(OnboardingResult(
                skipped: true,
                selectedPermissions: const [],
              ));
            },
            child: const Text('تخطي'),
          ),
        ],
      ),
    );
  }

  /// معالجة الأذونات وإكمال Onboarding
  Future<void> _processPermissionsAndComplete() async {
    if (_isProcessingPermissions) return;

    setState(() {
      _isProcessingPermissions = true;
    });

    HapticFeedback.heavyImpact();

    // إذا لم يتم اختيار أي أذونات
    if (_selectedPermissions.isEmpty) {
      _completeWithResult(OnboardingResult(
        skipped: false,
        selectedPermissions: const [],
      ));
      return;
    }

    // عرض dialog التقدم
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _PermissionProcessingDialog(
          totalPermissions: _selectedPermissions.length,
        ),
      ),
    );

    try {
      // طلب الأذونات
      final results = await _requestPermissions();

      // إغلاق dialog التقدم
      if (mounted) {
        Navigator.pop(context);
      }

      // عرض النتائج
      if (mounted) {
        await _showResults(results);
      }

      // إكمال العملية
      _completeWithResult(OnboardingResult(
        skipped: false,
        selectedPermissions: _selectedPermissions.toList(),
      ));
    } catch (e) {
      debugPrint('Error processing permissions: $e');

      // إغلاق dialog في حالة الخطأ
      if (mounted) {
        Navigator.pop(context);
        _showErrorMessage('حدث خطأ في معالجة الأذونات');
      }

      setState(() {
        _isProcessingPermissions = false;
      });
    }
  }

  /// طلب الأذونات بشكل متسلسل
  Future<Map<AppPermissionType, AppPermissionStatus>> _requestPermissions() async {
    final results = <AppPermissionType, AppPermissionStatus>{};
    final permissions = _selectedPermissions.toList();

    for (int i = 0; i < permissions.length; i++) {
      final permission = permissions[i];

      // تحديث dialog التقدم
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: _PermissionProcessingDialog(
              totalPermissions: permissions.length,
              currentIndex: i + 1,
              currentPermission: permission,
            ),
          ),
        );
      }

      // طلب الإذن
      try {
        final status =
            await widget.permissionService.requestPermission(permission);
        results[permission] = status;
        debugPrint('Permission ${permission.toString()}: ${status.toString()}');
      } catch (e) {
        debugPrint('Error requesting permission $permission: $e');
        results[permission] = AppPermissionStatus.unknown;
      }

      // تأخير صغير بين الطلبات
      if (i < permissions.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    return results;
  }

  /// عرض نتائج طلب الأذونات
  Future<void> _showResults(
      Map<AppPermissionType, AppPermissionStatus> results) async {
    final granted = results.entries
        .where((e) => e.value == AppPermissionStatus.granted)
        .map((e) => e.key)
        .toList();

    final denied = results.entries
        .where((e) => e.value != AppPermissionStatus.granted)
        .map((e) => e.key)
        .toList();

    if (mounted) {
      await PermissionDialogs.showResultDialog(
        context: context,
        granted: granted,
        denied: denied,
      );
    }
  }

  /// إكمال العملية وإرجاع النتيجة
  void _completeWithResult(OnboardingResult result) {
    if (widget.onComplete != null) {
      widget.onComplete!(result);
    } else {
      Navigator.pop(context, result);
    }
  }

  void _showErrorMessage(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: scheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          // خلفية هادئة بتدرج خفيف يعتمد على ColorScheme
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      scheme.surface,
                      scheme.surfaceVariant.withOpacity(0.7),
                      scheme.surface,
                    ]
                  : [
                      scheme.surface,
                      scheme.surfaceVariant.withOpacity(0.4),
                      scheme.surface,
                  ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    // Header مع Progress (نسخة جديدة)
                    _buildHeaderNew(context),

                    // Pages
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                              HapticFeedback.selectionClick();
                            },
                            children: [
                              _buildWelcomePageNew(context),
                              _buildAboutAppPage(),
                              _buildNonProfitPage(),
                              _buildSadaqahPage(),
                              _buildPermissionSelectionPage(),
                              _buildCompletionPage(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Navigation (نسخة جديدة زجاجية)
                    _buildNavigationNew(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //==================== الهيدر الحديث ====================

  Widget _buildHeaderNew(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // عنوان صغير متغير حسب الصفحة
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              switch (_currentPage) {
                0 => 'مرحبًا بك',
                1 => 'عن التطبيق',
                2 => 'قيمنا',
                3 => 'الصدقة الجارية',
                4 => 'الأذونات المطلوبة',
                5 => 'جاهزون للانطلاق',
                _ => '',
              },
              key: ValueKey(_currentPage),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withOpacity(0.9),
                  ),
            ),
          ),
          const SizedBox(height: 12),

          // مؤشر خطوات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final isActive = index == _currentPage;
              final isPassed = index < _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 28 : 10,
                decoration: BoxDecoration(
                  color: isActive || isPassed
                      ? scheme.primary
                      : scheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  //==================== صفحة الترحيب الحديثة ====================

  Widget _buildWelcomePageNew(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // دائرة متوهجة/عائمة + أيقونة
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scheme.primary.withOpacity(0.35),
                        scheme.primary.withOpacity(0.15),
                      ],
                      stops: const [0.4, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Container(
                    width: 140,
                    height: 140,
                    alignment: Alignment.center,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary,
                      ),
                      child: const Icon(Icons.mosque, size: 64, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 36),

          Text(
            'بسم الله الرحمن الرحيم',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'حصن المسلم',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          // شارة وصفية
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.primary.withOpacity(0.25)),
            ),
            child: Text(
              'رفيقك في الذكر والدعاء',
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // آية ضمن بطاقة زجاجية
          _GlassCard(
            child: Column(
              children: [
                Text(
                  '﴿ وَاذْكُرُوا اللَّهَ كَثِيرًا لَّعَلَّكُمْ تُفْلِحُونَ ﴾',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.7,
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'سورة الأنفال - آية 45',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.65),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //==================== بقية الصفحات (كما كانت مع تعديلات ألوان بسيطة) ====================

  Widget _buildAboutAppPage() {
    final scheme = Theme.of(context).colorScheme;

    final features = [
      {
        'icon': Icons.schedule,
        'title': 'مواقيت الصلاة',
        'description': 'تنبيهات دقيقة حسب موقعك الجغرافي',
        'color': scheme.primary,
      },
      {
        'icon': Icons.menu_book,
        'title': 'الأذكار اليومية',
        'description': 'أذكار الصباح والمساء وأذكار النوم',
        'color': scheme.secondary,
      },
      {
        'icon': Icons.explore,
        'title': 'اتجاه القبلة',
        'description': 'بوصلة دقيقة لتحديد القبلة',
        'color': Colors.orange,
      },
      {
        'icon': Icons.favorite,
        'title': 'الأذكار المفضلة',
        'description': 'احفظ أذكارك المفضلة للوصول السريع',
        'color': Colors.red,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // أيقونة التطبيق
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.star,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'عن التطبيق',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
          ),

          const SizedBox(height: 16),

          Text(
            'تطبيق "حصن المسلم" هو رفيقك الدائم في رحلة الذكر والعبادة. صُمم ليكون معينك على أداء العبادات في أوقاتها وتذكيرك بالأذكار النبوية الشريفة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 32),

          // الميزات
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFeatureCard(
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  description: feature['description'] as String,
                  color: feature['color'] as Color,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNonProfitPage() {
    final green = const Color(0xFF4CAF50);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة القلب
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF8BC34A),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.volunteer_activism,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'تطبيق غير ربحي',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: green,
                ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  green.withOpacity(0.1),
                  green.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: green.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: green, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'مجاني بالكامل - بدون إعلانات',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: green, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'لا نجمع أي بيانات شخصية',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: green, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'مفتوح المصدر للجميع',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'هدفنا نشر الخير والأجر، وتسهيل العبادة على إخواننا المسلمين في كل مكان.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'جعله الله في ميزان حسنات جميع من ساهم في هذا المشروع',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSadaqahPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // أيقونة الصدقة
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFB74D),
                  Color(0xFFFFA726),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.handshake,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'الصدقة الجارية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '"إذا مات الإنسان انقطع عمله إلا من ثلاثة: إلا من صدقة جارية، أو علم ينتفع به، أو ولد صالح يدعو له"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'رواه مسلم',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'كن سبباً في نشر هذا التطبيق',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          Text(
            'شاركه مع أهلك وأصدقائك، ولك أجر كل من استفاد منه إن شاء الله.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 24),

          // طرق المساهمة
          _buildContributionCard(
            icon: Icons.share,
            title: 'شارك التطبيق',
            description: 'انشر التطبيق بين الأهل والأصدقاء',
            color: Colors.blue,
          ),

          const SizedBox(height: 16),

          _buildContributionCard(
            icon: Icons.star,
            title: 'قيّم التطبيق',
            description: 'تقييمك يساعد في وصول التطبيق لعدد أكبر',
            color: Colors.amber,
          ),

          const SizedBox(height: 16),

          _buildContributionCard(
            icon: Icons.favorite,
            title: 'ادع لنا',
            description: 'دعواتكم خير دعم لنا للاستمرار',
            color: Colors.red,
          ),

          const SizedBox(height: 24),

          _GlassCard(
            child: Text(
              'جعل الله هذا العمل في ميزان حسناتكم وحسناتنا جميعاً',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSelectionPage() {
    final scheme = Theme.of(context).colorScheme;
    final criticalPermissions =
        widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    final optionalPermissions =
        widget.optionalPermissions ?? PermissionConstants.optionalPermissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الأذونات
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.security,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'الأذونات المطلوبة',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'نحتاج بعض الأذونات لتوفير أفضل تجربة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'أذونات أساسية',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 12),
          ...criticalPermissions.map(
            (permission) => _buildPermissionItem(permission, isCritical: true),
          ),

          if (optionalPermissions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'أذونات اختيارية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 12),
            ...optionalPermissions.map(
              (permission) => _buildPermissionItem(permission, isCritical: false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionPage() {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة الإكمال
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF8BC34A),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Text(
            'أهلاً وسهلاً بك!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),

          const SizedBox(height: 16),

          Text(
            'بارك الله فيك، أصبح كل شيء جاهزاً الآن',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 32),

          _GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: scheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'نصيحة',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك تخصيص إعدادات التذكيرات والإشعارات من قائمة الإعدادات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'جعل الله هذا التطبيق بركة ونفعاً لك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  //==================== بطاقات ثانوية ====================

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(AppPermissionType permission,
      {required bool isCritical}) {
    final scheme = Theme.of(context).colorScheme;
    final info = PermissionConstants.getInfo(permission);
    final isSelected = _selectedPermissions.contains(permission);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isCritical
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedPermissions.remove(permission);
                  } else {
                    _selectedPermissions.add(permission);
                  }
                });
                HapticFeedback.selectionClick();
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? info.color.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? info.color.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? info.color.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  info.icon,
                  color: isSelected ? info.color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          info.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? null : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مطلوب',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCritical)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedPermissions.add(permission);
                      } else {
                        _selectedPermissions.remove(permission);
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                  activeColor: info.color,
                ),
              if (isCritical)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.secondary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: scheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  //==================== شريط التنقل السفلي (زجاجي + M3) ====================

  Widget _buildNavigationNew(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: _GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessingPermissions ? null : _previousPage,
                  icon:
                      const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  label: const Text('السابق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _isProcessingPermissions ? null : _nextPage,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: _currentPage == _totalPages - 1
                      ? scheme.tertiary
                      : scheme.primary,
                ),
                child: _isProcessingPermissions
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getButtonText(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_currentPage < _totalPages - 1) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16),
                          ],
                        ],
                      ),
              ),
            ),

            if (_currentPage < _totalPages - 2) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: _isProcessingPermissions ? null : _skip,
                child: Text(
                  'تخطي',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_currentPage) {
      case 0:
        return 'ابدأ معنا';
      case 1:
      case 2:
      case 3:
        return 'التالي';
      case 4:
        return 'تأكيد الأذونات';
      case 5:
        return 'ابدأ الاستخدام';
      default:
        return 'التالي';
    }
  }
}

/// Dialog لعرض التقدم أثناء معالجة الأذونات
class _PermissionProcessingDialog extends StatelessWidget {
  final int totalPermissions;
  final int currentIndex;
  final AppPermissionType? currentPermission;

  const _PermissionProcessingDialog({
    required this.totalPermissions,
    this.currentIndex = 0,
    this.currentPermission,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = currentIndex > 0 ? currentIndex / totalPermissions : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'جاري طلب الأذونات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (currentIndex > 0) ...[
              Text(
                '$currentIndex من $totalPermissions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
              if (currentPermission != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    PermissionConstants.getName(currentPermission!),
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  minHeight: 8,
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              CircularProgressIndicator(color: scheme.primary),
            ],
          ],
        ),
      ),
    );
  }
}

//==================== ويدجت زجاجية عامة ====================

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: scheme.surface.withOpacity(0.65),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
