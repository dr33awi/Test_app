// lib/core/infrastructure/services/permissions/screens/professional_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:athkar_app/app//themes/app_theme.dart';
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

/// شاشة الترحيب الاحترافية المتقدمة
class ProfessionalOnboardingScreen extends StatefulWidget {
  final PermissionService permissionService;
  final List<AppPermissionType>? criticalPermissions;
  final List<AppPermissionType>? optionalPermissions;
  final Function(OnboardingResult)? onComplete;
  
  const ProfessionalOnboardingScreen({
    super.key,
    required this.permissionService,
    this.criticalPermissions,
    this.optionalPermissions,
    this.onComplete,
  });
  
  @override
  State<ProfessionalOnboardingScreen> createState() => _ProfessionalOnboardingScreenState();
}

class _ProfessionalOnboardingScreenState extends State<ProfessionalOnboardingScreen>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _mainAnimationController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _floatingElementsController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _slideDownAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _backgroundShiftAnimation;
  late Animation<double> _floatingAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4;
  
  final Set<AppPermissionType> _selectedPermissions = {};
  bool _isProcessingPermissions = false;
  
  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    // Controllers for different animation layers
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatingElementsController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    // Main content animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    
    _slideUpAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack)),
    );
    
    _slideDownAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: const Interval(0.0, 0.8, curve: Curves.elasticOut)),
    );
    
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack)),
    );
    
    // Background and floating animations
    _backgroundShiftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.linear),
    );
    
    _floatingAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _floatingElementsController, curve: Curves.linear),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOutCubic),
    );
    
    // Initialize selected permissions with critical ones
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    _selectedPermissions.addAll(criticalPermissions);
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() {
    _mainAnimationController.forward();
    _backgroundAnimationController.repeat();
    _floatingElementsController.repeat();
    _updateProgress();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _mainAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _progressAnimationController.dispose();
    _floatingElementsController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.mediumImpact();
      _resetPageAnimation();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _processPermissionsAndComplete();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _resetPageAnimation();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }
  
  void _resetPageAnimation() {
    _mainAnimationController.reset();
    _mainAnimationController.forward();
  }
  
  void _updateProgress() {
    _progressAnimationController.reset();
    _progressAnimationController.animateTo((_currentPage + 1) / _totalPages);
  }
  
  void _skip() {
    HapticFeedback.heavyImpact();
    _showProfessionalSkipDialog();
  }
  
  void _showProfessionalSkipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProfessionalSkipDialog(
        onConfirm: () {
          Navigator.pop(context);
          _completeWithResult(OnboardingResult(
            skipped: true,
            selectedPermissions: [],
          ));
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
  
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
    
    try {
      final results = await _requestPermissions();
      
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
        context.showErrorSnackBar('حدث خطأ في معالجة الأذونات');
      }
      setState(() {
        _isProcessingPermissions = false;
      });
    }
  }
  
  Future<Map<AppPermissionType, AppPermissionStatus>> _requestPermissions() async {
    final results = <AppPermissionType, AppPermissionStatus>{};
    final permissions = _selectedPermissions.toList();
    
    for (final permission in permissions) {
      try {
        final status = await widget.permissionService.requestPermission(permission);
        results[permission] = status;
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error requesting permission $permission: $e');
        results[permission] = AppPermissionStatus.unknown;
      }
    }
    
    return results;
  }
  
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
  
  void _completeWithResult(OnboardingResult result) {
    if (widget.onComplete != null) {
      widget.onComplete!(result);
    } else {
      Navigator.pop(context, result);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Background with dynamic patterns
            _buildDynamicBackground(),
            
            // Floating decorative elements
            _buildFloatingElements(),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Professional header with progress
                  _buildProfessionalHeader(),
                  
                  // Pages with advanced animations
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _mainAnimationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideUpAnimation.value),
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: PageView(
                                  controller: _pageController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  onPageChanged: (index) {
                                    setState(() => _currentPage = index);
                                    HapticFeedback.selectionClick();
                                    _updateProgress();
                                  },
                                  children: [
                                    _buildWelcomePage(),
                                    _buildFeaturesPage(),
                                    _buildPermissionSelectionPage(),
                                    _buildLaunchPage(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Professional navigation
                  _buildProfessionalNavigation(),
                ],
              ),
            ),
            
            // Processing overlay
            if (_isProcessingPermissions)
              _buildProfessionalLoadingOverlay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDynamicBackground() {
    return AnimatedBuilder(
      animation: _backgroundShiftAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_backgroundShiftAnimation.value * 0.2),
                0.7 + (_backgroundShiftAnimation.value * 0.1),
                1.0,
              ],
              colors: [
                context.primaryColor.withValues(alpha: 0.8),
                context.primaryColor.withValues(alpha: 0.6),
                ThemeConstants.accent.withValues(alpha: 0.4),
                ThemeConstants.tertiary.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _AdvancedIslamicPatternPainter(
              rotation: _backgroundShiftAnimation.value * 2 * math.pi,
              color: Colors.white,
              opacity: 0.08,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
  
  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating geometric shapes
            for (int i = 0; i < 6; i++)
              Positioned(
                left: (context.screenWidth * (0.1 + (i * 0.15))) + 
                      (math.sin(_floatingAnimation.value + i) * 20),
                top: (context.screenHeight * (0.2 + (i * 0.12))) + 
                     (math.cos(_floatingAnimation.value + i) * 15),
                child: _FloatingShape(
                  size: 30 + (i * 10),
                  color: Colors.white.withValues(alpha: 0.1),
                  rotation: _floatingAnimation.value + (i * 0.5),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildProfessionalHeader() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        children: [
          // Progress indicator with glow effect
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // Step indicator
          AnimatedBuilder(
            animation: _slideDownAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideDownAnimation.value),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.space4,
                        vertical: ThemeConstants.space2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPageIcon(),
                            size: ThemeConstants.iconSm,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          ThemeConstants.space2.w,
                          Text(
                            '${_currentPage + 1} من $_totalPages',
                            style: context.labelMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: ThemeConstants.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  IconData _getPageIcon() {
    switch (_currentPage) {
      case 0: return Icons.waving_hand_rounded;
      case 1: return Icons.auto_awesome_rounded;
      case 2: return Icons.security_rounded;
      case 3: return Icons.rocket_launch_rounded;
      default: return Icons.circle;
    }
  }
  
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        children: [
          ThemeConstants.space8.h,
          
          // Hero logo with advanced animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _ProfessionalLogo(),
              );
            },
          ),
          
          ThemeConstants.space8.h,
          
          // Welcome card with glassmorphism
          _ProfessionalCard(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, Colors.white.withValues(alpha: 0.8)],
                  ).createShader(bounds),
                  child: Text(
                    'أهلاً وسهلاً',
                    style: context.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: ThemeConstants.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                ThemeConstants.space3.h,
                
                Text(
                  'حصن المسلم',
                  style: context.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                    fontFamily: ThemeConstants.fontFamilyArabic,
                    letterSpacing: 2.0,
                  ),
                ),
                
                ThemeConstants.space4.h,
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.space5,
                    vertical: ThemeConstants.space3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'رفيقك اليومي في رحلة الذكر والعبادة',
                    textAlign: TextAlign.center,
                    style: context.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: ThemeConstants.medium,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          ThemeConstants.space6.h,
          
          // Feature highlights
          _buildWelcomeFeatures(),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeFeatures() {
    final features = [
      {'icon': Icons.auto_awesome, 'text': 'تجربة ذكية ومتطورة'},
      {'icon': Icons.security, 'text': 'حماية خصوصيتك أولوية'},
      {'icon': Icons.offline_bolt, 'text': 'يعمل بدون إنترنت'},
    ];
    
    return Row(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        
        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 800 + (index * 200)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * 30),
                child: Opacity(
                  opacity: value,
                  child: _MiniFeatureCard(
                    icon: feature['icon'] as IconData,
                    text: feature['text'] as String,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildFeaturesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        children: [
          // Page title
          _ProfessionalCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.space4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: ThemeConstants.icon2xl,
                    color: Colors.white,
                  ),
                ),
                
                ThemeConstants.space4.h,
                
                Text(
                  'ميزات استثنائية',
                  style: context.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                
                ThemeConstants.space2.h,
                
                Text(
                  'اكتشف المميزات التي ستجعل رحلتك الروحية أكثر ثراءً',
                  textAlign: TextAlign.center,
                  style: context.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          ThemeConstants.space6.h,
          
          // Features grid
          _buildAdvancedFeaturesGrid(),
        ],
      ),
    );
  }
  
  Widget _buildAdvancedFeaturesGrid() {
    final features = [
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'تذكيرات ذكية',
        'description': 'نظام تنبيهات متطور يتكيف مع روتينك اليومي',
        'color': const Color(0xFF4A90E2),
        'gradient': [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
      },
      {
        'icon': Icons.location_on_rounded,
        'title': 'مواقيت دقيقة',
        'description': 'حساب مواقيت الصلاة بدقة عالية حسب موقعك',
        'color': const Color(0xFF50C878),
        'gradient': [const Color(0xFF50C878), const Color(0xFF3A9B5C)],
      },
      {
        'icon': Icons.explore_rounded,
        'title': 'بوصلة القبلة',
        'description': 'تحديد اتجاه القبلة بدقة مع واجهة تفاعلية',
        'color': const Color(0xFFFF8A65),
        'gradient': [const Color(0xFFFF8A65), const Color(0xFFE57368)],
      },
      {
        'icon': Icons.menu_book_rounded,
        'title': 'مكتبة شاملة',
        'description': 'آلاف الأذكار والأدعية مع المصادر الموثقة',
        'color': const Color(0xFF9C27B0),
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      },
    ];
    
    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.space4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 600 + (index * 150)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset((1 - value) * (index.isEven ? -100 : 100), 0),
                child: Opacity(
                  opacity: value,
                  child: _AdvancedFeatureCard(
                    icon: feature['icon'] as IconData,
                    title: feature['title'] as String,
                    description: feature['description'] as String,
                    gradient: feature['gradient'] as List<Color>,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildPermissionSelectionPage() {
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    final optionalPermissions = widget.optionalPermissions ?? PermissionConstants.optionalPermissions;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        children: [
          // Page header
          _ProfessionalCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.space4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: ThemeConstants.icon2xl,
                    color: Colors.white,
                  ),
                ),
                
                ThemeConstants.space4.h,
                
                Text(
                  'الأذونات المطلوبة',
                  style: context.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                
                ThemeConstants.space2.h,
                
                Text(
                  'نحتاج بعض الأذونات لتقديم أفضل تجربة ممكنة\nجميع بياناتك محمية ولن نشاركها مع أي جهة',
                  textAlign: TextAlign.center,
                  style: context.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          ThemeConstants.space6.h,
          
          // Permissions list
          if (criticalPermissions.isNotEmpty) ...[
            _buildPermissionSection(
              title: 'أذونات أساسية',
              subtitle: 'مطلوبة لعمل التطبيق بشكل صحيح',
              permissions: criticalPermissions,
              isCritical: true,
              color: ThemeConstants.error,
            ),
          ],
          
          if (optionalPermissions.isNotEmpty) ...[
            ThemeConstants.space6.h,
            _buildPermissionSection(
              title: 'أذونات اختيارية',
              subtitle: 'تحسن من تجربتك مع التطبيق',
              permissions: optionalPermissions,
              isCritical: false,
              color: ThemeConstants.info,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPermissionSection({
    required String title,
    required String subtitle,
    required List<AppPermissionType> permissions,
    required bool isCritical,
    required Color color,
  }) {
    return Column(
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThemeConstants.space4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCritical ? Icons.star_rounded : Icons.info_outline_rounded,
                    color: color,
                    size: ThemeConstants.iconMd,
                  ),
                  ThemeConstants.space2.w,
                  Text(
                    title,
                    style: context.titleLarge?.copyWith(
                      color: color,
                      fontWeight: ThemeConstants.bold,
                    ),
                  ),
                ],
              ),
              ThemeConstants.space1.h,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: context.bodyMedium?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        
        ThemeConstants.space4.h,
        
        // Permissions list
        ...permissions.asMap().entries.map((entry) {
          final index = entry.key;
          final permission = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: ThemeConstants.space3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _ProfessionalPermissionCard(
                    permission: permission,
                    isCritical: isCritical,
                    isSelected: _selectedPermissions.contains(permission),
                    onToggle: isCritical ? null : () {
                      setState(() {
                        if (_selectedPermissions.contains(permission)) {
                          _selectedPermissions.remove(permission);
                        } else {
                          _selectedPermissions.add(permission);
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildLaunchPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      child: Column(
        children: [
          ThemeConstants.space8.h,
          
          // Launch animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeConstants.success,
                        ThemeConstants.success.lighten(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConstants.success.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: ThemeConstants.icon3xl,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          ThemeConstants.space8.h,
          
          // Ready message
          _ProfessionalCard(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      ThemeConstants.success.withValues(alpha: 0.8),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'جاهزون للانطلاق!',
                    style: context.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: ThemeConstants.bold,
                    ),
                  ),
                ),
                
                ThemeConstants.space4.h,
                
                Text(
                  'سنبدأ الآن في إعداد التطبيق وطلب الأذونات المختارة\nهذا لن يستغرق سوى لحظات قليلة',
                  textAlign: TextAlign.center,
                  style: context.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          
          if (_selectedPermissions.isNotEmpty) ...[
            ThemeConstants.space6.h,
            _buildSelectedPermissionsSummary(),
          ],
          
          ThemeConstants.space6.h,
          
          // Tips card
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeConstants.info.withValues(alpha: 0.2),
                  ThemeConstants.info.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              border: Border.all(
                color: ThemeConstants.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: ThemeConstants.info,
                  size: ThemeConstants.iconLg,
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نصيحة مهمة',
                        style: context.titleMedium?.copyWith(
                          color: ThemeConstants.info,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                      ThemeConstants.space1.h,
                      Text(
                        'يمكنك تعديل الأذونات في أي وقت من خلال إعدادات التطبيق',
                        style: context.bodyMedium?.copyWith(
                          color: ThemeConstants.info.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectedPermissionsSummary() {
    return _ProfessionalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: ThemeConstants.iconMd,
              ),
              ThemeConstants.space2.w,
              Text(
                'الأذونات المحددة (${_selectedPermissions.length})',
                style: context.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: ThemeConstants.bold,
                ),
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          Wrap(
            spacing: ThemeConstants.space2,
            runSpacing: ThemeConstants.space2,
            children: _selectedPermissions.map((permission) {
              final info = PermissionConstants.getInfo(permission);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.space3,
                  vertical: ThemeConstants.space2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      info.color.withValues(alpha: 0.8),
                      info.color.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: info.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      info.icon,
                      size: ThemeConstants.iconSm,
                      color: Colors.white,
                    ),
                    ThemeConstants.space1.w,
                    Text(
                      info.name,
                      style: context.labelMedium?.copyWith(
                        color: Colors.white,
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
    );
  }
  
  Widget _buildProfessionalNavigation() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentPage > 0)
            Expanded(
              child: _ProfessionalButton(
                text: 'السابق',
                icon: Icons.arrow_back_ios_rounded,
                onPressed: _isProcessingPermissions ? null : _previousPage,
                type: _ProfessionalButtonType.secondary,
              ),
            ),
          
          if (_currentPage > 0) ThemeConstants.space4.w,
          
          // Main button
          Expanded(
            flex: _currentPage == 0 ? 1 : 2,
            child: _ProfessionalButton(
              text: _currentPage == _totalPages - 1 ? 'ابدأ الرحلة' : 'التالي',
              icon: _currentPage == _totalPages - 1 
                  ? Icons.rocket_launch_rounded 
                  : Icons.arrow_forward_ios_rounded,
              onPressed: _isProcessingPermissions ? null : _nextPage,
              type: _currentPage == _totalPages - 1 
                  ? _ProfessionalButtonType.success 
                  : _ProfessionalButtonType.primary,
              isLoading: _isProcessingPermissions,
            ),
          ),
          
          // Skip button
          if (_currentPage < _totalPages - 1) ...[
            ThemeConstants.space4.w,
            _ProfessionalButton(
              text: 'تخطي',
              onPressed: _isProcessingPermissions ? null : _skip,
              type: _ProfessionalButtonType.ghost,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildProfessionalLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: _ProfessionalCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated loading indicator
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              
              ThemeConstants.space6.h,
              
              Text(
                'جاري إعداد التطبيق',
                style: context.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: ThemeConstants.bold,
                ),
              ),
              
              ThemeConstants.space2.h,
              
              Text(
                'سنطلب الأذونات المختارة الآن\nيرجى الانتظار...',
                textAlign: TextAlign.center,
                style: context.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Professional Components

class _ProfessionalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  
  const _ProfessionalCard({
    required this.child,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(ThemeConstants.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfessionalLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern
          Icon(
            Icons.mosque,
            size: 80,
            color: ThemeConstants.primary.withValues(alpha: 0.8),
          ),
          
          // Overlay glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFeatureCard extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _MiniFeatureCard({
    required this.icon,
    required this.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.space1),
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: ThemeConstants.iconMd,
          ),
          ThemeConstants.space2.h,
          Text(
            text,
            textAlign: TextAlign.center,
            style: context.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: ThemeConstants.medium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  
  const _AdvancedFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ThemeConstants.iconLg,
            ),
          ),
          
          ThemeConstants.space4.w,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                ThemeConstants.space2.h,
                Text(
                  description,
                  style: context.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalPermissionCard extends StatelessWidget {
  final AppPermissionType permission;
  final bool isCritical;
  final bool isSelected;
  final VoidCallback? onToggle;
  
  const _ProfessionalPermissionCard({
    required this.permission,
    required this.isCritical,
    required this.isSelected,
    this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    final info = PermissionConstants.getInfo(permission);
    
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: ThemeConstants.durationNormal,
        padding: const EdgeInsets.all(ThemeConstants.space5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected 
                ? [
                    info.color.withValues(alpha: 0.3),
                    info.color.withValues(alpha: 0.2),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          border: Border.all(
            color: isSelected 
                ? info.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: info.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: ThemeConstants.durationNormal,
              padding: const EdgeInsets.all(ThemeConstants.space3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [info.color, info.color.darken(0.2)]
                      : [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                border: Border.all(
                  color: isSelected 
                      ? info.color.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                info.icon,
                color: Colors.white,
                size: ThemeConstants.iconLg,
              ),
            ),
            
            ThemeConstants.space4.w,
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        info.name,
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                      if (isCritical) ...[
                        ThemeConstants.space2.w,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space2,
                            vertical: ThemeConstants.space1 / 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ThemeConstants.error,
                                ThemeConstants.error.darken(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              (ThemeConstants.space1 / 2).w,
                              Text(
                                'مطلوب',
                                style: context.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: ThemeConstants.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  ThemeConstants.space2.h,
                  Text(
                    info.description,
                    style: context.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            ThemeConstants.space3.w,
            
            // Toggle/Status indicator
            if (!isCritical)
              AnimatedContainer(
                duration: ThemeConstants.durationNormal,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [info.color, info.color.darken(0.2)])
                      : null,
                  color: isSelected ? null : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected 
                        ? info.color 
                        : Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              )
            else
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeConstants.success,
                      ThemeConstants.success.darken(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: ThemeConstants.iconSm,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _ProfessionalButtonType {
  primary,
  secondary,
  success,
  ghost,
}

class _ProfessionalButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final _ProfessionalButtonType type;
  final bool isLoading;
  
  const _ProfessionalButton({
    required this.text,
    this.icon,
    this.onPressed,
    required this.type,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: colors.gradient,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: colors.border,
        boxShadow: colors.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.space5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
                    ),
                  )
                else if (icon != null) ...[
                  Icon(
                    icon,
                    color: colors.textColor,
                    size: ThemeConstants.iconMd,
                  ),
                  ThemeConstants.space2.w,
                ],
                Text(
                  text,
                  style: context.titleMedium?.copyWith(
                    color: colors.textColor,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  _ButtonColors _getColors() {
    switch (type) {
      case _ProfessionalButtonType.primary:
        return _ButtonColors(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.8),
            ],
          ),
          textColor: ThemeConstants.primary,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          shadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        );
        
      case _ProfessionalButtonType.secondary:
        return _ButtonColors(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          textColor: Colors.white,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
          shadow: null,
        );
        
      case _ProfessionalButtonType.success:
        return _ButtonColors(
          gradient: LinearGradient(
            colors: [
              ThemeConstants.success,
              ThemeConstants.success.darken(0.2),
            ],
          ),
          textColor: Colors.white,
          border: Border.all(
            color: ThemeConstants.success.withValues(alpha: 0.6),
            width: 1,
          ),
          shadow: [
            BoxShadow(
              color: ThemeConstants.success.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
        
      case _ProfessionalButtonType.ghost:
        return _ButtonColors(
          gradient: const LinearGradient(
            colors: [Colors.transparent, Colors.transparent],
          ),
          textColor: Colors.white.withValues(alpha: 0.7),
          border: null,
          shadow: null,
        );
    }
  }
}

class _ButtonColors {
  final Gradient gradient;
  final Color textColor;
  final Border? border;
  final List<BoxShadow>? shadow;
  
  _ButtonColors({
    required this.gradient,
    required this.textColor,
    this.border,
    this.shadow,
  });
}

class _FloatingShape extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;
  
  const _FloatingShape({
    required this.size,
    required this.color,
    required this.rotation,
  });
  
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AdvancedIslamicPatternPainter extends CustomPainter {
  final double rotation;
  final Color color;
  final double opacity;
  
  _AdvancedIslamicPatternPainter({
    required this.rotation,
    required this.color,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    
    // Draw complex Islamic pattern
    _drawComplexIslamicPattern(canvas, size, paint);
    
    canvas.restore();
  }
  
  void _drawComplexIslamicPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw multiple layers of geometric patterns
    for (int layer = 1; layer <= 3; layer++) {
      final radius = 80.0 * layer;
      
      // Octagonal stars
      _drawOctagonalStar(canvas, centerX, centerY, radius, paint);
      
      // Connecting lines
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4);
        final x1 = centerX + (radius * 0.7) * math.cos(angle);
        final y1 = centerY + (radius * 0.7) * math.sin(angle);
        final x2 = centerX + radius * math.cos(angle);
        final y2 = centerY + radius * math.sin(angle);
        
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
    
    // Corner decorations
    _drawCornerDecorations(canvas, size, paint);
  }
  
  void _drawOctagonalStar(Canvas canvas, double centerX, double centerY, double radius, Paint paint) {
    final path = Path();
    const int points = 8;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final currentRadius = i.isEven ? radius : radius * 0.4;
      final x = centerX + currentRadius * math.cos(angle);
      final y = centerY + currentRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawCornerDecorations(Canvas canvas, Size size, Paint paint) {
    final corners = [
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.9),
    ];
    
    for (final corner in corners) {
      _drawCornerPattern(canvas, corner, paint);
    }
  }
  
  void _drawCornerPattern(Canvas canvas, Offset center, Paint paint) {
    // Draw small decorative pattern at corner
    final path = Path();
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final radius = 15.0;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant _AdvancedIslamicPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation || 
           oldDelegate.color != color ||
           oldDelegate.opacity != opacity;
  }
}

// Professional Skip Dialog
class _ProfessionalSkipDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  const _ProfessionalSkipDialog({
    required this.onConfirm,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.space6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.primaryColor.withValues(alpha: 0.95),
              context.primaryColor.darken(0.2).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(ThemeConstants.radius2xl),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeConstants.warning,
                    ThemeConstants.warning.darken(0.2),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.warning.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: ThemeConstants.icon2xl,
              ),
            ),
            
            ThemeConstants.space4.h,
            
            // Title
            Text(
              'تخطي الإعداد؟',
              style: context.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.bold,
              ),
            ),
            
            ThemeConstants.space3.h,
            
            // Content
            Text(
              'قد لا تعمل بعض ميزات التطبيق بشكل صحيح بدون الأذونات المطلوبة.\n\nيمكنك تفعيلها لاحقاً من الإعدادات.',
              textAlign: TextAlign.center,
              style: context.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
            
            ThemeConstants.space6.h,
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: _ProfessionalButton(
                    text: 'البقاء',
                    onPressed: onCancel,
                    type: _ProfessionalButtonType.secondary,
                  ),
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: _ProfessionalButton(
                    text: 'تخطي',
                    icon: Icons.skip_next_rounded,
                    onPressed: onConfirm,
                    type: _ProfessionalButtonType.primary,
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