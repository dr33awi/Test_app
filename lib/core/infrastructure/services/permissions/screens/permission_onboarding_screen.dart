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

/// شاشة Onboarding الموحدة لطلب الأذونات - التصميم المحسن
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
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _floatingAnimation;
  
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeAnimations();
    
    // إضافة الأذونات الحرجة تلقائياً
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    _selectedPermissions.addAll(criticalPermissions);
    
    _animationController.forward();
  }
  
  void _initializeAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _colorAnimation = ColorTween(
      begin: ThemeConstants.primary,
      end: ThemeConstants.accent,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _floatingAnimation = Tween<double>(
      begin: -20.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
      _animationController.forward();
    } else {
      _processPermissionsAndComplete();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
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
      builder: (context) => _buildModernDialog(
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
    
    if (_selectedPermissions.isEmpty) {
      _completeWithResult(OnboardingResult(
        skipped: false,
        selectedPermissions: [],
      ));
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _ModernPermissionProcessingDialog(
          totalPermissions: _selectedPermissions.length,
        ),
      ),
    );
    
    try {
      final results = await _requestPermissions();
      
      if (mounted) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        await _showResults(results);
      }
      
      _completeWithResult(OnboardingResult(
        skipped: false,
        selectedPermissions: _selectedPermissions.toList(),
      ));
      
    } catch (e) {
      debugPrint('Error processing permissions: $e');
      
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
      
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: _ModernPermissionProcessingDialog(
              totalPermissions: permissions.length,
              currentIndex: i + 1,
              currentPermission: permission,
            ),
          ),
        );
      }
      
      try {
        final status = await widget.permissionService.requestPermission(permission);
        results[permission] = status;
        debugPrint('Permission ${permission.toString()}: ${status.toString()}');
      } catch (e) {
        debugPrint('Error requesting permission $permission: $e');
        results[permission] = AppPermissionStatus.unknown;
      }
      
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
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeConstants.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متدرجة ديناميكية محسنة
            _buildEnhancedAnimatedBackground(),
            
            // عناصر زخرفية عائمة
            _buildFloatingElements(),
            
            // المحتوى الرئيسي
            SafeArea(
              child: Column(
                children: [
                  // Header مع Progress المحسن
                  _buildModernHeader(),
                  
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
                                  _buildModernWelcomePage(),
                                  _buildModernExplanationPage(),
                                  _buildModernPermissionSelectionPage(),
                                  _buildModernCompletionPage(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Navigation المحسن
                  _buildModernNavigation(),
                ],
              ),
            ),
            
            // Loading overlay محسن
            if (_isProcessingPermissions)
              _buildModernLoadingOverlay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnhancedAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_rotateAnimation.value * 0.2),
              colors: [
                const Color(0xFF1E3A8A), // أزرق داكن إسلامي
                const Color(0xFF059669), // أخضر إسلامي
                const Color(0xFFDC2626), // أحمر دافئ
                const Color(0xFF7C3AED), // بنفسجي ملكي
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // عناصر هندسية إسلامية
            Positioned(
              top: 100 + _floatingAnimation.value,
              right: 30,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 2,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white24,
                    size: 30,
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 200 - _floatingAnimation.value,
              left: 40,
              child: Transform.rotate(
                angle: -_rotateAnimation.value * 1.5,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white12,
                    size: 40,
                  ),
                ),
              ),
            ),
            
            Positioned(
              top: 300 + _floatingAnimation.value * 0.5,
              left: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            
            Positioned(
              bottom: 400 - _floatingAnimation.value * 0.8,
              right: 50,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          // عنوان الصفحة مع تأثير متدرج
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white70],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              'إعداد التطبيق',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'مرحباً بك في رحلتك الروحانية',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Progress Bar فاخر
          Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: (_currentPage + 1) / _totalPages,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white70,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
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
          
          const SizedBox(height: 20),
          
          // Page indicators مع أنيميشن فاخر
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final isActive = index == _currentPage;
              final isPassed = index < _currentPage;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 32 : 8,
                decoration: BoxDecoration(
                  color: isPassed 
                      ? Colors.green.shade300
                      : isActive 
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                child: isPassed ? const Center(
                  child: Icon(
                    Icons.check,
                    size: 6,
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
  
  Widget _buildModernWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // شعار التطبيق الفاخر
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [
                        Colors.white,
                        Colors.white70,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // دائرة داخلية للتأثير
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // الأيقونة
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF059669),
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.mosque_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // عنوان الترحيب مع تأثير متدرج
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white70],
            ).createShader(bounds),
            child: const Text(
              'بسم الله نبدأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white60],
            ).createShader(bounds),
            child: const Text(
              'حصن المسلم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // وصف التطبيق
          Text(
            'رفيقك اليومي للأذكار والعبادات\nوالتقرب إلى الله سبحانه وتعالى',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.8,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // إحصائيات سريعة محسنة
          _buildModernWelcomeStats(),
        ],
      ),
    );
  }
  
  Widget _buildModernWelcomeStats() {
    final stats = [
      {'icon': Icons.menu_book_rounded, 'label': 'أذكار', 'count': '200+', 'color': Colors.amber},
      {'icon': Icons.access_time_rounded, 'label': 'مواقيت', 'count': 'دقيقة', 'color': Colors.blue},
      {'icon': Icons.explore_rounded, 'label': 'قبلة', 'count': 'ذكية', 'color': Colors.green},
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((stat) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (stat['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (stat['color'] as Color).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                stat['icon'] as IconData,
                color: stat['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat['count'] as String,
              style: TextStyle(
                fontSize: 16,
                color: stat['color'] as Color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              stat['label'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
  
  Widget _buildModernExplanationPage() {
    final features = [
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'تذكيرات ذكية',
        'description': 'تنبيهات في الأوقات المناسبة للأذكار والصلوات',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.location_on_rounded,
        'title': 'مواقيت دقيقة',
        'description': 'حساب دقيق لمواقيت الصلاة حسب موقعك الجغرافي',
        'color': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.explore_rounded,
        'title': 'اتجاه القبلة',
        'description': 'بوصلة دقيقة لتحديد اتجاه القبلة الصحيح',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.menu_book_rounded,
        'title': 'أذكار شاملة',
        'description': 'مجموعة كاملة من الأذكار اليومية مع الأدعية',
        'color': const Color(0xFFF59E0B),
      },
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'ميزات التطبيق',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'تعرف على الميزات الرائعة التي ستساعدك في رحلتك الروحية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 800 + (index * 200)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset((1 - value) * 300, 0),
                  child: Opacity(
                    opacity: value,
                    child: _buildModernFeatureCard(
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
  
  Widget _buildModernFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة فاخرة
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // رقم الترتيب
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernPermissionSelectionPage() {
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    final optionalPermissions = widget.optionalPermissions ?? PermissionConstants.optionalPermissions;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الصفحة
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 40,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'الأذونات المطلوبة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'نحتاج بعض الأذونات لتوفير أفضل تجربة ممكنة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // الأذونات الأساسية
          _buildModernPermissionSection(
            title: 'أذونات أساسية',
            subtitle: 'مطلوبة لعمل التطبيق بشكل صحيح',
            icon: Icons.star_rounded,
            color: const Color(0xFFEF4444),
            permissions: criticalPermissions,
            isCritical: true,
          ),
          
          if (optionalPermissions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildModernPermissionSection(
              title: 'أذونات اختيارية',
              subtitle: 'لتحسين تجربة الاستخدام',
              icon: Icons.tune_rounded,
              color: const Color(0xFF3B82F6),
              permissions: optionalPermissions,
              isCritical: false,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildModernPermissionSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<AppPermissionType> permissions,
    required bool isCritical,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // قائمة الأذونات
          ...permissions.map((permission) => 
            _buildModernPermissionItem(permission, isCritical: isCritical),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernPermissionItem(AppPermissionType permission, {required bool isCritical}) {
    final info = PermissionConstants.getInfo(permission);
    final isSelected = _selectedPermissions.contains(permission);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? info.color.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? info.color.withOpacity(0.6)
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // أيقونة الإذن
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? info.color.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    info.icon,
                    color: isSelected ? info.color : Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                          if (isCritical)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'مطلوب',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFEF4444),
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
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // مؤشر الحالة
                if (!isCritical)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? info.color : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? info.color : Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                
                if (isCritical)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernCompletionPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة الاكتمال الفاخرة
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // رسالة الاكتمال
          const Text(
            'كل شيء جاهز!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'سنطلب الأذونات المختارة الآن لبدء الاستخدام',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // ملخص الأذونات المحسن
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ملخص الأذونات المختارة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedPermissions.isEmpty)
                  Text(
                    'لم يتم اختيار أي أذونات',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedPermissions.map((permission) {
                      final info = PermissionConstants.getInfo(permission);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: info.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: info.color.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              info.icon,
                              size: 16,
                              color: info.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              info.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: info.color,
                                fontWeight: FontWeight.w600,
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
          
          const SizedBox(height: 24),
          
          // ملاحظة مهمة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يمكنك تغيير إعدادات الأذونات لاحقاً من خلال إعدادات التطبيق',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF3B82F6).withOpacity(0.9),
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
  
  Widget _buildModernNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // زر السابق
          if (_currentPage > 0)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isProcessingPermissions ? null : _previousPage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'السابق',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 12),
          
          // زر التالي/البدء
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: _currentPage == _totalPages - 1 
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_currentPage == _totalPages - 1 
                        ? const Color(0xFF10B981) 
                        : Colors.white).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isProcessingPermissions ? null : _nextPage,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isProcessingPermissions)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          Icon(
                            _currentPage == _totalPages - 1 
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: _currentPage == _totalPages - 1 
                                ? Colors.white 
                                : const Color(0xFF1E3A8A),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _currentPage == _totalPages - 1 ? 'البدء الآن' : 'التالي',
                          style: TextStyle(
                            fontSize: 16,
                            color: _currentPage == _totalPages - 1 
                                ? Colors.white 
                                : const Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // زر التخطي
          if (_currentPage < _totalPages - 1) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: _isProcessingPermissions ? null : _skip,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                'تخطي',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildModernLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'جاري المعالجة...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required _DialogAction primaryAction,
    _DialogAction? secondaryAction,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة التحذير
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // العنوان
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // المحتوى
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // الأزرار
            Row(
              children: [
                if (secondaryAction != null) ...[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: secondaryAction.onPressed,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                secondaryAction.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryAction.color ?? const Color(0xFF1E3A8A),
                          (primaryAction.color ?? const Color(0xFF1E3A8A)).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: primaryAction.onPressed,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              primaryAction.text,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
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

/// Dialog لعرض التقدم أثناء معالجة الأذونات - تصميم فاخر
class _ModernPermissionProcessingDialog extends StatefulWidget {
  final int totalPermissions;
  final int currentIndex;
  final AppPermissionType? currentPermission;
  
  const _ModernPermissionProcessingDialog({
    required this.totalPermissions,
    this.currentIndex = 0,
    this.currentPermission,
  });
  
  @override
  State<_ModernPermissionProcessingDialog> createState() => __ModernPermissionProcessingDialogState();
}

class __ModernPermissionProcessingDialogState extends State<_ModernPermissionProcessingDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = widget.currentIndex > 0 ? widget.currentIndex / widget.totalPermissions : 0.0;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation فاخر
            Stack(
              alignment: Alignment.center,
              children: [
                // دائرة خارجية دوارة مع تأثير النبض
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: CustomPaint(
                            painter: _ModernLoadingPainter(
                              color: Colors.white,
                              progress: progress,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // أيقونة في المنتصف مع تدرج
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 30,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // العنوان
            const Text(
              'جاري طلب الأذونات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // التقدم
            if (widget.currentIndex > 0) ...[
              Text(
                'الإذن ${widget.currentIndex} من ${widget.totalPermissions}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              
              if (widget.currentPermission != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PermissionConstants.getInfo(widget.currentPermission!).icon,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        PermissionConstants.getName(widget.currentPermission!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // شريط التقدم فاخر
              Container(
                height: 4,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // نسبة التقدم
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Text(
                'جاري التحضير...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Painter للـ Loading Animation الفاخر
class _ModernLoadingPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  _ModernLoadingPainter({
    required this.color,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    // رسم قوس التقدم مع تدرج
    final gradient = SweepGradient(
      colors: [
        color.withOpacity(0.2),
        color,
        color.withOpacity(0.8),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
    
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