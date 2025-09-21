// lib/core/infrastructure/services/permissions/screens/permission_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
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

/// شاشة Onboarding الموحدة لطلب الأذونات
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
  State<PermissionOnboardingScreen> createState() => _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState extends State<PermissionOnboardingScreen>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4;
  
  // الأذونات المختارة
  final Set<AppPermissionType> _selectedPermissions = {};
  
  // حالة معالجة الأذونات
  bool _isProcessingPermissions = false;
  
  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: ThemeConstants.durationNormal,
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: ThemeConstants.durationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ThemeConstants.curveSmooth,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ThemeConstants.curveBounce,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ThemeConstants.curveDefault,
    ));
    
    // إضافة الأذونات الحرجة تلقائياً
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    _selectedPermissions.addAll(criticalPermissions);
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      _pageController.nextPage(
        duration: ThemeConstants.durationSlow,
        curve: ThemeConstants.curveSmooth,
      );
      _animationController.forward();
    } else {
      // في الصفحة الأخيرة - معالجة الأذونات
      _processPermissionsAndComplete();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      _pageController.previousPage(
        duration: ThemeConstants.durationSlow,
        curve: ThemeConstants.curveSmooth,
      );
      _animationController.forward();
    }
  }
  
  void _skip() {
    HapticFeedback.mediumImpact();
    _showSkipConfirmation();
  }
  
  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => _buildCustomDialog(
        icon: Icons.skip_next_rounded,
        iconColor: ThemeConstants.warning,
        title: 'تخطي إعداد الأذونات؟',
        content: 'قد لا تعمل بعض ميزات التطبيق بشكل صحيح بدون الأذونات المطلوبة.\n\nيمكنك تفعيلها لاحقاً من الإعدادات.',
        primaryAction: _DialogAction(
          text: 'تخطي',
          color: ThemeConstants.warning,
          onPressed: () {
            Navigator.pop(context);
            _completeWithResult(OnboardingResult(
              skipped: true,
              selectedPermissions: [],
            ));
          },
        ),
        secondaryAction: _DialogAction(
          text: 'إلغاء',
          onPressed: () => Navigator.pop(context),
        ),
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
        selectedPermissions: [],
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
        final status = await widget.permissionService.requestPermission(permission);
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
  Future<void> _showResults(Map<AppPermissionType, AppPermissionStatus> results) async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: ThemeConstants.iconSm),
            const SizedBox(width: ThemeConstants.space2),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeConstants.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        margin: const EdgeInsets.all(ThemeConstants.space4),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ThemeConstants.background(context),
        body: Stack(
          children: [
            // خلفية متدرجة ديناميكية
            _buildAnimatedBackground(),
            
            // المحتوى الرئيسي
            SafeArea(
              child: Column(
                children: [
                  // Header مع Progress المحسن
                  _buildEnhancedHeader(),
                  
                  // Pages مع Animations
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
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
                                  _progressController.animateTo(index / (_totalPages - 1));
                                },
                                children: [
                                  _buildWelcomePage(),
                                  _buildExplanationPage(),
                                  _buildPermissionSelectionPage(),
                                  _buildCompletionPage(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Navigation المحسن
                  _buildEnhancedNavigation(),
                ],
              ),
            ),
            
            // Loading overlay محسن
            if (_isProcessingPermissions)
              _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: ThemeConstants.getTimeBasedGradient(),
      ),
      child: AnimatedContainer(
        duration: ThemeConstants.durationSlow,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeConstants.background(context),
              ThemeConstants.surface(context).withValues(alpha: ThemeConstants.opacity90),
              ThemeConstants.background(context),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        children: [
          // عنوان الصفحة
          Text(
            'إعداد التطبيق',
            style: AppTextStyles.h4.copyWith(
              color: ThemeConstants.textPrimary(context),
              fontWeight: ThemeConstants.bold,
            ),
          ),
          const SizedBox(height: ThemeConstants.space4),
          
          // Progress Bar محسن
          Container(
            height: ThemeConstants.space2,
            margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.space8),
            decoration: BoxDecoration(
              color: ThemeConstants.divider(context),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ThemeConstants.divider(context),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (_currentPage + 1) / _totalPages,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: ThemeConstants.primaryGradient,
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity30),
                              blurRadius: ThemeConstants.space1,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space3),
          
          // Page indicators محسنة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final isActive = index == _currentPage;
              final isPassed = index < _currentPage;
              
              return AnimatedContainer(
                duration: ThemeConstants.durationNormal,
                margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.space1),
                height: ThemeConstants.space2,
                width: isActive ? ThemeConstants.space8 : ThemeConstants.space2,
                decoration: BoxDecoration(
                  color: isPassed 
                      ? ThemeConstants.success
                      : isActive 
                          ? ThemeConstants.primary 
                          : ThemeConstants.divider(context),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity30),
                      blurRadius: ThemeConstants.space1,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                child: isPassed ? const Center(
                  child: Icon(
                    Icons.check,
                    size: ThemeConstants.space2,
                    color: Colors.white,
                  ),
                ) : null,
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.space8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // شعار التطبيق المحسن
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: ThemeConstants.durationExtraSlow,
            curve: ThemeConstants.curveBounce,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: ThemeConstants.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: ThemeConstants.shadowLg,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // دائرة داخلية للتأثير
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: ThemeConstants.opacity20),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        ThemeConstants.iconPrayer,
                        size: ThemeConstants.icon3xl,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: ThemeConstants.space10),
          
          // عنوان الترحيب
          ShaderMask(
            shaderCallback: (bounds) => ThemeConstants.primaryGradient.createShader(bounds),
            child: Text(
              'مرحباً بك في\nحصن المسلم',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(
                fontWeight: ThemeConstants.bold,
                height: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space4),
          
          // وصف التطبيق
          Text(
            'رفيقك اليومي للأذكار والعبادات\nوالتقرب إلى الله سبحانه وتعالى',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: ThemeConstants.textSecondary(context),
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space8),
          
          // إحصائيات سريعة
          _buildWelcomeStats(),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeStats() {
    final stats = [
      {'icon': Icons.menu_book_rounded, 'label': 'أذكار', 'count': '100+'},
      {'icon': Icons.access_time_rounded, 'label': 'مواقيت', 'count': 'دقيقة'},
      {'icon': Icons.explore_rounded, 'label': 'قبلة', 'count': 'ذكية'},
    ];
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: ThemeConstants.card(context),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        boxShadow: ThemeConstants.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((stat) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space3),
              decoration: BoxDecoration(
                color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity10),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: Icon(
                stat['icon'] as IconData,
                color: ThemeConstants.primary,
                size: ThemeConstants.iconMd,
              ),
            ),
            const SizedBox(height: ThemeConstants.space2),
            Text(
              stat['count'] as String,
              style: AppTextStyles.label1.copyWith(
                color: ThemeConstants.primary,
                fontWeight: ThemeConstants.bold,
              ),
            ),
            Text(
              stat['label'] as String,
              style: AppTextStyles.caption.copyWith(
                color: ThemeConstants.textSecondary(context),
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
  
  Widget _buildExplanationPage() {
    final features = [
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'تذكيرات ذكية',
        'description': 'تنبيهات في الأوقات المناسبة للأذكار والصلوات',
        'color': ThemeConstants.info,
      },
      {
        'icon': Icons.location_on_rounded,
        'title': 'مواقيت دقيقة',
        'description': 'حساب دقيق لمواقيت الصلاة حسب موقعك الجغرافي',
        'color': ThemeConstants.success,
      },
      {
        'icon': Icons.explore_rounded,
        'title': 'اتجاه القبلة',
        'description': 'بوصلة دقيقة لتحديد اتجاه القبلة الصحيح',
        'color': ThemeConstants.warning,
      },
      {
        'icon': Icons.menu_book_rounded,
        'title': 'أذكار شاملة',
        'description': 'مجموعة كاملة من الأذكار اليومية مع الأدعية',
        'color': ThemeConstants.accent,
      },
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space8),
      child: Column(
        children: [
          Text(
            'ميزات التطبيق',
            style: AppTextStyles.h3.copyWith(
              fontWeight: ThemeConstants.bold,
              color: ThemeConstants.textPrimary(context),
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space2),
          
          Text(
            'تعرف على الميزات الرائعة التي ستساعدك في رحلتك الروحية',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(
              color: ThemeConstants.textSecondary(context),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space8),
          
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 600 + (index * 200)),
              curve: ThemeConstants.curveSmooth,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset((1 - value) * 100, 0),
                  child: Opacity(
                    opacity: value,
                    child: _buildEnhancedFeatureCard(
                      icon: feature['icon'] as IconData,
                      title: feature['title'] as String,
                      description: feature['description'] as String,
                      color: feature['color'] as Color,
                      index: index,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.space4),
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        color: ThemeConstants.card(context),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: ThemeConstants.opacity20),
          width: ThemeConstants.borderLight,
        ),
        boxShadow: ThemeConstants.shadowSm,
      ),
      child: Row(
        children: [
          // أيقونة محسنة
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: ThemeConstants.opacity20),
                  color.withValues(alpha: ThemeConstants.opacity10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: ThemeConstants.opacity20),
                  blurRadius: ThemeConstants.space2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: ThemeConstants.iconLg,
            ),
          ),
          
          const SizedBox(width: ThemeConstants.space4),
          
          // المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: ThemeConstants.semiBold,
                    color: ThemeConstants.textPrimary(context),
                  ),
                ),
                const SizedBox(height: ThemeConstants.space1),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: ThemeConstants.textSecondary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // رقم الترتيب
          Container(
            width: ThemeConstants.space8,
            height: ThemeConstants.space8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: ThemeConstants.opacity10),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: ThemeConstants.opacity30),
                width: ThemeConstants.borderLight,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: ThemeConstants.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionSelectionPage() {
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    final optionalPermissions = widget.optionalPermissions ?? PermissionConstants.optionalPermissions;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الصفحة
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.space4),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: ThemeConstants.icon2xl,
                    color: ThemeConstants.primary,
                  ),
                ),
                const SizedBox(height: ThemeConstants.space4),
                Text(
                  'الأذونات المطلوبة',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: ThemeConstants.textPrimary(context),
                  ),
                ),
                const SizedBox(height: ThemeConstants.space2),
                Text(
                  'نحتاج بعض الأذونات لتوفير أفضل تجربة ممكنة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body2.copyWith(
                    color: ThemeConstants.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space8),
          
          // الأذونات الأساسية
          _buildPermissionSection(
            title: 'أذونات أساسية',
            subtitle: 'مطلوبة لعمل التطبيق بشكل صحيح',
            icon: Icons.star_rounded,
            color: ThemeConstants.error,
            permissions: criticalPermissions,
            isCritical: true,
          ),
          
          if (optionalPermissions.isNotEmpty) ...[
            const SizedBox(height: ThemeConstants.space6),
            _buildPermissionSection(
              title: 'أذونات اختيارية',
              subtitle: 'لتحسين تجربة الاستخدام',
              icon: Icons.tune_rounded,
              color: ThemeConstants.info,
              permissions: optionalPermissions,
              isCritical: false,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPermissionSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<AppPermissionType> permissions,
    required bool isCritical,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: ThemeConstants.card(context),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: ThemeConstants.opacity20),
          width: ThemeConstants.borderLight,
        ),
        boxShadow: ThemeConstants.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: ThemeConstants.opacity10),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                ),
                child: Icon(icon, color: color, size: ThemeConstants.iconMd),
              ),
              const SizedBox(width: ThemeConstants.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h5.copyWith(
                        fontWeight: ThemeConstants.semiBold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: ThemeConstants.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.space4),
          
          // قائمة الأذونات
          ...permissions.map((permission) => 
            _buildEnhancedPermissionItem(permission, isCritical: isCritical),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnhancedPermissionItem(AppPermissionType permission, {required bool isCritical}) {
    final info = PermissionConstants.getInfo(permission);
    final isSelected = _selectedPermissions.contains(permission);
    
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.space3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCritical ? null : () {
            setState(() {
              if (isSelected) {
                _selectedPermissions.remove(permission);
              } else {
                _selectedPermissions.add(permission);
              }
            });
            HapticFeedback.selectionClick();
          },
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          child: AnimatedContainer(
            duration: ThemeConstants.durationFast,
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: isSelected 
                  ? info.color.withValues(alpha: ThemeConstants.opacity05)
                  : ThemeConstants.surface(context),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: isSelected 
                    ? info.color.withValues(alpha: ThemeConstants.opacity30)
                    : ThemeConstants.divider(context),
                width: isSelected ? ThemeConstants.borderThick : ThemeConstants.borderLight,
              ),
            ),
            child: Row(
              children: [
                // أيقونة الإذن
                AnimatedContainer(
                  duration: ThemeConstants.durationFast,
                  padding: const EdgeInsets.all(ThemeConstants.space3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? info.color.withValues(alpha: ThemeConstants.opacity5)
                        : ThemeConstants.divider(context).withValues(alpha: ThemeConstants.opacity10),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  child: Icon(
                    info.icon,
                    color: isSelected ? info.color : ThemeConstants.textSecondary(context),
                    size: ThemeConstants.iconMd,
                  ),
                ),
                
                const SizedBox(width: ThemeConstants.space4),
                
                // معلومات الإذن
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              info.name,
                              style: AppTextStyles.label1.copyWith(
                                fontWeight: ThemeConstants.semiBold,
                                color: isSelected 
                                    ? ThemeConstants.textPrimary(context) 
                                    : ThemeConstants.textSecondary(context),
                              ),
                            ),
                          ),
                          if (isCritical)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemeConstants.space2,
                                vertical: ThemeConstants.space1,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConstants.error.withValues(alpha: ThemeConstants.opacity10),
                                borderRadius: BorderRadius.circular(ThemeConstants.radiusXs),
                                border: Border.all(
                                  color: ThemeConstants.error.withValues(alpha: ThemeConstants.opacity30),
                                  width: ThemeConstants.borderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: ThemeConstants.space3,
                                    color: ThemeConstants.error,
                                  ),
                                  const SizedBox(width: ThemeConstants.space1),
                                  Text(
                                    'مطلوب',
                                    style: AppTextStyles.caption.copyWith(
                                      color: ThemeConstants.error,
                                      fontWeight: ThemeConstants.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: ThemeConstants.space1),
                      Text(
                        info.description,
                        style: AppTextStyles.caption.copyWith(
                          color: ThemeConstants.textSecondary(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: ThemeConstants.space3),
                
                // مؤشر الحالة
                if (!isCritical)
                  AnimatedContainer(
                    duration: ThemeConstants.durationFast,
                    width: ThemeConstants.iconMd,
                    height: ThemeConstants.iconMd,
                    decoration: BoxDecoration(
                      color: isSelected ? info.color : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? info.color : ThemeConstants.divider(context),
                        width: ThemeConstants.borderMedium,
                      ),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXs),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: ThemeConstants.iconSm,
                            color: Colors.white,
                          )
                        : null,
                  ),
                
                if (isCritical)
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.space2),
                    decoration: BoxDecoration(
                      color: ThemeConstants.success.withValues(alpha: ThemeConstants.opacity10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeConstants.success.withValues(alpha: ThemeConstants.opacity30),
                        width: ThemeConstants.borderMedium,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: ThemeConstants.iconSm,
                      color: ThemeConstants.success,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompletionPage() {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.space8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة الاكتمال
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: ThemeConstants.durationExtraSlow,
            curve: ThemeConstants.curveBounce,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeConstants.success,
                        ThemeConstants.success.withValues(alpha: ThemeConstants.opacity80),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConstants.success.withValues(alpha: ThemeConstants.opacity30),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: ThemeConstants.icon3xl,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: ThemeConstants.space8),
          
          // رسالة الاكتمال
          Text(
            'كل شيء جاهز!',
            style: AppTextStyles.h3.copyWith(
              fontWeight: ThemeConstants.bold,
              color: ThemeConstants.success,
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space4),
          
          Text(
            'سنطلب الأذونات المختارة الآن لبدء الاستخدام',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: ThemeConstants.textSecondary(context),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space8),
          
          // ملخص الأذونات
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space5),
            decoration: BoxDecoration(
              color: ThemeConstants.card(context),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              border: Border.all(
                color: ThemeConstants.success.withValues(alpha: ThemeConstants.opacity20),
                width: ThemeConstants.borderLight,
              ),
              boxShadow: ThemeConstants.shadowSm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: ThemeConstants.success,
                      size: ThemeConstants.iconMd,
                    ),
                    const SizedBox(width: ThemeConstants.space3),
                    Text(
                      'ملخص الأذونات المختارة',
                      style: AppTextStyles.h5.copyWith(
                        fontWeight: ThemeConstants.semiBold,
                        color: ThemeConstants.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeConstants.space4),
                if (_selectedPermissions.isEmpty)
                  Text(
                    'لم يتم اختيار أي أذونات',
                    style: AppTextStyles.body2.copyWith(
                      color: ThemeConstants.textSecondary(context),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Wrap(
                    spacing: ThemeConstants.space2,
                    runSpacing: ThemeConstants.space2,
                    children: _selectedPermissions.map((permission) {
                      final info = PermissionConstants.getInfo(permission);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.space3,
                          vertical: ThemeConstants.space1,
                        ),
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: ThemeConstants.opacity10),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                          border: Border.all(
                            color: info.color.withValues(alpha: ThemeConstants.opacity30),
                            width: ThemeConstants.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              info.icon,
                              size: ThemeConstants.iconSm,
                              color: info.color,
                            ),
                            const SizedBox(width: ThemeConstants.space1),
                            Text(
                              info.name,
                              style: AppTextStyles.caption.copyWith(
                                color: info.color,
                                fontWeight: ThemeConstants.medium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: ThemeConstants.space6),
          
          // ملاحظة مهمة
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: ThemeConstants.info.withValues(alpha: ThemeConstants.opacity10),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: ThemeConstants.info.withValues(alpha: ThemeConstants.opacity20),
                width: ThemeConstants.borderLight,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: ThemeConstants.info,
                  size: ThemeConstants.iconMd,
                ),
                const SizedBox(width: ThemeConstants.space3),
                Expanded(
                  child: Text(
                    'يمكنك تغيير إعدادات الأذونات لاحقاً من خلال إعدادات التطبيق',
                    style: AppTextStyles.caption.copyWith(
                      color: ThemeConstants.info,
                      height: 1.3,
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
  
  Widget _buildEnhancedNavigation() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      decoration: BoxDecoration(
        color: ThemeConstants.card(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: ThemeConstants.opacity05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر السابق
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessingPermissions ? null : _previousPage,
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: ThemeConstants.iconSm,
                ),
                label: const Text('السابق'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  side: BorderSide(
                    color: ThemeConstants.divider(context),
                    width: ThemeConstants.borderLight,
                  ),
                ),
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: ThemeConstants.space3),
          
          // زر التالي/البدء
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isProcessingPermissions ? null : _nextPage,
              icon: _isProcessingPermissions
                  ? const SizedBox(
                      width: ThemeConstants.iconSm,
                      height: ThemeConstants.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _currentPage == _totalPages - 1 
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: ThemeConstants.iconSm,
                    ),
              label: Text(
                _currentPage == _totalPages - 1 ? 'البدء الآن' : 'التالي',
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space4),
                backgroundColor: _currentPage == _totalPages - 1 
                    ? ThemeConstants.success 
                    : ThemeConstants.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                elevation: ThemeConstants.elevation2,
              ),
            ),
          ),
          
          // زر التخطي
          if (_currentPage < _totalPages - 1) ...[
            const SizedBox(width: ThemeConstants.space3),
            TextButton(
              onPressed: _isProcessingPermissions ? null : _skip,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.space4,
                  vertical: ThemeConstants.space3,
                ),
              ),
              child: Text(
                'تخطي',
                style: AppTextStyles.label2.copyWith(
                  color: ThemeConstants.textSecondary(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: ThemeConstants.opacity30),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.space8),
          decoration: BoxDecoration(
            color: ThemeConstants.card(context),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            boxShadow: ThemeConstants.shadowLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primary),
              ),
              const SizedBox(height: ThemeConstants.space4),
              Text(
                'جاري المعالجة...',
                style: AppTextStyles.body1.copyWith(
                  color: ThemeConstants.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required _DialogAction primaryAction,
    _DialogAction? secondaryAction,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.space6),
        decoration: BoxDecoration(
          color: ThemeConstants.card(context),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة التحذير
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: ThemeConstants.opacity10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: ThemeConstants.iconLg,
              ),
            ),
            
            const SizedBox(height: ThemeConstants.space4),
            
            // العنوان
            Text(
              title,
              style: AppTextStyles.h5.copyWith(
                fontWeight: ThemeConstants.bold,
                color: ThemeConstants.textPrimary(context),
              ),
            ),
            
            const SizedBox(height: ThemeConstants.space3),
            
            // المحتوى
            Text(
              content,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(
                color: ThemeConstants.textSecondary(context),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: ThemeConstants.space6),
            
            // الأزرار
            Row(
              children: [
                if (secondaryAction != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: secondaryAction.onPressed,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space4),
                      ),
                      child: Text(secondaryAction.text),
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.space3),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: primaryAction.onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAction.color ?? ThemeConstants.primary,
                      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space4),
                    ),
                    child: Text(
                      primaryAction.text,
                      style: const TextStyle(color: Colors.white),
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
}

/// Helper class للأزرار في الحوارات
class _DialogAction {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  
  _DialogAction({
    required this.text,
    required this.onPressed,
    this.color,
  });
}

/// Dialog لعرض التقدم أثناء معالجة الأذونات - محسن
class _PermissionProcessingDialog extends StatefulWidget {
  final int totalPermissions;
  final int currentIndex;
  final AppPermissionType? currentPermission;
  
  const _PermissionProcessingDialog({
    required this.totalPermissions,
    this.currentIndex = 0,
    this.currentPermission,
  });
  
  @override
  State<_PermissionProcessingDialog> createState() => __PermissionProcessingDialogState();
}

class __PermissionProcessingDialogState extends State<_PermissionProcessingDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: ThemeConstants.durationVerySlow,
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = widget.currentIndex > 0 ? widget.currentIndex / widget.totalPermissions : 0.0;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.space8),
        decoration: BoxDecoration(
          color: ThemeConstants.card(context),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation محسن
            Stack(
              alignment: Alignment.center,
              children: [
                // دائرة خارجية دوارة
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity30),
                        width: 3,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _LoadingPainter(
                        color: ThemeConstants.primary,
                        progress: progress,
                      ),
                    ),
                  ),
                ),
                // أيقونة في المنتصف
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: ThemeConstants.primary,
                    size: ThemeConstants.iconMd,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.space6),
            
            // العنوان
            Text(
              'جاري طلب الأذونات',
              style: AppTextStyles.h5.copyWith(
                fontWeight: ThemeConstants.bold,
                color: ThemeConstants.textPrimary(context),
              ),
            ),
            
            const SizedBox(height: ThemeConstants.space2),
            
            // التقدم
            if (widget.currentIndex > 0) ...[
              Text(
                'الإذن ${widget.currentIndex} من ${widget.totalPermissions}',
                style: AppTextStyles.body2.copyWith(
                  color: ThemeConstants.textSecondary(context),
                ),
              ),
              
              if (widget.currentPermission != null) ...[
                const SizedBox(height: ThemeConstants.space3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.space4,
                    vertical: ThemeConstants.space2,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity10),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                    border: Border.all(
                      color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity20),
                      width: ThemeConstants.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PermissionConstants.getInfo(widget.currentPermission!).icon,
                        size: ThemeConstants.iconSm,
                        color: ThemeConstants.primary,
                      ),
                      const SizedBox(width: ThemeConstants.space2),
                      Text(
                        PermissionConstants.getName(widget.currentPermission!),
                        style: AppTextStyles.caption.copyWith(
                          color: ThemeConstants.primary,
                          fontWeight: ThemeConstants.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: ThemeConstants.space5),
              
              // شريط التقدم محسن
              Container(
                height: ThemeConstants.space1,
                decoration: BoxDecoration(
                  color: ThemeConstants.divider(context),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ThemeConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConstants.primary.withValues(alpha: ThemeConstants.opacity30),
                          blurRadius: ThemeConstants.space1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Painter للـ Loading Animation
class _LoadingPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  _LoadingPainter({
    required this.color,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;
    
    // رسم قوس التقدم
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // البدء من الأعلى
      2 * 3.14159 * progress,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}